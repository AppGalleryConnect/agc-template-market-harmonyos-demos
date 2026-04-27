import { common } from '@kit.AbilityKit';
import { AppStorageV2, display, window } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { audio } from '@kit.AudioKit';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition';
import { Constants } from '../constants/Constants';
import { AVPlayerManager } from '../controller/AVPlayerManager';
import { AVPlayerController } from '../controller/AVPlayerController';
import { VideoSessionController } from '../controller/VideoSessionController';
import { VideoCastController } from '../controller/VideoCastController';
import { VideoNetworkModel } from '../models/VideoNetworkModel';
import { GlobalConfigModel } from '../models/GlobalConfigModel';
import { BreakpointModel } from '../models/BreakpointModel';
import { PiPWindowModel } from '../models/PiPWindowModel';
import {
  closeFileSync,
  handleSandboxVideoUrl,
  isDisplayModeFull,
  registerAVPlayerCallback,
  setOrientation,
} from '../utils/Util';
import { AVPlayerState, PageNameEnum, VideoPlayerData } from '../type/Index';
import { Logger } from '../utils/Logger';

const TAG = '[VideoPlayerModel]'

@ObservedV2
export class VideoPlayerModel {
  @Trace xComponentWidth: Length = Constants.FULL_PERCENT;
  @Trace xComponentHeight: Length = Constants.VIDEO_CARD_HEIGHT;
  // 视频默认宽高
  @Trace videoWidth: Length = Constants.VIDEO_CARD_WIDTH;
  @Trace videoHeight: Length = Constants.VIDEO_CARD_HEIGHT;
  // 视频窗口ID
  @Trace surfaceId: string = ''
  @Trace showCover: boolean = true;
  @Trace isBuffering: boolean = false;
  @Trace isPause: boolean = false;
  @Trace isCompleted: boolean = false;
  @Trace isHideSlide: boolean = false;
  // 是否是通过点击全屏播放按钮跳转到横屏页面
  @Trace isClickFullScreenBtn: boolean = false;
  @Trace videoFileFD: number = 0;
  @Trace breakpointModel: BreakpointModel = new BreakpointModel();
  @Trace globalConfigModel: GlobalConfigModel = AppStorageV2.connect(GlobalConfigModel, () => new GlobalConfigModel())!;
  @Trace pipWindowModel: PiPWindowModel = AppStorageV2.connect(PiPWindowModel, () => new PiPWindowModel())!;
  // AVPlayer管理器
  avPlayerManager: AVPlayerManager = AVPlayerManager.getInstance()
  // 播放器id
  playerId: string = ''
  // videoIndex
  index: number = 0
  // AVPlayer控制器
  avPlayerController: AVPlayerController = new AVPlayerController();
  // 播控中心控制器
  avSessionController: VideoSessionController = VideoSessionController.instance;
  // 投屏控制器
  videoCastController: VideoCastController | null = null;
  network?: VideoNetworkModel
  uiContext?: UIContext
  context?: Context
  pathStack: NavPathStack = new NavPathStack()
  windowClass?: window.Window
  // 视频数据
  private videoData?: VideoPlayerData
  // 播放器状态监听
  private playerStateListeners: Array<(state: string) => void> = [];
  private preparedListeners: Array<() => void> = []
  private initializedListeners: Array<(avPlayer: media.AVPlayer) => void> = []
  private playingListeners: Array<() => void> = []
  private completedListeners: Array<() => void> = []
  private errorListeners: Array<() => void> = []
  private bufferingUpdateListeners: Array<(infoType: media.BufferingInfoType) => void> = []
  private videoSizeChangedListeners: Array<() => void> = []
  private startRendFrameListeners: Array<() => void> = []
  private timeUpdateListeners: Array<(timeMs: number) => void> = []

  constructor(uiContext: UIContext, index: number = 0) {
    try {
      this.uiContext = uiContext;
      this.context = this.uiContext.getHostContext();
      this.windowClass = (uiContext.getHostContext() as common.UIAbilityContext).windowStage.getMainWindowSync();
      this.index = index
    } catch (e) {
      Logger.error(TAG, 'constructor getMainWindowSync fail, error: ' + JSON.stringify(e));
    }
  }

  setPathStack(pathStack: NavPathStack) {
    this.pathStack = pathStack;
  }

  setSurfaceId(surfaceId: string) {
    this.surfaceId = surfaceId
  }

