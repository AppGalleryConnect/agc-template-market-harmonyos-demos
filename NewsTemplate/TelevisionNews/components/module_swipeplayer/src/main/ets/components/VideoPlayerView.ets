import { media } from '@kit.MediaKit';
import { emitter } from '@kit.BasicServicesKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { AVPlayerState, BreakpointNameEnum, PageNameEnum, VideoPlayerData } from '../type/Index';
import { AVPlayerController } from '../controller/AVPlayerController';
import { SwipePlayerController } from '../controller/SwipePlayerController';
import { PlayerLayoutSize } from '../controller/PlayerLayoutSize';
import { VideoProgressBar } from './VideoProgressBar';
import { Constants } from '../constants/Constants';
import { SwipePlayerModel } from '../viewmodel/SwipePlayerModel';
import { PlayerSpeedRateView } from './PlayerSpeedRateView';
import { DownloadWithoutWlanEnum, VideoNetworkModel, VideoNetworkSetting } from '../models/VideoNetworkModel';
import { handleSandboxVideoUrl, toast } from '../utils/Util';
import { BreakpointModel } from '../models/BreakpointModel';
import { PiPWindowModel } from '../models/PiPWindowModel';
import { EventKey } from '../constants/EventKey';
import { Logger } from '../utils/Logger';

const TAG = '[VideoPlayerView]';

@ComponentV2
export struct VideoPlayerView {
  // 视频数据
  @Param @Require videoData: VideoPlayerData;
  // 本视频索引
  @Param index: number = 0;
  // swiper中当前的播放索引
  @Param currentIndex: number = 0;
  // 总数
  @Param totalCount: number = 0;
  // 滑动组件控制器
  @Param @Require swipePlayerController: SwipePlayerController;
  // 视频播放的外层交互组件
  @Param videoLayerBuilder:
  WrappedBuilder<[Object, AVPlayerController, SwipePlayerController, PlayerLayoutSize]> | undefined = undefined;
  // 全屏按钮
  @BuilderParam fullBtnBuilder: () => CustomBuilder
  // 是否自动播放
  @Param autoPlay: boolean = true;
  // 是否接入播控中心
  @Param enableAVSession: boolean = false;
  // 点击列表页的视频卡片对应的视频
  @Param videoItemAVPlayerController: AVPlayerController | undefined = undefined
  // 网络
  @Param videoNetwork: VideoNetworkModel | undefined = undefined
  @Param videoNetworkSetting: VideoNetworkSetting | undefined = undefined
  // 路由栈
  @Param @Require pathStack: NavPathStack
  // 是否横屏
  @Param isLandscape: boolean = false;
  // 当前组件所在的页面是否显示
  @Param isShown: boolean = false;
  // 一多适配的断点
  @Param breakpointModel: BreakpointModel = new BreakpointModel();
  // 播放状态回调
  @Event playerStateCallback: (state: string, id: string) => void = () => {
  }
  // 播放进度变化的回调
  @Event playerTimeUpdateCallback: (videoData: VideoPlayerData, timeMs: number) => void = () => {
  }
  // 底部tab高度
  @Consumer() bottomTabHeight: Length | undefined;
  // 路由变化的监听事件
  @Local pipWindowModel: PiPWindowModel = AppStorageV2.connect(PiPWindowModel, () => new PiPWindowModel())!;
  private xComponentController = new XComponentController();
  private vm: SwipePlayerModel = new SwipePlayerModel(this.getUIContext(), this.index)
  // 准备状态监听事件
  private preparedListener = () => {
    if (this.index === this.currentIndex && this.autoPlay) {
      const isShown = AppStorage.get<boolean>('isShown');
      if (isShown) {
        this.vm.avPlayerController.play()
      }
    } else {
      // 没有封面图时，取视频的 2ms 的位置帧作为封面
      if (!this.videoData.getCoverUrl()) {
        this.vm.avPlayerController.avPlayer?.seek(2)
      }
    }
  }
  // 播放时监听
  private playingListeners = () => {
    if (this.index === this.currentIndex) {
      this.playerStateCallback && this.playerStateCallback(AVPlayerState.PLAYING, this.videoData.getVideoId())
      emitter.emit(EventKey.SWIPER_VIDEO_PLAYER_STATE, {
        data: {
          state: AVPlayerState.PLAYING,
          index: this.currentIndex,
        },
      } as emitter.EventData)
    }
  }
  // 播放完成状态监听事件
  private completedListeners = () => {
    // 横屏时，播放完成后，重头开始播放
    if (this.isLandscape) {
      this.vm.avPlayerController.play();
      return
    }
    // 设置自动播放下一个
    if (this.videoNetworkSetting?.autoPlayNext) {
      if (!this.totalCount || this.currentIndex + 1 < this.totalCount) {
        this.vm.isPause = true;
        this.vm.avPlayerController.avPlayer!.seek(0, media.SeekMode.SEEK_CLOSEST);
        this.swipePlayerController.changeIndex(this.currentIndex + 1);
        return
      }
    }
    // 其他情况，重头开始播放
    this.vm.avPlayerController.play()
  }
  // 视频播放错误事件监听
  private errorListener = () => {
    if (this.videoNetwork && !this.videoNetwork.hasNet && this.vm.isBuffering) {
      toast(this.vm.uiContext!, {
        message: '网络连接不可用',
        alignment: Alignment.Center,
        textColor: Color.Red,
      })
      this.vm.isBuffering = false;
      this.vm.isPause = true;
    }
  }
  // 缓存事件监听
  private buffingUpdateListener = (infoType: media.BufferingInfoType) => {
    if (this.currentIndex === this.index) {
      if (infoType === media.BufferingInfoType.BUFFERING_START) {
        this.vm.isPause = false;
        this.vm.isBuffering = true;
      }
      if (infoType === media.BufferingInfoType.BUFFERING_END) {
        this.vm.isBuffering = false
      }
    }
  }

