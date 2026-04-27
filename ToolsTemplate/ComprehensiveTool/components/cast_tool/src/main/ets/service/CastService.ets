import { avSession } from '@kit.AVSessionKit';
import { common } from '@kit.AbilityKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { AvCastController } from '../controller/AvCastController';
import { AvSessionController } from '../controller/AvSessionController';
import { toastUtil } from '../util/ToastUtil';
import { MediaData, CastSessionListener, CastStatusModel, MediaType } from '../model/Index';


const TAG = '[CastService]';


@ObservedV2
export class CastService {
  private static instance: CastService | null;
  @Trace castStatusModel: CastStatusModel = new CastStatusModel;
  private context?: common.UIAbilityContext;
  private sessionController: AvSessionController = AvSessionController.getInstance();
  private castController?: AvCastController;
  private sessionListener?: CastSessionListener;
  private curSource?: MediaData;
  private curFile: fs.File | undefined = undefined;
  private sessionOutputDeviceChange = async (connectState: avSession.ConnectionState,
    device: avSession.OutputDeviceInfo) => {
    let currentDevice: avSession.DeviceInfo = device?.devices?.[0];
    this.castStatusModel.currentDeviceName = device?.devices[0].deviceName;
    this.castStatusModel.currentDeviceType = device?.devices[0].deviceType;
    if (currentDevice.castCategory === avSession.AVCastCategory.CATEGORY_REMOTE &&
      connectState === avSession.ConnectionState.STATE_CONNECTED) {
      if (this.curSource) {
        let innerController = await this.sessionController.getAvSession()?.getAVCastController();
        if (innerController) {
          this.castController = new AvCastController(innerController);
          if (this.sessionListener) {
            this.castController.registerCastListener(this.sessionListener);
          }
          this.castStatusModel.isCasting = true;
        }
      } else {
        toastUtil.showToast('获取投播资源失败');
        Logger.error(TAG, 'can not get source');
        this.castController?.endCasting();
        this.castStatusModel.isCasting = false;
      }
    } else if ((currentDevice.castCategory === avSession.AVCastCategory.CATEGORY_REMOTE &&
      connectState === avSession.ConnectionState.STATE_DISCONNECTED) ||
      (currentDevice.castCategory === avSession.AVCastCategory.CATEGORY_LOCAL &&
        connectState === avSession.ConnectionState.STATE_CONNECTED)) {
      if (device) {
        this.pause();
        this.castController?.endCasting();
        this.sessionController.unregisterSessionListener();
        this.castStatusModel.isCasting = false;
        // 投屏端断开链接关闭投屏文件
        if (this.curFile) {
          fs.closeSync(this.curFile);
          this.curFile = undefined;
        }
      }
    }
  };

  public static getInstance(): CastService {
    if (!CastService.instance) {
      CastService.instance = new CastService();
    }
    return CastService.instance;
  }

  // 使用UIAbilityContext初始化
  public async init(context: common.UIAbilityContext) {
    this.context = context;
    await this.sessionController.initAvSession(context);
    await this.initAvCastController();
  }

  public deinit() {
    this.sessionController.release();
  }

  getAvSessionController(): AvSessionController {
    return this.sessionController;
  }

  getAvCastController(): AvCastController | undefined {
    return this.castController;
  }

  public registerSessionListener(listener: CastSessionListener): void {
    this.sessionListener = listener;
    if (this.sessionListener && this.castController) {
      this.castController.registerCastListener(this.sessionListener);
    }
  }

  public unregisterSessionListener(): void {
    this.sessionListener = undefined;
  }

  /* 投播：播放
   * 1.设置AVSession状态
   * 2.发送AVCast播放命令
   */
  public async play(position?: avSession.PlaybackPosition, duration?: number) {
    if (this.sessionController) {
      let playbackState: avSession.AVPlaybackState = {
        state: avSession.PlaybackState.PLAYBACK_STATE_PLAY,
      };
      this.sessionController.setAvSessionPlayState(playbackState);
      if (this.castController && this.castStatusModel.isCasting) {
        await this.castController.play();
        Logger.debug(TAG, 'cast play');
      }
    }
  }

  /* 投播：暂停
   * 1.设置AVSession状态
   * 2.发送AVCast 暂停命令
   */
  public pause(position?: avSession.PlaybackPosition, duration?: number) {
    if (this.sessionController) {
      let playbackState: avSession.AVPlaybackState = {
        state: this.castStatusModel.isCastPlaying ? avSession.PlaybackState.PLAYBACK_STATE_PLAY :
          avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      };
      this.sessionController.setAvSessionPlayState(playbackState);
      if (this.castController) {
        this.castController.pause();
      }

    }
  }