  initPlayerListener(avPlayer: media.AVPlayer) {
    // 设置状态监听
    this.onStateChangeListener(avPlayer);
    // 设置播放器事件回调
    this.setAVPlayerCallback(avPlayer);
    // 设置音频事件回调
    this.setAVPlayerInterruptCallback(avPlayer)
  }

  // 播控中心监听avplayer事件
  onAVPlayerChangeBySession() {
    this.onPlayerStateListener(this.avSessionController.setState);
    this.onTimeUpdateListener(this.avSessionController.setProgress);
  }

  // 播控中心取消监听avplayer事件
  offAVPlayerChangeBySession() {
    this.popPlayerStateListener(this.avSessionController.setState);
    this.popTimeUpdateListener(this.avSessionController.setProgress);
  }

  setVideoData(data: VideoPlayerData) {
    this.videoData = data
  }

  setDataSource() {
    if (this.videoData!.getVideoUrl().startsWith('http')) {
      this.avPlayerController!.getAVPlayer()!.url = this.videoData!.getVideoUrl()
    } else {
      this.videoFileFD = handleSandboxVideoUrl(this.videoData!.getVideoUrl())
      this.avPlayerController!.getAVPlayer()!.url = 'fd://' + this.videoFileFD
    }
  }

  getVideData(): VideoPlayerData {
    return this.videoData!
  }

  // 设置窗口旋转
  async handleOrientation() {
    try {
      const isFullMode = isDisplayModeFull();
      const displayClass = display.getDefaultDisplaySync();
      const orientation = displayClass.orientation;
      this.breakpointModel.orientationBefore = orientation;
      if (orientation === display.Orientation.LANDSCAPE) {
        await setOrientation(this.uiContext, window.Orientation.USER_ROTATION_LANDSCAPE_INVERTED)
      } else if (orientation === display.Orientation.LANDSCAPE_INVERTED) {
        await setOrientation(this.uiContext, window.Orientation.USER_ROTATION_LANDSCAPE)
      } else if (orientation === display.Orientation.PORTRAIT) {
        // 双折叠展开态不旋转
        if (isFullMode) {
          await setOrientation(this.uiContext, window.Orientation.AUTO_ROTATION)
        } else {
          await setOrientation(this.uiContext, window.Orientation.USER_ROTATION_LANDSCAPE)
        }
      } else if (orientation === display.Orientation.PORTRAIT_INVERTED) {
        // 双折叠展开态不旋转
        if (isFullMode) {
          await setOrientation(this.uiContext, window.Orientation.AUTO_ROTATION)
        } else {
          await setOrientation(this.uiContext, window.Orientation.USER_ROTATION_LANDSCAPE_INVERTED)
        }
      }
    } catch (e) {
      Logger.error(TAG, 'handleOrientation fail, error: ' + JSON.stringify(e));
    }
  }

  // 跳转到横屏页
  pushToLandscapePage(
    param: Record<string, Object | AVPlayerController | BreakpointModel | LongTakeTransitionParam | undefined>,
    cardId: string,
  ) {
    const longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(this.uiContext!, cardId, 9);
    if (longTakeTransitionParam) {
      param.longTakeTransitionParam = longTakeTransitionParam;
    }
    this.pathStack?.pushPathByName(PageNameEnum.VIDEO_LANDSCAPE_PAGE, param, () => {
      this.isClickFullScreenBtn = false;
    });
  }

  onPlayerStateListener(listener: (state: string) => void) {
    this.playerStateListeners.push(listener)
  }

  popPlayerStateListener(listener: (state: string) => void) {
    const index = this.playerStateListeners.findIndex(v => v === listener);
    if (index !== -1) {
      this.playerStateListeners.splice(index, 1);
    }
  }

  onPreparedListener(listener: () => void) {
    this.preparedListeners.push(listener)
  }

  onInitializedListener(listener: (avPlayer: media.AVPlayer) => void) {
    this.initializedListeners.push(listener)
  }

  onPlayingListener(listener: () => void) {
    this.playingListeners.push(listener)
  }

  onCompletionListener(listener: () => void) {
    this.completedListeners.push(listener)
  }

  onErrorListener(listener: () => void) {
    this.errorListeners.push(listener)
  }

  onBuffingUpdateListener(listener: (infoType: media.BufferingInfoType) => void) {
    this.bufferingUpdateListeners.push(listener)
  }

  onVideoSizeChangedListener(listener: () => void) {
    this.videoSizeChangedListeners.push(listener)
  }