  @Monitor('currentIndex')
  onIndexChanged() {
    this.onChangeSwiperIndex();
  }

  @Monitor('videoNetwork.isNetworkAvailable')
  onListenNetwork(monitor: IMonitor) {
    let hasNet = monitor.value()?.now as boolean
    let playerState = this.vm.avPlayerController?.avPlayer?.state
    if (this.index === this.currentIndex && playerState === 'idle' && hasNet) {
      if (this.videoData.getVideoUrl().startsWith('http')) {
        this.vm.avPlayerController.avPlayer!.url = this.videoData.getVideoUrl()
      } else {
        this.vm.videoFileFD = handleSandboxVideoUrl(this.videoData.getVideoUrl())
        this.vm.avPlayerController.avPlayer!.url = 'fd://' + this.vm.videoFileFD;
      }
    }
  }

  @Monitor('isLandscape')
  onChangeOrientation(monitor: IMonitor) {
    let isLandscape = (monitor.value()?.now) as boolean;
    if (!isLandscape) {
      this.vm.isClickFullScreenBtn = false;
      return
    }
    // 自动横屏：组件处于显示状态、横屏、当前索引视频、不是通过点击全屏按钮的横屏、直板机状态下
    if (this.index === this.currentIndex && isLandscape && this.isShown && !this.vm.isClickFullScreenBtn &&
      this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM
    ) {
      this.handleFullScreen(false)
    }
  }

  // 是否当前在页面中心的视频
  @Computed
  get isCurrent() {
    return this.index === this.currentIndex;
  }

  aboutToAppear(): void {
    let isDisabled = this.videoNetworkSetting?.downloadWithoutWlan === DownloadWithoutWlanEnum.downloadDisable;
    let isCellular = this.videoNetwork?.isNetworkAvailable && this.videoNetwork?.isCellular;
    // 移动网络下，设置不下载图
    let imageUrl = isCellular && isDisabled ? $r('app.media.ic_default_bg') : this.videoData.getCoverUrl();
    this.vm.imageUrl = imageUrl || $r('app.media.ic_default_bg');
    this.vm.setPathStack(this.pathStack);
    // 初始化
    this.vm.avPlayerManager = this.swipePlayerController.getAVPlayerMgr()!
    this.vm.initPlayerManager(this.videoData, this.videoItemAVPlayerController)
    this.vm.initXComponentId()
    // 注册监听
    this.registerListeners();
  }

