import { AvCastController } from '../controller/AvCastController';
import { AvSessionController } from '../controller/AvSessionController';
import { avSession } from '@kit.AVSessionKit';
import { VideoData } from '../model/VideoData';
import promptAction from '@ohos.promptAction';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CastSessionListener, CastStatusModel } from '../model/CastStatusModel'
import { media } from '@kit.MediaKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';

const TAG = '[CastService]'
const DOMAIN = 0x000

@ObservedV2
export class CastService {
  private static instance: CastService | null;
  private context?: common.UIAbilityContext;
  private sessionController: AvSessionController = AvSessionController.getInstance();
  private castController?: AvCastController;
  private sessionListener?: CastSessionListener;
  private curSource?: VideoData;
  @Trace castStatusModel: CastStatusModel = CastStatusModel.instance
  windowStage: window.WindowStage = AppStorage.get('windowStage')!

  constructor() {
  }

  public static getInstance(): CastService {
    if (!CastService.instance) {
      CastService.instance = new CastService();
    }
    return CastService.instance;
  }

  // 使用UIAbilityContext初始化
  public async init(context: common.UIAbilityContext) {
    this.context = context
    await this.sessionController.initAvSession(context)
    await this.initAvCastController()
  }

  public deinit() {
    this.sessionController.release()

  }

  private async reInit() {
    hilog.info(DOMAIN, TAG, 're init')
    await this.sessionController.initAvSession(this.context!!)
    await this.initAvCastController()
    this.castController = undefined
  }

  getAvSessionController(): AvSessionController {
    return this.sessionController
  }

  getAvCastController(): AvCastController | undefined {
    return this.castController
  }

  private async initAvCastController() {
    try {
      if (AvSessionController.getInstance().getAvSession()) {
        hilog.error(0x000, TAG, 'initAvCastController')
        AvSessionController.getInstance().getAvSession()?.on('play', this.sessionPlayCallback);
        AvSessionController.getInstance().getAvSession()?.on('pause', this.sessionPauseCallback);
        AvSessionController.getInstance().getAvSession()?.on('playNext', this.sessionPlayNextCallback);
        AvSessionController.getInstance().getAvSession()?.on('playPrevious', this.sessionPlayPreviousCallback);
        AvSessionController.getInstance().getAvSession()?.on('fastForward', this.sessionFastForwardCallback);
        AvSessionController.getInstance().getAvSession()?.on('rewind', this.sessionRewindCallback);
        AvSessionController.getInstance().getAvSession()?.on('seek', this.sessionSeekCallback);
        AvSessionController.getInstance().getAvSession()?.on('outputDeviceChange', this.sessionOutputDeviceChange)
        AvSessionController.getInstance().getAvSession()?.activate();
      }
    } catch (e) {
      hilog.error(0x000, TAG, `initAvCastController failed: ${e}`);
    }
  }

  public registerSessionListener(listener: CastSessionListener): void {
    this.sessionListener = listener
  }

  public unregisterSessionListener(listener: CastSessionListener): void {
    this.sessionListener = undefined
  }

  private sessionOutputDeviceChange = async (connectState: avSession.ConnectionState,
    device: avSession.OutputDeviceInfo) => {
    let currentDevice: avSession.DeviceInfo = device?.devices?.[0];
    this.castStatusModel.currentDeviceName = device?.devices[0].deviceName
    this.castStatusModel.currentDeviceType = device?.devices[0].deviceType
    if (currentDevice.castCategory === avSession.AVCastCategory.CATEGORY_REMOTE &&
      connectState === avSession.ConnectionState.STATE_CONNECTED) {
      if (this.curSource) {
        let innerController: avSession.AVCastController | null = null;
        try {
          innerController = await this.sessionController.getAvSession()?.getAVCastController() ?? null;
        } catch (e) {
          hilog.error(DOMAIN, TAG, `getAVCastController failed: ${e}`);
        }
        if (innerController) {
          this.castController = new AvCastController(innerController)
          if (this.sessionListener) {
            this.castController.registerCastListener(this.sessionListener)
          }
          this.changeCasting()
          this.castStatusModel.isCasting = true
          this.sessionListener?.onStartCasting()
        }
      } else {
        this.windowStage.getMainWindowSync().getUIContext().getPromptAction().showToast({ message: '获取投播资源失败' })
        hilog.error(DOMAIN, TAG, 'can not get video source')
        this.castController?.endCasting()
        this.castStatusModel.isCasting = false
      }
    } else if ((currentDevice.castCategory === avSession.AVCastCategory.CATEGORY_REMOTE &&
      connectState === avSession.ConnectionState.STATE_DISCONNECTED) ||
      (currentDevice.castCategory === avSession.AVCastCategory.CATEGORY_LOCAL &&
        connectState === avSession.ConnectionState.STATE_CONNECTED)) {
      if (device) {
        hilog.info(DOMAIN, TAG, `remote to local`)
        this.castStatusModel.isCasting = false
        this.castController?.endCasting()
      }
    }
  };

