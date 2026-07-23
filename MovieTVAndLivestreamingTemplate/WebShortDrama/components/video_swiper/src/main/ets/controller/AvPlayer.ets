import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { VideoPlayData } from '../datasource/VideoPlayDataSource';
import { secondToTime } from '../utils/CommonUtils';
import { AVPlayerState } from '../constant/AVPlayerState';
import { AVPlayerListener } from './AvPlayerListener';
import { MediaSource } from '../constant/MediaSource';
import { Constants as Const } from '../constant/Contants'
import { AVPlayerConstants, CommonConstants, ViewConstants } from '../common/CommonConstants';
import { CustomConfigs } from '../common/CustomConfigs';
import { VideoInfoModel } from '../common/VideoInfoModel';

interface PlayerParam {
  videoInfo: VideoPlayData;
}

interface PlayCommand {
  func: Function;
  name?: string;
}

interface CheckPlayCommandResult {
  ignore: boolean;
  indexToRemove: number;
}

const TAG = '[AvPlayer111]'
const DOMAIN = 0x0000

@ObservedV2
export class AvPlayer {
  @Trace videoHeight: number = Const.SURFACE_HEIGHT;
  @Trace videoWidth: number = Const.SURFACE_WIDTH;
  @Trace isPlaying: boolean = false;
  @Trace isReady: boolean = false;
  @Trace currentTime: number = 0;
  @Trace durationStringTime: string = '00:00';
  @Trace currentStringTime: string = '00:00';
  @Trace duration: number = 0;
  @Trace durationTime: number = 0;
  @Trace firstFrame: boolean = false;
  @Trace isBufferUpdate: boolean = false;
  @Trace speed: number = 1;
  @Trace startPlay: boolean = false;
  @Trace isCompleted: boolean = false;
  listeners: Set<AVPlayerListener> = new Set
  @Trace state: AVPlayerState = AVPlayerState.IDLE
  private surfaceID: string = ''; // surfaceID用于播放画面显示，具体的值需要通过Xcomponent接口获取，相关文档链接见上面Xcomponent创建方法
  avPlayer?: media.AVPlayer;
  prepared: boolean = false;
  commands: PlayCommand[] = [];
  videoInfo?: MediaSource;
  id: string = ''
  public stateChangeCallbacks: Map<string, Array<(state: string) => void>> = new Map();
  public timeUpdateCallbacks: Map<string, Array<(time: number) => void>> = new Map();
  public avPlayerCallback: Map<string, Array<(...arg: string[] | number[]) => void>> = new Map();
  private playbackCallbackInterval: number = 0;
  private netCheckInterval: number = 0;
  private weakNetCheckInterval: number = 0;
  private bitrateUpCheckInterval: number = 0;
  private isSeeking: boolean = false;
  private isResumePlay: boolean = false;
  private isWeakNet: boolean = false;
  private isBitrateUpAvailable: boolean = true;
  private currentBitrateIndex: number | undefined = undefined;
  private maxBufferValueList: Array<number> = [];
  private recentDownRates: Array<number> = [];
  private downloadRate: number = 0;
  private maxDownloadRate: number = 0;
  private source: media.MediaSource | undefined = undefined;
  private strategy: media.PlaybackStrategy | undefined = undefined;
  @Trace bitrateList: Array<number> = [];
  @Trace currentResolutionIndex: number | undefined = undefined;
  @Trace videoNetInfo: VideoInfoModel = new VideoInfoModel();
  ctx: UIContext = AppStorage.get('UIContext')!;

  setListener(listener: AVPlayerListener) {
    this.listeners.add(listener)
  }

  unsetListener(listener: AVPlayerListener) {
    this.listeners.delete(listener)
  }

  clearListener() {
    this.listeners.clear()
  }

  // 状态变化事件监听
  onStateChange(key: string, callback: (state: string) => void): void {
    if (this.stateChangeCallbacks.has(key)) {
      this.stateChangeCallbacks.get(key)?.push(callback);
    } else {
      this.stateChangeCallbacks.set(key, [callback]);
    }
  }

  // 时间更新事件监听
  onTimeUpdate(key: string, callback: (time: number) => void): void {
    if (this.timeUpdateCallbacks.has(key)) {
      this.timeUpdateCallbacks.get(key)?.push(callback);
    } else {
      this.timeUpdateCallbacks.set(key, [callback]);
    }
  }

  constructor() {
  }