  aboutToDisappear(): void {
    Logger.debug(TAG, 'aboutToDisappear, this.vm.isFromList: ' + this.vm.isFromList);
    // 从列表页跳转过来的，不需要销毁播放对象，由列表页负责销毁
    if (!this.vm.isFromList) {
      this.vm.releaseAVPlayer();
    }
    this.pipWindowModel.navDestinationUpdateListeners.delete('fullScreenListener');
  }

  registerListeners() {
    // 准备状态监听事件
    this.vm.onPreparedListener(this.preparedListener);
    // 播放状态
    this.vm.onPlayingListener(this.playingListeners)
    // 完成状态监听事件
    this.vm.onCompletionListener(this.completedListeners)
    // 播放错误状态监听事件
    this.vm.onErrorListener(this.errorListener)
    // 缓存事件监听
    this.vm.onBuffingUpdateListener(this.buffingUpdateListener)
    // 监听首帧事件
    this.vm.onStartRenderFrameListener(() => {
      if (this.index === this.currentIndex) {
        this.vm.isPause = false
        this.vm.showCover = false;
      }
    })
    // 视频尺寸变化监听
    this.vm.onVideoSizeChangedListener(() => {
      this.vm.adaptiveVideoSize()
    })
    // 视频进度监听
    this.vm.onTimeUpdateListener((timeMs: number) => {
      if (this.index === this.currentIndex) {
        this.playerTimeUpdateCallback && this.playerTimeUpdateCallback(this.videoData, timeMs)
      }
    })
  }

  onChangeSwiperIndex() {
    this.swipePlayerController.setCurrentIndex(this.currentIndex);
    if (this.index !== this.currentIndex) {
      this.vm.offAVPlayerChangeBySession();
      this.vm.isPause = true;
      this.vm.avPlayerController.pause();
      return;
    }

    if (this.enableAVSession) {
      this.vm.onAVPlayerChangeBySession();
    }
    this.vm.isPause = false;
    if (this.vm.avPlayerController.avPlayer?.state! === AVPlayerState.IDLE) {
      if (this.videoData.getVideoUrl().startsWith('http')) {
        this.vm.avPlayerController.avPlayer!.url = this.videoData.getVideoUrl()
      } else {
        this.vm.avPlayerController.avPlayer!.url = 'fd://' + handleSandboxVideoUrl(this.videoData.getVideoUrl())
      }
      return
    }
    let canPlayStates = [AVPlayerState.PREPARED, AVPlayerState.PAUSED, AVPlayerState.COMPLETED] as media.AVPlayerState[]
    if (canPlayStates.includes(this.vm.avPlayerController.avPlayer?.state!)) {
      this.vm.avPlayerController.avPlayer?.setSpeed(1);
      this.vm.avPlayerController.play();
    }
  }