  /* 投播：播放
   * 1.设置AVSession状态
   * 2.发送AVCast播放命令
   */
  public async play(position?: avSession.PlaybackPosition, duration?: number) {
    hilog.debug(DOMAIN, TAG, `play elapsedTime:${position?.elapsedTime} duration:${duration}`)
    if (this.sessionController) {
      let playbackState: avSession.AVPlaybackState = {
        state: avSession.PlaybackState.PLAYBACK_STATE_PLAY,
        position: position,
        duration: duration
      }
      this.sessionController.setAvSessionPlayState(playbackState)
      if (duration !== undefined) {
        this.castStatusModel.castDuration = duration
        hilog.debug(DOMAIN, TAG, `play duration:${this.castStatusModel.castDuration}`)
      }
      hilog.debug(DOMAIN, TAG, 'session play')
      if (this.castController && this.castStatusModel.isCasting) {
        await this.castController.play()
        hilog.debug(DOMAIN, TAG, 'cast play')
      }
    }
  }

  /* 投播：暂停
   * 1.设置AVSession状态
   * 2.发送AVCast 暂停命令
   */
  public pause(position?: avSession.PlaybackPosition, duration?: number) {
    hilog.debug(DOMAIN, TAG, `pause elapsedTime:${position?.elapsedTime} duration:${duration}`)
    if (this.sessionController) {
      let playbackState: avSession.AVPlaybackState = {
        state: this.castStatusModel.isCastPlaying ? avSession.PlaybackState.PLAYBACK_STATE_PLAY :
        avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
        position: position,
        duration: duration
      }
      this.sessionController.setAvSessionPlayState(playbackState)
      if (duration !== undefined) {
        this.castStatusModel.castDuration = duration
        hilog.debug(DOMAIN, TAG, `pause duration:${this.castStatusModel.castDuration}`)
      }
      hilog.debug(DOMAIN, TAG, 'session pause')
      if (this.castController) {
        this.castController.pause()
        hilog.debug(DOMAIN, TAG, 'cast pause')
      }

    }
  }

  /* 投播：seek
   * 1.设置AVSession状态
   * 2.发送AVCast seek命令
   */
  public seek(time: number) {
    hilog.debug(DOMAIN, TAG, 'seek')
    if (this.sessionController) {
      let playbackState: avSession.AVPlaybackState = {
        state: this.castStatusModel.isCastPlaying ? avSession.PlaybackState.PLAYBACK_STATE_PLAY :
        avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
        position: {
          elapsedTime: this.castStatusModel.castCurrentTime * 1000,
          updateTime: new Date().getTime()
        },
        duration: this.castStatusModel.castDuration
      }
      this.sessionController.setAvSessionPlayState(playbackState)
      hilog.debug(DOMAIN, TAG, 'session seek')
      if (this.castController && this.castStatusModel.isCasting) {
        this.castController.seekCasting(time)
        hilog.debug(DOMAIN, TAG, 'cast seek')
      }
    }
  }

  // 投播：设置音量
  public setVolume(value: number) {
    this.castController?.setVolume(value)
    hilog.debug(DOMAIN, TAG, `cast setVolume:${value}`)
  }

  public setVolumeByOffset(value: number) {
    this.castController?.setVolumeByOffset(value)
    hilog.debug(DOMAIN, TAG, `cast setVolumeByOffset:${value}`)
  }

  // 播控中心：设置播控信息，更换播放内容时必须设置
  public async setAVMetadata(videoData: VideoData, duration?: number) {
    hilog.debug(DOMAIN, TAG, `setAVMetadata ${JSON.stringify(videoData)} duration:${duration}`)
    let preSource = this.curSource
    this.curSource = videoData
    if (duration !== undefined) {
      this.castStatusModel.castDuration = duration
      hilog.debug(DOMAIN, TAG, `setAVMetadata duration:${this.castStatusModel.castDuration}`)
    }
    if (!this.sessionController.getAvSession()) {
      // 重新初始化
      await this.reInit()
    }
    if (this.sessionController) {
      await this.sessionController.setAVMetadata(videoData, duration)
      hilog.debug(DOMAIN, TAG, `session setAVMetadata`)
    }
    if (this.castController && this.castStatusModel.isCasting) {
      if (preSource !== this.curSource) {
        await this.changeCasting()
      }
    }

  }