  /* 投播：seek
   * 1.设置AVSession状态
   * 2.发送AVCast seek命令
   */
  public seek(time: number) {
    if (this.sessionController) {
      let playbackState: avSession.AVPlaybackState = {
        state: this.castStatusModel.isCastPlaying ? avSession.PlaybackState.PLAYBACK_STATE_PLAY :
          avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
        position: {
          elapsedTime: this.castStatusModel.castCurrentTime * 1000,
          updateTime: new Date().getTime(),
        },
        duration: this.castStatusModel.castDuration,
      };
      this.sessionController.setAvSessionPlayState(playbackState);
      if (this.castController && this.castStatusModel.isCasting) {
        this.castController.seekCasting(time);
      }
    }
  }

  // 投播：设置音量
  public setVolume(value: number) {
    this.castController?.setVolume(value);
  }

  public setVolumeByOffset(value: number) {
    this.castController?.setVolumeByOffset(value);
  }

  // 播控中心：设置播控信息，更换播放内容时必须设置
  public async setAVMetadata(videoData: MediaData, duration?: number) {
    let preSource = this.curSource;
    this.curSource = videoData;
    if (duration !== undefined) {
      this.castStatusModel.castDuration = duration;
    }
    if (!this.sessionController.getAvSession()) {
      // 重新初始化
      await this.reInit();
    }
    if (this.sessionController) {
      await this.sessionController.setAVMetadata(videoData, duration);
    }
    if (this.castController && this.castStatusModel.isCasting) {
      if (preSource !== this.curSource) {
        await this.changeCasting();
      }
    }
  }

  // 停止远程播放
  public endCasting() {
    if (this.castController) {
      this.castController.endCasting();
      this.castStatusModel.isCasting = false;
      this.sessionListener?.onEndCasting();
    }
  }


  public wifiError() {

  }

  private async reInit() {
    await this.sessionController.initAvSession(this.context!!);
    await this.initAvCastController();
    this.castController = undefined;
  }


  private async initAvCastController() {
    if (AvSessionController.getInstance().getAvSession()) {
      AvSessionController.getInstance().getAvSession()?.on('play', this.sessionPlayCallback);
      AvSessionController.getInstance().getAvSession()?.on('pause', this.sessionPauseCallback);
      AvSessionController.getInstance().getAvSession()?.on('playNext', this.sessionPlayNextCallback);
      AvSessionController.getInstance().getAvSession()?.on('playPrevious', this.sessionPlayPreviousCallback);
      AvSessionController.getInstance().getAvSession()?.on('fastForward', this.sessionFastForwardCallback);
      AvSessionController.getInstance().getAvSession()?.on('rewind', this.sessionRewindCallback);
      AvSessionController.getInstance().getAvSession()?.on('seek', this.sessionSeekCallback);
      AvSessionController.getInstance().getAvSession()?.on('outputDeviceChange', this.sessionOutputDeviceChange);
      AvSessionController.getInstance().getAvSession()?.activate();
    }
  }

  private async changeCasting(): Promise<boolean> {
    if (!this.curSource) {
      return false;
    }
    // 切换投播资源时关闭上一个资源
    if (this.curFile) {
      fs.closeSync(this.curFile);
    }
    // 打开本地资源
    this.curFile = fs.openSync(this.curSource.url, fs.OpenMode.READ_ONLY);
    let castItem: avSession.AVQueueItem = {
      itemId: this.curSource.sortId,
      description: {
        // todo 修改为自己的应用名称
        appName: '本地影音投屏',
        assetId: this.curSource.id,
        title: this.curSource.name,
        mediaType: this.curSource.mediaType === MediaType.VIDEO ? 'VIDEO' : 'AUDIO',
        mediaImage: this.curSource.head,
        fdSrc: {
          fd: this.curFile.fd,
        },
      },
    };
    if (castItem) {
      await this.castController?.startCasting(castItem);
      this.castStatusModel.isCasting = true;
    } else {
      Logger.error(TAG, `no cast item`);
      this.castController?.endCasting();
      this.castStatusModel.isCasting = false;
      this.sessionListener?.onEndCasting();
    }
    return true;
  }

  private sessionPlayCallback = (): void => {
    console.log('播放');
    this.sessionListener?.onPlay();
  };
  private sessionPauseCallback = (): void => {
    console.log('暂停');
    this.sessionListener?.onPause();
  };
  private sessionPlayNextCallback = (): void => {
    console.log('下一级');
    this.sessionListener?.onPlayNext();
  };
  private sessionPlayPreviousCallback = (): void => {
    console.log('上一级');
    this.sessionListener?.onPlayPre();
  };
  private sessionFastForwardCallback = (time?: number) => {
    if (!time) {
      return;
    }
    this.sessionListener?.onFastForward(time);
  };
  private sessionRewindCallback = (time?: number) => {
    if (!time) {
      return;
    }
    this.sessionListener?.onRewind(time);
  };
  private sessionSeekCallback = (seekTime: number) => {
    this.sessionListener?.onSeek(seekTime);
  };
}

