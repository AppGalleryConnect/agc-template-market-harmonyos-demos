import { media } from '@kit.MediaKit';
import { audio } from '@kit.AudioKit';
import { componentUtils, PiPWindow, window } from '@kit.ArkUI';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { pauseVideo, playVideo, releaseVideo } from '../utils/CommonUtils';
import { Constants as Const } from '../constant/Contants'
import { PlayController, PlayerLayoutSize } from '../controller/PlayController';
import { VideoPlayData } from '../datasource/VideoPlayDataSource';
import { util } from '@kit.ArkTS';
import { PlaySession } from '../controller/PlaySession';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AvSessionController } from '../controller/AvSessionController';
import { preferences } from '@kit.ArkData';

const TAG = '[VideoPlayer]';

export enum VideoFit {
  Contain,
  Cover,
  CoverH
}


/**
 * 功能描述：
 * 1. 展示视频，播放组件，控制条
 * 参考最佳实践[在线短视频流畅切换](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-smooth-switching)。
 *
 */
@Preview
@ComponentV2
export struct VideoPlayView {
  @Param firstFlag: boolean = false;
  @Event firstLoaded: () => void = () => {
  };
  @Event freshLoaded: () => void = () => {
  };
  // swipe中当前的播放索引
  @Param curIndex: number = -1;
  @Param isPageShow: boolean = false;
  @Param contentBuilder: WrappedBuilder<[VideoPlayData, PlayController, PlaySession]> | undefined = undefined;
  @Param previewUri: ResourceStr = '';
  @Param @Require videoData: VideoPlayData
  @Param @Require playController: PlayController;
  @Local xComponentWidth: number | string = '100%';
  @Local xComponentHeight: number | string = '100%';
  videoFit: VideoFit = VideoFit.CoverH
  @Consumer('pathInfo') pathStack: NavPathStack = new NavPathStack()
  @Consumer('navId') navId: string = '';