  private async changeCasting(): Promise<boolean> {
    let castItem: avSession.AVQueueItem
    if (!this.curSource) {
      return false
    }
    if(this.curSource.url?.substring(0,4) === 'http'){
      castItem = {
        itemId: this.curSource.index,
        description: {
          assetId: '${this.curSource?.index}',
          title: this.curSource.name,
          mediaUri: this.curSource.url,
          mediaType: 'VIDEO',
          mediaImage: this.curSource.head
        }
      }
    }else if(this.curSource.url?.substring(0,4) === 'file'){
      let file = fileIo.openSync(this.curSource.url, fileIo.OpenMode.READ_ONLY);
      let fileSize:number = 0
      fileIo.stat(this.curSource.url, (err: BusinessError, stat: fileIo.Stat) => {
        if (err) {
          console.error('get file info failed with error message: ' + err.message + ', error code: ' + err.code);
        } else {
          fileSize = stat.size
          console.info('get file info succeed, the size of file is ' + stat.size);
        }
      });
      let buffer = new ArrayBuffer(fileSize);
      fileIo.readSync(file.fd, buffer);
      let avFileDescriptor: media.AVFileDescriptor = { fd: file.fd }
      castItem = {
        itemId: this.curSource.index,
        description: {
          assetId: '${this.curSource?.index}',
          title: this.curSource.name,
          fdSrc: avFileDescriptor,
          mediaType: 'VIDEO',
          mediaImage: this.curSource.head
        }
      }
    }else{
      this.windowStage.getMainWindowSync().getUIContext().getPromptAction().showToast({ message: '获取投播资源失败' })
      return false
    }
    if (castItem) {
      await this.castController?.startCasting(castItem)
      this.castStatusModel.isCasting = true
    } else {
      hilog.error(DOMAIN, TAG, `no cast item`)
      this.castController?.endCasting()
      this.castStatusModel.isCasting = false
      this.sessionListener?.onEndCasting()
    }
    return true;
  }

  // 停止远程播放
  public endCasting() {
    hilog.debug(DOMAIN, TAG, `user endCasting`)
    if (this.castController) {
      this.castController.endCasting()
      this.castStatusModel.isCasting = false
      this.sessionListener?.onEndCasting()
      hilog.debug(DOMAIN, TAG, `user cast endCasting`)
      this.sessionListener?.onPause()
    }
  }

  private sessionPlayCallback = (): void => {
    hilog.debug(DOMAIN, TAG, `sessionPlay`)
    this.sessionListener?.onPlay()
  };
  private sessionPauseCallback = (): void => {
    hilog.debug(DOMAIN, TAG, `sessionPause`)
    this.sessionListener?.onPause()
  };
  private sessionPlayNextCallback = (): void => {
    hilog.debug(DOMAIN, TAG, `sessionPlayNext`)
    this.sessionListener?.onPlayNext()
  };
  private sessionPlayPreviousCallback = (): void => {
    hilog.debug(DOMAIN, TAG, `sessionPlayPrevious`)
    this.sessionListener?.onPlayPre()
  };
  private sessionFastForwardCallback = (time?: number) => {
    if (!time) {
      return;
    }
    hilog.debug(DOMAIN, TAG, `sessionFastForward`)
    this.sessionListener?.onFastForward(time)
  };
  private sessionRewindCallback = (time?: number) => {
    if (!time) {
      return;
    }
    hilog.debug(DOMAIN, TAG, `sessionRewind`)
    this.sessionListener?.onRewind(time)
  };
  private sessionSeekCallback = (seekTime: number) => {
    hilog.debug(DOMAIN, TAG, `sessionSeek`)
    this.sessionListener?.onSeek(seekTime)
  };
}

export interface CastListener {
  onEndCasting(): void

  onPlay(): void

  onPause(): void

  onPlayNext(): void

  onPlayPre(): void

  onSeek(time: number): void

  onFastForward(time: number): void

  onRewind(time: number): void

  onDurationChange(duration: number): void

  onPositionChange(position: number): void
}