  // 处理横屏按钮事件
  async handleFullScreen(isSetOrientation: boolean = true) {
    let param: Record<string, Object | AVPlayerController | BreakpointModel> = {};
    param.avPlayerController = this.vm.avPlayerController;
    param.surfaceId = this.vm.surfaceId;
    param.videoWidth = this.vm.videoWidth;
    param.videoHeight = this.vm.videoHeight;
    param.videoTitle = this.videoData.getVideoTitle();
    param.breakpointModel = this.breakpointModel
    // 视频播放，跨页面流转
    this.pipWindowModel.navDestinationUpdateListeners.clear();
    this.pipWindowModel.navDestinationUpdateListeners.set('fullScreenListener', (info) => {
      if (info.name === PageNameEnum.VIDEO_LANDSCAPE_PAGE && info.state === 3) {
        let avPlayer = (param.avPlayerController as AVPlayerController).getAVPlayer() as media.AVPlayer;
        if (avPlayer) {
          avPlayer.surfaceId = param.surfaceId as string;
        }
      }
    })
    if (isSetOrientation) {
      await this.vm.handleOrientation();
      this.vm.isClickFullScreenBtn = true;
    }
    this.breakpointModel.isLandscapeAuto = !isSetOrientation;
    this.vm.pushToLandscapePage(param, 'player');
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 倍速
      PlayerSpeedRateView({
        leftRateOpacity: this.vm.leftRateOpacity,
        rightRateOpacity: this.vm.rightRateOpacity,
      })
        .visibility(this.vm.isAccelerate ? Visibility.Visible : Visibility.None)

      Stack() {
        Stack({ alignContent: Alignment.Bottom }) {
          Column() {
            Stack() {
              if (this.vm.isPause) {
                Image($r('app.media.ic_paused'))
                  .width(60)
                  .height(60)
                  .zIndex(2)
                  .accessibilityLevel('yes')
                  .accessibilityText('继续播放')
                  .onClick(() => {
                    this.vm.playOrPause()
                  });
              }

              XComponent({
                id: this.vm.xComponentId,
                type: XComponentType.SURFACE,
                controller: this.xComponentController,
              })
                .aspectRatio(Number(this.vm.videoWidth) / Number(this.vm.videoHeight))
                .onLoad(() => {
                  let surfaceId = this.xComponentController.getXComponentSurfaceId();
                  // 设置视频窗口ID
                  this.vm.setSurfaceId(surfaceId)
                  // 初始化
                  this.vm.initAVPlayer(this.enableAVSession && this.isCurrent);
                })

              Column() {
                LoadingProgress()
                  .width(40)
                  .height(40)
                  .color($r('sys.color.icon_on_primary'))
                Text('缓冲中...')
                  .fontSize(12)
                  .fontColor($r('sys.color.icon_on_primary'))
              }
              .accessibilityLevel('no-hide-descendants')
              .zIndex(2)
              .visibility(this.vm.isBuffering ? Visibility.Visible : Visibility.Hidden)

              // 封面
              if (this.vm.showCover && this.videoData.getCoverUrl()) {
                this.coverImgView()
              }
            }
            .id(this.vm.componentId)
            .width(this.vm.playerLayoutSize.getPlayerWidth())
            .height(this.vm.playerLayoutSize.getPlayerHeight())
            .animation({ duration: 200 })
            .onSizeChange(() => {
              this.vm.adaptiveVideoSize()
            })
          }
          .width('100%')
          .height('100%')
          .padding({ bottom: this.bottomTabHeight })

          // 自定义外层操作交互层
          if (this.videoLayerBuilder && !this.vm.isAccelerate) {
            Column() {
              this.videoLayerBuilder?.builder(
                this.videoData,
                this.vm.avPlayerController,
                this.swipePlayerController,
                this.vm.playerLayoutSize,
              )
            }
            .zIndex(2)
            .width('100%')
            .height('100%')
          }
          // 没有设置外层操作层时，默认展示视频进度控制器
          if (!this.videoLayerBuilder && !this.vm.isAccelerate) {
            this.defaultVideoProgressBar()
          }
        }

        // 全屏播放按钮
        if (this.vm.showFullScreenBtn) {
          this.fullScreenBtnView()
        }
      }
    }
    .accessibilityLevel('no')
    .gesture(
      LongPressGesture({ repeat: true, duration: 300 })
        .onAction((event: GestureEvent) => {
          this.vm.onLongPress(event)
        })
        .onActionCancel(() => {
          this.vm.offLongPress()
        })
        .onActionEnd(() => {
          this.vm.offLongPress()
        }),
    )
  }

  @Builder
  coverImgView() {
    Image(this.vm.imageUrl).width(this.vm.playerLayoutSize.getXComponentWidth())
  }

  @Builder
  fullScreenBtnView() {
    Column() {
      this.fullBtnBuilder()
    }
    .zIndex(4)
    .offset({ top: Number(this.vm.playerLayoutSize.getXComponentHeight()) / 2 })
    .visibility(this.vm.playerLayoutSize.getLayoutSizeChangeFlag() ? Visibility.Hidden : Visibility.Visible)
    .onClick(() => {
      if (this.vm.isBuffering) {
        return;
      }
      this.handleFullScreen()
    })
  }

  @Builder
  defaultVideoProgressBar() {
    Column() {
      VideoProgressBar({
        avPlayerController: this.vm.avPlayerController,
      })
    }
    .zIndex(2)
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.End)
    .padding({ bottom: Constants.BOTTOM_TAB_NAV_HEIGHT })
  }
}