  @Monitor('curIndex', 'isPageShow', 'onFoldStatusChange')
  onIndexChanged(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      console.log(`${path} change from ${monitor.value(path)?.before} to ${monitor.value(path)?.now}`);
      switch (path) {
        case 'curIndex':
          this.onIndexChange();
        case 'isPageShow':
          this.onPageShowWatch()
        case 'onFoldStatusChange':
          this.onFoldStatusChange()
      }
    })
  }

  // 本视频索引
  @Param @Once index: number = 0;
  @Local layoutSize: PlayerLayoutSize = new PlayerLayoutSize()
  @Local aspRatio: number = 0.5;
  @Local isPlaying: boolean = false;
  @Local trackThicknessSize: number = Const.TRACK_SIZE_MIN;
  @Local preparedFlag: boolean = false;
  @Local isLoading: boolean = true;
  private surfaceID: string = '';
  private xComponentController = new XComponentController();
  private avPlayer: media.AVPlayer | undefined = undefined;
  private videoHeight: number = Const.SURFACE_HEIGHT;
  private videoWidth: number = Const.SURFACE_WIDTH;
  componentId: string = 'player_' + util.generateRandomUUID(true)
  private xComponentId: string = 'XComponentId' + this.componentId;
  playerSession: PlaySession = new PlaySession()
  private pipController?: PiPWindow.PiPController = undefined;
  private avSessionController: AvSessionController = AvSessionController.getInstance();
  private dataPreferences: preferences.Preferences | null = null;
  private uiContext: UIContext = this.getUIContext();
  aboutToDisappear(): void {
    hilog.info(0x0000, TAG,
      `aboutToDisappear curIndex: ${this.curIndex}, index: ${this.index}, isPageShow: ${this.isPageShow}.`);
    releaseVideo(this.avPlayer, this.curIndex, this.index);
    this.avSessionController?.unregisterSessionListener();
  }

  aboutToAppear(): void {
    this.layoutSize = this.playerSession.playLayout
    this.playerSession.onStartPip = () => {
      this.startPip()
    }
    PlayController.onStopPip = () => {
      this.stopPip()
    }
    this.backEmitter()
    this.foreEmitter()
    hilog.info(0x0000, TAG,
      `aboutToAppear playerWidth: ${this.layoutSize.playerWidth}, playerHeight: ${this.layoutSize.playerHeight}.`);
  }

  onPageShowWatch() {
    if (!this.isPageShow && this.curIndex === this.index) {
      pauseVideo(this.avPlayer, this.curIndex, this.index);
      this.isPlaying = false;
      this.trackThicknessSize = Const.TRACK_SIZE_MIN;
    }
  }

  build() {
    Stack() {
      Stack({ alignContent: Alignment.Center }) {
        Stack({ alignContent: Alignment.Center }) {
          Stack() {
            XComponent({
              id: this.xComponentId,
              type: XComponentType.SURFACE,
              controller: this.xComponentController
            })
              .width(this.xComponentWidth)
              .height(this.xComponentHeight)
              .onLoad(async () => {
                this.surfaceID = this.xComponentController.getXComponentSurfaceId();
                hilog.info(0x0000, TAG,
                  `surfaceID: ${this.surfaceID}, curIndex: ${this.curIndex}, index: ${this.index}.`);
                this.initAVPlayer();
              })
              .onDestroy(() => {
                hilog.info(0x0000, TAG,
                  `surfaceID: ${this.surfaceID}, destroy`);
              })
              .id('player')
              .zIndex(1)
          }
          .id(this.componentId)
          .width(this.layoutSize.playerWidth)
          .height(this.layoutSize.playerHeight)
          .position({ y: this.layoutSize.playerPositionY })
          .onSizeChange(() => {
            hilog.info(0x0000, TAG,
              `onSizeChange.`);
            this.uiContext.animateTo({ duration: 0, curve: Curve.EaseInOut }, () => {
              this.autoVideoSize()
            })
          })

          // 图层view, 外部提供
          if (this.contentBuilder) {
            Column() {
              this.contentBuilder?.builder(this.videoData, this.playController, this.playerSession);
            }.zIndex(2)
            .width('100%')
            .height('100%')
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Black)
      }
    }
  }

  async initAVPlayer() {
    try {
      hilog.info(0x0000, TAG, `createAVPlayer begin. curIndex: ${this.curIndex}, index: ${this.index}.`);
      media.createAVPlayer().then((player: media.AVPlayer) => {
        if (player === undefined) {
          hilog.info(0x0000, TAG, `createAVPlayer fail.`);
          return;
        }
        this.avPlayer = player;
        this.setAVPlayerCallback(this.avPlayer);
        // set url into state initialized.
        if (typeof this.videoData.getUrl() === 'string') {
          this.avPlayer.url = this.videoData.getUrl() as string;
          hilog.info(0x0000, TAG,
            `AVPlayer state idle. source: ${this.videoData.getUrl()}, curIndex: ${this.curIndex}, index: ${this.index}.`);
        } else {
          this.avPlayer.fdSrc = this.videoData.getUrl() as media.AVFileDescriptor;
        }
        this.playController.setAVPlayer(this.index, player)
        this.playerSession.setAVPlayer(player)
        this.avSessionController.setAVMetadata(this.videoData);
        hilog.info(0x0000, TAG, `createAVPlayer success. curIndex: ${this.curIndex}, index: ${this.index}.`);
      })
    } catch (e) {
    }
  }

  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('timeUpdate', (time: number) => {
      this.playerSession.timeUpdateCallbacks.get('timeUpdate')?.forEach((item) => {
        item(time);
      });
    })

    avPlayer.on('speedDone', (speed: number) => {
      this.playerSession.avPlayerCallback.get('speedDone')?.forEach((item) => {
        item(speed);
      });
    })

    avPlayer.on('videoSizeChange', (width: number, height: number) => {
      this.videoHeight = height;
      this.videoWidth = width;
      hilog.info(0x0000, TAG, `videoSizeChange videoWidth${this.videoWidth}, videoHeight${this.videoHeight}`)
      this.autoVideoSize()
    })

    avPlayer.on('audioInterrupt', async (interruptEvent: audio.InterruptEvent) => {
      if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
        // 强制打断类型（INTERRUPT_FORCE）：音频相关处理已由系统执行，应用需更新自身状态，做相应调整
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
            avPlayer.pause();
            break;
          case audio.InterruptHint.INTERRUPT_HINT_STOP:
            avPlayer.pause();
            break;

          default:
            break;
        }
      } else if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_SHARE) {
        // 共享打断类型（INTERRUPT_SHARE）：应用可自主选择执行相关操作或忽略音频打断事件
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_RESUME:
            avPlayer.play();
            break;
          default:
            break;
        }
      }
    })

    avPlayer.on('audioOutputDeviceChangeWithInfo', (data: audio.AudioStreamDeviceChangeInfo) => {
      if (data.changeReason === audio.AudioStreamDeviceChangeReason.REASON_OLD_DEVICE_UNAVAILABLE) {
        hilog.info(0x0001, TAG, `Device connect: ${data.changeReason}`);
        avPlayer.pause();
      }
    });

    //error listen, when the avPlayer is error, to load reset interface
    avPlayer.on('error', (err: BusinessError) => {
      hilog.info(0x0000, TAG, `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}.` +
        `----state: ${avPlayer.state}, curIndex: ${this.curIndex}, index: ${this.index}.`);
      avPlayer.reset();
    })

    this.setAVPlayerStateListen(avPlayer);
  }

  setAVPlayerStateListen(avPlayer: media.AVPlayer) {
    avPlayer.on('stateChange', async (state: string) => {
      switch (state) {
        case 'idle':
          hilog.info(0x0000, TAG, `AVPlayer state idle called. curIndex: ${this.curIndex}, index: ${this.index}.`);
          break;
        case 'initialized':
          hilog.info(0x0000, TAG,
            `AVPlayer state initialized called. curIndex: ${this.curIndex}, index: ${this.index}.`);
          avPlayer.surfaceId = this.surfaceID;
          avPlayer.prepare();
          break;
        case 'prepared':
          hilog.info(0x0000, TAG, `AVPlayer state prepared called. curIndex: ${this.curIndex}, index: ${this.index}.`);
          avPlayer.audioInterruptMode = audio.InterruptMode.INDEPENDENT_MODE;
          this.preparedFlag = true;
          this.freshLoaded();
          // 起播进度调整
          if (this.videoData.getPlayTime() > 0) {
            hilog.info(0x0000, TAG, `AVPlayer state prepared called. need seekto: ${this.videoData.getPlayTime()}.`);
            avPlayer.seek(this.videoData.getPlayTime())
          }
          hilog.info(0x0000, TAG,
            `prepared firstFlag:${this.firstFlag}, index:${this.index}, isPageShow:${this.isPageShow}`);
          // 首播起播
          if (this.firstFlag && this.index === this.curIndex && this.isPageShow) {
            hilog.info(0x0000, TAG, 'first video prepared go play!');
            avPlayer.play();
            this.firstLoaded();
          }
          break;
        case 'playing':
          hilog.info(0x0000, TAG,
            `AVPlayer state playing called. curIndex: ${this.curIndex}, index: ${this.index},
            source: ${this.videoData.getUrl()}.`);
          this.isPlaying = true;
          this.isLoading = false;
          break;
        case 'paused':
          this.isPlaying = false;
          hilog.info(0x0000, TAG, `AVPlayer state paused called. curIndex: ${this.curIndex}, index: ${this.index}.`);
          break;
        case 'stopped':
          this.isPlaying = false;
          hilog.info(0x0000, TAG, `AVPlayer state stopped called. curIndex: ${this.curIndex}, index: ${this.index}.`);
          break;
        case 'completed':
          hilog.info(0x0000, TAG, `AVPlayer state completed called. curIndex: ${this.curIndex}, index: ${this.index}.`);
          this.isPlaying = false;
          if (this.playController.autoPlay) {
            this.playController.changeIndex(this.curIndex + 1)
          }
          avPlayer.seek(0, media.SeekMode.SEEK_CLOSEST);
          if(this.playController.loopPlay){
            this.avPlayer?.play()
          }
          break;
        case 'released':
          hilog.info(0x0000, TAG, `AVPlayer state released called. curIndex: ${this.curIndex}, index: ${this.index}.`);
          break;
        case 'error':
          hilog.info(0x0000, TAG, `AVPlayer state error called. curIndex: ${this.curIndex}, index: ${this.index}.`);
          avPlayer.reset();
          break;
        default:
          hilog.info(0x0000, TAG, `AVPlayer state unknown called. curIndex: ${this.curIndex}, index: ${this.index}.`);
          break;
      }
      let callArr = this.playerSession.stateChangeCallbacks.get('stateChange');
      callArr?.forEach((item) => {
        item(state);
      });
    })
  }

  onIndexChange() {
    hilog.info(0x0000, TAG,
      `enter onIndexChange. curIndex: ${this.curIndex}, index: ${this.index}, isPageShow: ${this.isPageShow}.`);
    // 滑动过程中，不播放视频
    if (this.curIndex !== this.index) {
      pauseVideo(this.avPlayer, this.curIndex, this.index);
      this.isPlaying = false;
      this.trackThicknessSize = Const.TRACK_SIZE_MIN;
    } else {
      hilog.info(0x0000, TAG,
        `enter indexChange play. curIndex: ${this.curIndex}, index: ${this.index}, isPageShow: ${this.isPageShow}.`);
      // 准备好了，直接播放视频，否则等待准备
      if (this.preparedFlag) {
        playVideo(this.avPlayer, this.curIndex, this.index);
        this.isPlaying = true;
        this.trackThicknessSize = Const.TRACK_SIZE_MIN;
      } else {
        let countNum = 0;
        let intervalFlag = setInterval(() => {
          countNum++;
          if (this.curIndex !== this.index) {
            hilog.info(0x0000, TAG, `enter indexChange play error, clearIntreval. flag: ${this.preparedFlag},
            curIndex: ${this.curIndex}, index: ${this.index}.`);
            clearInterval(intervalFlag);
          }
          if (this.preparedFlag && this.isPageShow) {
            countNum = 0;
            playVideo(this.avPlayer, this.curIndex, this.index);
            this.isPlaying = true;
            this.trackThicknessSize = Const.TRACK_SIZE_MIN;
            clearInterval(intervalFlag);
          } else {
            hilog.info(0x0000, TAG, `enter indexChange play error, clearIntreval. countNum: ${countNum},
             flag: ${this.preparedFlag}, curIndex: ${this.curIndex}, index: ${this.index}.`);
            if (countNum > 15) {
              hilog.info(0x0000, TAG,
                `enter indexChange play error, reinit initAVPlayer. countNum: ${countNum}, flag: ${this.preparedFlag},
                curIndex: ${this.curIndex}, index: ${this.index}.`);
              countNum = 0;
              this.initAVPlayer();
            }
          }
        }, 100);
      }
    }
  }

  onFoldStatusChange() {
    this.autoVideoSize();
  }

  autoVideoSize() {
    let size = this.uiContext.getComponentUtils().getRectangleById(this.componentId).size;
    let playerComponentWidth = size.width;
    let playerComponentHeight = size.height;
    let videoRatio = this.videoWidth / this.videoHeight;
    let componentRatio = playerComponentWidth / playerComponentHeight;

    // 保持宽高比进行缩小或者放大，使得视频两边都大于或等于显示边界。
    if (this.videoFit === VideoFit.Cover) {
      if (videoRatio > componentRatio) {
        this.xComponentWidth = this.uiContext.px2vp(this.videoWidth * playerComponentHeight / this.videoHeight);
        this.xComponentHeight = this.uiContext.px2vp(playerComponentHeight);
      } else {
        this.xComponentWidth = this.uiContext.px2vp(playerComponentWidth);
        this.xComponentHeight = this.uiContext.px2vp(this.videoHeight * playerComponentWidth / this.videoWidth);
      }
    }
    // 保持宽高比进行缩小或者放大，使得视频高度填满。
    if (this.videoFit === VideoFit.CoverH) {
      this.xComponentWidth = this.uiContext.px2vp(this.videoWidth * playerComponentHeight / this.videoHeight);
      this.xComponentHeight = this.uiContext.px2vp(playerComponentHeight);
    }
    // 保持宽高比进行缩小或者放大，使得图片完全显示在显示边界内。
    if (this.videoFit === VideoFit.Contain) {
      if (videoRatio > componentRatio) {
        this.xComponentWidth = this.uiContext.px2vp(playerComponentWidth);
        this.xComponentHeight = this.uiContext.px2vp(this.videoHeight * playerComponentWidth / this.videoWidth);
      } else {
        this.xComponentWidth = this.uiContext.px2vp(this.videoWidth * playerComponentHeight / this.videoHeight);
        this.xComponentHeight = this.uiContext.px2vp(playerComponentHeight);
      }
    }
  }

  startPip() {
    if (!PiPWindow.isPiPEnabled()) {
      console.error(`picture in picture disabled for current OS`);
      return;
    }
    let config: PiPWindow.PiPConfiguration = {
      context: this.getUIContext().getHostContext() as Context,
      componentController: this.xComponentController,
      templateType: PiPWindow.PiPTemplateType.VIDEO_LIVE,
      contentWidth: this.videoData.getType() === 0 ? 1080 : 1920,
      contentHeight: this.videoData.getType() === 0 ? 1920 : 1080,
      navigationId: this.navId,
      controlGroups: []
    };
    // 步骤1：创建画中画控制器，通过create接口创建画中画控制器实例
    try {
      let promise: Promise<PiPWindow.PiPController> = PiPWindow.create(config);
      promise.then((controller: PiPWindow.PiPController) => {
        this.pipController = controller;
        // 步骤1：初始化画中画控制器
        this.initPipController();
        // 步骤2：通过startPiP接口启动画中画
        this.pipController.startPiP().then(() => {
          console.info(`Succeeded in starting pip.`);
        }).catch((err: BusinessError) => {
          console.error(`Failed to start pip. Cause:${err.code}, message:${err.message}`);
        });
      }).catch((err: BusinessError) => {
        console.error(`Failed to create pip controller. Cause:${err.code}, message:${err.message}`);
      });
    } catch (e) {
    }
  }

  initPipController() {
    if (!this.pipController) {
      return;
    }
    //通过setAutoStartEnabled接口设置是否需要在应用返回桌面时自动启动画中画，注册stateChange和controlPanelActionEvent回调
    this.pipController.setAutoStartEnabled(false);
    this.pipController.on('stateChange', (state: PiPWindow.PiPState, reason: string) => {
      this.onStateChange(state, reason);
    });
    this.pipController.on('controlPanelActionEvent', (event: PiPWindow.PiPActionEventType, status?: number) => {
      this.onActionEvent(event, status);
    });
  }

  onStateChange(state: PiPWindow.PiPState, reason: string) {
    let curState: string = '';
    switch (state) {
      case PiPWindow.PiPState.ABOUT_TO_START:
        curState = 'ABOUT_TO_START';
        this.pathStack.pop()
        break;
      case PiPWindow.PiPState.STARTED:
        curState = 'STARTED';
        break;
      case PiPWindow.PiPState.ABOUT_TO_STOP:
        curState = 'ABOUT_TO_STOP';
        break;
      case PiPWindow.PiPState.STOPPED:
        curState = 'STOPPED';
        break;
      case PiPWindow.PiPState.ABOUT_TO_RESTORE:
        curState = 'ABOUT_TO_RESTORE';
        break;
      case PiPWindow.PiPState.ERROR:
        curState = 'ERROR';
        break;
      default:
        break;
    }
    console.info(`[${TAG}] onStateChange: ${curState}, reason: ${reason}`);
  }

  onActionEvent(event: PiPWindow.PiPActionEventType, status?: number) {
    switch (event) {
      case 'playbackStateChanged':
        // 开始或停止视频
        if (status === 0) {
          this.playController.pause()
        } else if (status === 1) {
          this.playController.play()
        }
        break;
      default:
        break;
    }
  }

  // 视频内容变化时，向画中画控制器更新视频尺寸信息，用于调整画中画窗口比例
  updateContentSize(width: number, height: number) {
    if (this.pipController) {
      this.pipController.updateContentSize(width, height);
    }
  }

  // 当不再需要显示画中画时，通过stopPiP接口关闭画中画
  stopPip() {
    if (this.pipController === null || this.pipController === undefined) {
      return;
    }
    let promise: Promise<void> = this.pipController.stopPiP();
    promise.then(() => {
      console.info(`Succeeded in stopping pip.`);
      this.pipController?.off('stateChange');
      this.pipController?.off('controlPanelActionEvent');
    }).catch((err: BusinessError) => {
      console.error(`Failed to stop pip. Cause:${err.code}, message:${err.message}`);
    });
  }

  backEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 1
    };
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      if (!this.playController.allowBackground) {
        this.playController.pause()
        this.stopPip()
      }
      hilog.info(0x0000, TAG, `eventData: ${JSON.stringify(eventData)}`);
    }
    try {
      emitter.on(event, callback);
    } catch (e) {
    }
  }

  foreEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 2
    };
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      if (!this.playController.allowBackground) {
        this.playController.play()
      }
      hilog.info(0x0000, TAG, `eventData: ${JSON.stringify(eventData)}`);
    }
    try {
      emitter.on(event, callback);
    } catch (e) {
    }
  }
}