  setSurfaceID(surfaceId: string) {
    hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}].setSurfaceID : ${surfaceId}`);
    this.surfaceID = surfaceId;
    this.commands.push({
      func: () => {
        hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}].surfaceId(${surfaceId})`);
        this.avPlayer!!.surfaceId = surfaceId;
      }
    });
    this.schedule();
  }

  getSurfaceId() {
    return this.surfaceID
  }

  setIsPlaying(isPlaying: boolean) {
    this.isPlaying = isPlaying
  }

  public isReleased(): boolean {
    return this.state === AVPlayerState.RELEASED
  }

  public isError(): boolean {
    return this.state === AVPlayerState.ERROR
  }

  private isDownloading() {
    return this.downloadRate !== 0;
  }

  private findTargetBitrate() {
    const bitrateListLength = this.bitrateList.length;
    const downloadBitrate = this.downloadRate;
    if (downloadBitrate > this.bitrateList[bitrateListLength - 1]) {
      return this.bitrateList[bitrateListLength - 1];
    } else {
      const targetBitrate = this.bitrateList.find((_value, index) =>
      index < bitrateListLength - 1 &&
        this.bitrateList[index] <= downloadBitrate &&
        this.bitrateList[index + 1] > downloadBitrate
      ) ?? this.bitrateList[0];
      return targetBitrate;
    }
  }

  private autoReduceBitrate(targetBitrate: number) {
    this.ctx.getPromptAction()
      .showToast({ message: '当前网络环境差，将自动降低分辨率', duration: ViewConstants.TOAST_TIME_MS });
    this.setBitrate(targetBitrate);
  }

  private autoIncreaseBitrate(targetBitrate: number) {
    this.ctx.getPromptAction()
      .showToast({ message: '当前网络较为稳定，将自动提升分辨率', duration: ViewConstants.TOAST_TIME_MS });
    this.setBitrate(targetBitrate);
  }

  private isNewResolutionCaching() {
    return this.currentBitrateIndex !== this.currentResolutionIndex;
  }

  public clearAllCallback() {
    if (!this.avPlayer) {
      return;
    }
    clearInterval(this.playbackCallbackInterval);
    clearInterval(this.netCheckInterval);
    clearInterval(this.weakNetCheckInterval);
    this.avPlayer.off('availableBitrates');
    this.avPlayer.off('bitrateDone');
    this.avPlayer.off('videoSizeChange');
    this.avPlayer.off('bufferingUpdate');
    this.avPlayer.off('seekDone');
    this.avPlayer.off('timeUpdate');
    this.avPlayer.off('error');
    this.avPlayer.off('stateChange');
  }

  private isValidVideoStream() {
    if (this.bitrateList.length === 0 || this.currentBitrateIndex === undefined) {
      console.warn('Bitrate list does not exist, maybe invalid video stream');
      return false;
    } else {
      return true;
    }
  }

  public setBitrate(bitrate: number) {
    if (!this.avPlayer || !this.isValidVideoStream()) {
      return;
    }

    if (this.avPlayer.state === 'prepared' || this.avPlayer.state === 'playing' ||
      this.avPlayer.state === 'paused' || this.avPlayer.state === 'completed') {
      this.avPlayer.setBitrate(bitrate);
    }
  }

  // 注册avplayer回调函数
  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('availableBitrates', (bitrateList: Array<number>) => {
      const bitrateListLength = bitrateList.length;
      if (bitrateListLength === 0) {
        console.warn(`No available bitrate`);
        return;
      }
      this.bitrateList = bitrateList.sort((a, b) => (a - b));
      bitrateList.forEach((element) => {
        this.maxBufferValueList.push(CustomConfigs.PREFERRED_BUFFER_SIZE * CommonConstants.MB_TO_BIT / element *
        CommonConstants.SECOND_TO_MS);
      });

      this.setBitrate(this.bitrateList[bitrateListLength - 1]);
      console.info(`Available bitrates: ${this.bitrateList}`);
    });
    avPlayer.on('bitrateDone', (bitrate: number) => {
      console.info(`AVPlayer set bitrate done, bitrate: ${bitrate}`);
      this.maxDownloadRate = 0;
      this.currentBitrateIndex = this.bitrateList.findIndex((value) => value === bitrate);
    });
    avPlayer.on('videoSizeChange', (width: number, height: number) => {
      console.info(`AVPlayer video size changed, resolution ${width} x ${height}`);

      this.currentBitrateIndex =
        Array.from(CustomConfigs.SELECTABLE_RESOLUTIONS.keys()).findIndex((value) => value === height);

      this.isBitrateUpAvailable = false;
      clearInterval(this.bitrateUpCheckInterval);
      this.bitrateUpCheckInterval = setTimeout(() => {
        this.isBitrateUpAvailable = true;
      }, AVPlayerConstants.BITRATE_UP_CHECK_INTERVAL);

      this.currentResolutionIndex = this.currentBitrateIndex;
      this.ctx.getPromptAction().showToast({ message: '分辨率切换完成', duration: ViewConstants.TOAST_TIME_MS });

    });
    avPlayer.on('bufferingUpdate', (infoType: media.BufferingInfoType, value: number) => {
      this.videoNetInfo.currentBufferInfoType = infoType;
      this.videoNetInfo.currentBufferInfoValue = value;

      if (infoType !== media.BufferingInfoType.CACHED_DURATION || this.isWeakNet || !this.isDownloading() ||
      this.isSeeking || !this.isValidVideoStream()) {
        return;
      }
      if (value < CustomConfigs.CACHED_PERCENT_THRESHOLD * this.maxBufferValueList[this.currentBitrateIndex!]) {
        // Match the bitrate lower than the current download rate; if no match is found, select the lowest bitrate.
        const targetBitrate = this.findTargetBitrate();
        if (targetBitrate < this.bitrateList[this.currentBitrateIndex!]) {
          this.autoReduceBitrate(targetBitrate);
        }
      } else {
        const nextBitrateIndex = this.currentBitrateIndex! + 1;
        if (nextBitrateIndex < this.bitrateList.length && value > this.maxBufferValueList[nextBitrateIndex] &&
          this.maxDownloadRate >= this.bitrateList[nextBitrateIndex] &&
          !this.isNewResolutionCaching() && this.isBitrateUpAvailable) {
          this.autoIncreaseBitrate(this.bitrateList[nextBitrateIndex]);
        }
      }
    });
    // seek操作结果回调函数
    avPlayer.on('seekDone', (seekDoneTime: number) => {
      hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}] seek succeeded, seek time is ${seekDoneTime}`);
    });
    // error回调监听函数,当avPlayer在操作过程中出现错误时调用reset接口触发重置流程
    avPlayer.on('error', (err: BusinessError) => {
      hilog.error(DOMAIN, TAG,
        `AVPlayer[${this.id}] Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      try {
        avPlayer.reset(); // 调用reset重置资源，触发idle状态
      } catch (e) {
        hilog.error(DOMAIN, TAG, `AVPlayer[${this.id}].reset failed: ${e}`);
      }
    });
    // 状态机变化回调函数
    avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}] state idle called.`);
          this.state = AVPlayerState.IDLE
          try {
            avPlayer.release(); // 调用release接口销毁实例对象
          } catch (e) {
            hilog.error(DOMAIN, TAG, `AVPlayer[${this.id}].release failed: ${e}`);
          }
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}] state initialized called.`)
          this.state = AVPlayerState.INITIALIZED
          if (this.surfaceID !== '') {
            avPlayer.surfaceId = this.surfaceID;
          }
          try {
            avPlayer.prepare();
          } catch (e) {
            hilog.error(DOMAIN, TAG, `AVPlayer[${this.id}].prepare failed: ${e}`);
          }
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}] state prepared called.`);
          this.state = AVPlayerState.PREPARED
          // if (this.videoInfo!!.getPlayTime() > 0) {
          //   hilog.info(0x0000, TAG, `AVPlayer state prepared called. need seek.`);
          //   this.seek(this.videoInfo!!.getPlayTime())
          // }
          this.prepared = true;
          this.isReady = true;
          this.duration = avPlayer.duration;
          this.durationTime = Math.floor(this.duration / 1000);
          hilog.info(DOMAIN, TAG, `durationTime:${this.durationTime} duration:${this.duration}`)
          this.durationStringTime = secondToTime(this.durationTime);
          this.schedule();
          break;
        case 'playing': // play成功调用后触发该状态机上报
          hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}] state playing called.`);
          this.state = AVPlayerState.PLAYING
          this.listeners.forEach(item => item.onPlaying?.())
          this.setIsPlaying(true)
          if (!this.startPlay) {
            this.startPlay = true
          }
          break;
        case 'paused': // pause成功调用后触发该状态机上报
          hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}] state paused called.`);
          this.state = AVPlayerState.PAUSED
          this.listeners.forEach(item => item.onPaused?.())
          this.setIsPlaying(false)
          break;
        case 'completed': // 播放结束后触发该状态机上报
          hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}] state completed called.`);
          this.state = AVPlayerState.COMPLETED
          this.setIsPlaying(false)
          this.isCompleted = true;
          this.seek(0)
          this.listeners.forEach(item => item.onEnded?.())
          // avPlayer.stop(); //调用播放结束接口
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}] state stopped called.`);
          this.state = AVPlayerState.STOPPED
          this.setIsPlaying(false)
          break;
        case 'released':
          this.state = AVPlayerState.RELEASED
          this.listeners.forEach(item => item.onDestroyed?.())
          this.prepared = false;
          this.setIsPlaying(false)
          hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}] state released called.`);
          break;
        default:
          hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}] state unknown called.`);
          break;
      }
      let callArr = this.stateChangeCallbacks.get('stateChange');
      callArr?.forEach((item) => {
        item(state);
      });
    });
    avPlayer.on('durationUpdate', (duration: number) => {
      hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}] state durationUpdate success,new duration is :${duration}`);
    });
    avPlayer.on('timeUpdate', (time: number) => {
      this.timeUpdateCallbacks.get('timeUpdate')?.forEach((item) => {
        item(time);
      });
      this.currentStringTime = secondToTime(Math.floor(time / 1000));
      if (time > this.currentTime * 1000) {
        this.currentTime = Math.floor(time / 1000);
      } else {
        this.currentTime = Math.floor(time / 1000);
      }
      this.currentStringTime = secondToTime(Math.floor(time / 1000));

    });
    avPlayer.on('bufferingUpdate', (infoType: media.BufferingInfoType, value: number) => {
      // hilog.debug(DOMAIN, TAG,
      //   `AVPlayer state bufferingUpdate success,and infoType value is:${infoType}, value is : ${value}`);
      if (infoType === media.BufferingInfoType.BUFFERING_START) {
        this.isBufferUpdate = true
      }
      if (infoType === media.BufferingInfoType.BUFFERING_END) {
        this.isBufferUpdate = false
      }
    })
    avPlayer.on('videoSizeChange', (width: number, height: number) => {
      hilog.info(DOMAIN, TAG,
        `AVPlayer[${this.id}] state videoSizeChange success,and width is:${width}, height is : ${height}`);
      this.videoHeight = height;
      this.videoWidth = width;
    })
    avPlayer.on('startRenderFrame', () => {
      this.firstFrame = true;
      hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}] startRenderFrame[${this.id}] called`)
    })
    avPlayer.on('speedDone', (speed: number) => {
      this.avPlayerCallback.get('speedDone')?.forEach((item) => {
        item(speed);
      });
    })
  }

  // 以下示例通过URL设置网络地址来播放直播码流
  async init(videoInfo: MediaSource) {
    try { // 创建avPlayer实例对象
      this.avPlayer = await media.createAVPlayer();
      // 创建状态机变化回调函数
      this.setAVPlayerCallback(this.avPlayer);
      if (typeof videoInfo.url === 'string') {
        this.setAVPlayerCallback(this.avPlayer);
        let mediaSource: media.MediaSource =
          media.createMediaSourceWithUrl(videoInfo.url);
        let playbackStrategy: media.PlaybackStrategy =
          {
            preferredWidth: 1080,
            preferredHeight: 1920,
            preferredBufferDuration: 20,
            preferredHdr: false
          };
        this.avPlayer.setMediaSource(mediaSource, playbackStrategy);
      } else {
        this.avPlayer.fdSrc = videoInfo.url as media.AVFileDescriptor;
      }
      this.videoInfo = videoInfo
      this.id = this.videoInfo.id
    } catch (e) {
    }
  }

  schedule() {
    if (!this.avPlayer) {
      return;
    }
    if (!this.prepared) {
      return;
    }
    if (this.commands.length > 0) {
      let command = this.commands.shift();
      if (command) {
        command.func();
      }
      if (this.commands.length > 0) {
        setTimeout(() => {
          this.schedule();
        });
      }
    }
  }

  private checkCommand(selfName: string, oppositeName: string) {
    let indexToRemove = -1;
    let ignoreThisAction = false;
    let index = this.commands.length - 1;
    while (index >= 0) {
      if (this.commands[index].name === selfName) {
        ignoreThisAction = true;
        break;
      }
      if (this.commands[index].name === oppositeName) {
        indexToRemove = index;
        break;
      }
      index--;
    }

    let result: CheckPlayCommandResult = {
      ignore: ignoreThisAction,
      indexToRemove: indexToRemove,
    };
    return result;
  }

  play() {
    let commandName = 'play';
    let checkResult = this.checkCommand(commandName, 'pause');
    if (checkResult.ignore) {
      hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}] ${commandName} ignored.`);
      this.schedule();
      return;
    }
    if (checkResult.indexToRemove >= 0) {
      let removedCommand = this.commands.splice(checkResult.indexToRemove, 1);
      hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}] ${JSON.stringify(removedCommand)} removed.`);
      return;
    }
    this.commands.push({
      func: () => {
        hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}].play()`);
        try {
          this.avPlayer?.play();
        } catch (e) {
          hilog.error(DOMAIN, TAG, `AVPlayer[${this.id}].play failed: ${e}`);
        }
      }, name: commandName
    });
    this.schedule();
  }

  pause() {
    let commandName = 'pause';
    let checkResult = this.checkCommand(commandName, 'play');
    hilog.info(DOMAIN, TAG, `checkResult:${JSON.stringify(checkResult)}`);
    if (checkResult.ignore) {
      hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}] ${commandName} ignored.`);
      this.schedule();
      return;
    }
    if (checkResult.indexToRemove >= 0) {
      let removedCommand = this.commands.splice(checkResult.indexToRemove, 1);
      hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}] ${JSON.stringify(removedCommand)} removed.`);
      return;
    }
    this.commands.push({
      func: () => {
        hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}].pause()`);
        try {
          this.avPlayer?.pause();
        } catch (e) {
          hilog.error(DOMAIN, TAG, `AVPlayer[${this.id}].pause failed: ${e}`);
        }
      }, name: commandName
    });
    this.schedule();
  }

  stop() {
    let commandName = 'stop';
    let checkResult = this.checkCommand(commandName, 'play');
    hilog.info(DOMAIN, TAG, `checkResult:${JSON.stringify(checkResult)}`);
    if (checkResult.ignore) {
      hilog.info(DOMAIN, TAG, `AVPlayer ${commandName} ignored.`);
      this.schedule();
      return;
    }
    if (checkResult.indexToRemove >= 0) {
      let removedCommand = this.commands.splice(checkResult.indexToRemove, 1);
      hilog.info(DOMAIN, TAG, `AVPlayer ${JSON.stringify(removedCommand)} removed.`);
      return;
    }
    this.commands.push({
      func: () => {
        hilog.info(DOMAIN, TAG, 'AVPlayer.stop()');
        try {
          this.avPlayer?.stop();
        } catch (e) {
          hilog.error(DOMAIN, TAG, `AVPlayer[${this.id}].stop failed: ${e}`);
        }
      }, name: commandName
    });
    this.schedule();
  }

  release() {
    this.commands.push({
      func: () => {
        hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}].release()`);
        try {
          this.avPlayer?.release();
        } catch (e) {
          hilog.error(DOMAIN, TAG, `AVPlayer[${this.id}].release failed: ${e}`);
        }
      }
    });
    this.schedule();
  }

  seek(time: number) {
    this.commands.push({
      func: () => {
        hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}].seek(${time})`);
        this.avPlayer?.seek(time);
      }
    });
    this.schedule();
  }

  setVolume(volume: number) {
    this.commands.push({
      func: () => {
        hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}].setVolume(${volume})`);
        this.avPlayer?.setVolume(volume);
      }
    });
    this.schedule();
  }

  setPlaybackRate(playbackRate: number) {
    let speed = media.PlaybackSpeed.SPEED_FORWARD_1_00_X;
    let delta = 0.05;
    playbackRate += delta;
    if (playbackRate < 1) {
      speed = media.PlaybackSpeed.SPEED_FORWARD_0_75_X;
    } else if (playbackRate < 1.25) {
      speed = media.PlaybackSpeed.SPEED_FORWARD_1_00_X;
    } else if (playbackRate < 1.5) {
      speed = media.PlaybackSpeed.SPEED_FORWARD_1_25_X;
    } else if (playbackRate < 2) {
      speed = media.PlaybackSpeed.SPEED_FORWARD_1_75_X;
    } else {
      speed = media.PlaybackSpeed.SPEED_FORWARD_2_00_X;
    }
    this.commands.push({
      func: () => {
        hilog.info(DOMAIN, TAG, `AVPlayer[${this.id}].setSpeed(${speed})`);
        this.avPlayer?.setSpeed(speed);
      }
    });
    this.schedule();
  }
}