  onStartRenderFrameListener(listener: () => void) {
    this.startRendFrameListeners.push(listener)
  }

  onTimeUpdateListener(listener: (timeMs: number) => void) {
    this.timeUpdateListeners.push(listener)
  }

  popTimeUpdateListener(listener: (timeMs: number) => void) {
    const index = this.timeUpdateListeners.findIndex(v => v === listener);
    if (index !== -1) {
      this.timeUpdateListeners.splice(index, 1);
    }
  }


  onStateChangeListener(avPlayer: media.AVPlayer) {
    this.avPlayerController.avPlayer!.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      this.playerStateListeners.forEach((callback) => {
        callback(state);
      })
      try {
        switch (state) {
          case 'idle':
            Logger.debug(TAG, 'player state is idle');
            this.showCover = true;
            break;
          case 'initialized':
            Logger.debug(TAG, 'player state is initialized');
            this.showCover = true;
            this.avPlayerController.avPlayer!.surfaceId = this.surfaceId;
            this.initializedListeners.forEach((callback) => {
              callback(avPlayer)
            })
            await this.avPlayerController.avPlayer!.prepare();
            break;
          case 'prepared':
            Logger.debug(TAG, 'player state is prepared index: ' + this.index);
            this.showCover = true;
            this.isCompleted = false;
            this.avPlayerController.avPlayer!.loop = false;
            this.avPlayerController.avPlayer!.audioInterruptMode = audio.InterruptMode.INDEPENDENT_MODE;
            this.preparedListeners.forEach((callback) => {
              Logger.debug(TAG, 'prepared preparedListeners callback index: ' + this.index)
              callback()
            })
            break;
          case 'playing':
            Logger.debug(TAG, 'player state is playing');
            this.isPause = false;
            this.showCover = false;
            this.isBuffering = false;
            this.isCompleted = false;
            // mock数据中的duration不准确，需要以avplayer.duration为准
            this.videoData?.setVideoDuration(this.avPlayerController.avPlayer!.duration);
            // 隐藏进度条的场景
            if (this.isHideSlide) {
              this.videoData?.setVideoDuration(0);
            }
            this.avSessionController.setAVMetadata(this.videoData!);
            this.playingListeners.forEach((callback) => {
              callback()
            })
            await this.windowClass?.setWindowKeepScreenOn(true);
            break;
          case 'paused':
            Logger.debug(TAG, 'player state is paused');
            this.isPause = true;
            this.showCover = false;
            this.isCompleted = false;
            await this.windowClass?.setWindowKeepScreenOn(false);
            break;
          case 'stopped':
            Logger.debug(TAG, 'player state is stopped');
            this.showCover = false;
            this.isCompleted = false;
            await this.windowClass?.setWindowKeepScreenOn(false);
            break;
          case 'completed':
            Logger.debug(TAG, 'player state is completed');
            this.showCover = false;
            this.isCompleted = true;
            this.completedListeners.forEach((callback) => {
              callback()
            })
            break;
          case 'released':
            Logger.debug(TAG, 'player state is released');
            this.showCover = false;
            this.isCompleted = false;
            break;
          case 'error':
            Logger.debug(TAG, 'player state is error');
            this.showCover = false;
            this.isCompleted = false;
            this.errorListeners.forEach((callback) => {
              callback()
            })
            await this.avPlayerController.avPlayer!.reset();
            break;
          default:
            break;
        }
      } catch (e) {
        Logger.error(TAG, 'onStateChangeListener fail, error: ' + JSON.stringify(e));
      }

      const callArr = this.avPlayerController.avPlayerCallback.get('stateChange');
      callArr?.forEach((item) => {
        item(state, reason);
      });
    })
  }

  // 播放器监听
  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('videoSizeChange', (width: number, height: number) => {
      this.videoWidth = width;
      this.videoHeight = height;
      this.videoSizeChangedListeners.forEach((callback) => {
        callback()
      })

      const callArr = this.avPlayerController.avPlayerCallback.get('videoSizeChange');
      callArr?.forEach((item) => {
        item(width, height);
      });
    });

    avPlayer.on('timeUpdate', (time: number) => {
      this.timeUpdateListeners.forEach((callback) => {
        callback(time)
      });
      const callArr = this.avPlayerController.avPlayerCallback.get('timeUpdate');
      callArr?.forEach((item) => {
        item(time);
      });
    })

    registerAVPlayerCallback(avPlayer, this.avPlayerController.avPlayerCallback)

    this.avPlayerController.onEvent('bufferingUpdate', (infoType: media.BufferingInfoType, _value: number) => {
      this.bufferingUpdateListeners.forEach((callback) => {
        callback(infoType)
      })
    });
    this.avPlayerController.onEvent('startRenderFrame', () => {
      this.startRendFrameListeners.forEach((callback) => {
        callback()
      })
    });
  }

  setAVPlayerInterruptCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('audioInterrupt', async (info: audio.InterruptEvent) => {
      try {
        if (info.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
          switch (info.hintType) {
            case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
              this.isPause = true;
              await this.avPlayerController?.avPlayer?.pause();
              break;
            case audio.InterruptHint.INTERRUPT_HINT_STOP:
              this.isPause = true;
              await this.avPlayerController?.avPlayer?.pause();
              break;
            case audio.InterruptHint.INTERRUPT_HINT_DUCK:
              break;
            case audio.InterruptHint.INTERRUPT_HINT_UNDUCK:
              break;
            default:
              break;
          }
        } else {
          switch (info.hintType) {
            case audio.InterruptHint.INTERRUPT_HINT_RESUME:
              await this.avPlayerController?.avPlayer?.play();
              break;
            default:
              break;
          }
        }
      } catch (e) {
        Logger.error(TAG, 'setAVPlayerInterruptCallback fail, error: ' + JSON.stringify(e));
      }

      const callArr = this.avPlayerController.avPlayerCallback.get('audioInterrupt');
      callArr?.forEach((item) => {
        item(info);
      });
    });
  }

  // 计算尺寸
  adaptiveVideoSize() {
  }

  async releaseAVPlayer() {
    try {
      closeFileSync(this.videoFileFD);
      if (this.avPlayerController?.avPlayer) {
        Logger.debug(TAG, 'releaseAVPlayer start');
        // 停止播放音视频资源，只能在prepared/playing/paused/completed状态调用。
        if ([
          AVPlayerState.PREPARED,
          AVPlayerState.PLAYING,
          AVPlayerState.PAUSED,
          AVPlayerState.COMPLETED,
        ].includes(this.avPlayerController.avPlayer.state as AVPlayerState)) {
          await this.avPlayerController.avPlayer.stop();
        }
        // 销毁播放资源，除released状态外，均可以调用。
        if (this.avPlayerController.avPlayer.state !== AVPlayerState.RELEASED) {
          Logger.debug(TAG, 'release the avplayer')
          await this.avPlayerController.avPlayer.release();
        }
        this.avPlayerController.avPlayer.off('stateChange');
        this.avPlayerController.avPlayer.off('videoSizeChange');
        this.avPlayerController.avPlayer.off('timeUpdate');
        this.avPlayerController.avPlayer.off('error');
        this.avPlayerController.avPlayer.off('durationUpdate');
        this.avPlayerController.avPlayer.off('seekDone');
        this.avPlayerController.avPlayer.off('speedDone');
        this.avPlayerController.avPlayer.off('bitrateDone');
        this.avPlayerController.avPlayer.off('availableBitrates');
        this.avPlayerController.avPlayer.off('volumeChange');
        this.avPlayerController.avPlayer.off('endOfStream');
        this.avPlayerController.avPlayer.off('bufferingUpdate');
        this.avPlayerController.avPlayer.off('startRenderFrame');
        this.avPlayerController.avPlayer.off('audioInterrupt');
        this.avPlayerController.avPlayer.off('mediaKeySystemInfoUpdate');
        this.avPlayerController.avPlayer.off('audioOutputDeviceChangeWithInfo');
        this.avPlayerController.avPlayer.off('subtitleUpdate');
        this.avPlayerController.avPlayer.off('trackChange');
        this.avPlayerController.avPlayer.off('trackInfoUpdate');
        this.avPlayerController.avPlayer = undefined;
        this.avPlayerController!.avPlayerCallback = new Map();
        this.avPlayerManager?.deleteAVPlayerController(this.playerId);
      }
    } catch (e) {
      Logger.error(TAG, 'releaseAVPlayer fail, error: ' + JSON.stringify(e));
    }
  }

  // 处理页面销毁
  async handlerDisappear() {
    try {
      this.offAVPlayerChangeBySession();
      this.avSessionController.destroy(this.context!);
      this.videoCastController?.offPlaybackEvent();
      this.releaseAVPlayer();
    } catch (e) {
      Logger.error(TAG, 'handlerDisappear fail, error: ' + JSON.stringify(e));
    }
  }
}