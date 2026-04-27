import { deviceInfo, emitter } from '@kit.BasicServicesKit';
import { AppStorageV2, display, uiObserver, window } from '@kit.ArkUI';
import { SessionListener, VideoSessionController } from '../controller/VideoSessionController';
import { SwipePlayerController } from '../controller/SwipePlayerController';
import { AVPlayerController } from '../controller/AVPlayerController';
import { PlayerLayoutSize } from '../controller/PlayerLayoutSize';
import { PlayerDataSource } from '../datasource/PlayerDataSource';
import { VideoPlayerView } from '../components/VideoPlayerView';
import { AVPlayerState, BreakpointNameEnum, PageNameEnum, VideoPlayerData } from '../type/Index';
import { isDisplayModeFull, setOrientation, toast } from '../utils/Util';
import { VideoNetworkModel, VideoNetworkSetting } from '../models/VideoNetworkModel';
import { BreakpointModel } from '../models/BreakpointModel';
import { PiPWindowModel } from '../models/PiPWindowModel';
import { Logger } from '../utils/Logger';
import { EventKey } from '../constants/EventKey';

const TAG = '[VideoSwipePlayer]';

@ComponentV2
export struct VideoSwipePlayer {
  // 当前视频索引
  @Local currentIndex: number = 0;
  // 播放控制器
  @Param swipePlayerController: SwipePlayerController = new SwipePlayerController();
  // 懒加载数据源
  @Param datasource: PlayerDataSource<VideoPlayerData> = new PlayerDataSource<VideoPlayerData>();
  // 视频播放的外层交互组件
  @Param videoLayerBuilder:
  WrappedBuilder<[Object, AVPlayerController, SwipePlayerController, PlayerLayoutSize]> | undefined = undefined;
  // 全屏按钮
  @BuilderParam fullBtnBuilder: () => void = this.defaultFullBtnBuilder
  // 配置项信息
  @Param options: SwipePlayerOptions | undefined = undefined
  // 底部tab的高度
  @Provider() bottomTabHeight: Length | undefined = this.options?.bottomTabHeight;
  // 点击列表页的视频卡片对应的视频
  @Param videoItemAVPlayerController: AVPlayerController | undefined = undefined
  // 网络
  @Param videoNetwork: VideoNetworkModel | undefined = undefined
  @Param videoNetworkSetting: VideoNetworkSetting | undefined = undefined
  // 路由栈
  @Param @Require pathStack: NavPathStack
  // 是否接入播控中心
  @Param enableAVSession: boolean = false;
  // 当前组件所在的页面是否显示
  @Param isShown: boolean = false;
  // 是否横屏
  @Param isLandscape: boolean = false;
  // 一多适配的断点
  @Param currentBreakpoint: BreakpointNameEnum = BreakpointNameEnum.SM;
  // 播放状态回调
  @Event playerStateCallback: (state: string, id: string) => void = () => {
  }
  // 播放进度变化的回调
  @Event playerTimeUpdateCallback: (videoData: VideoPlayerData, timeMs: number) => void = () => {
  }
  // 滑动控制器
  swiperController: SwiperController = new SwiperController();
  // 播控中心控制器
  avSessionController: VideoSessionController = VideoSessionController.instance;
  @Local videoState: AVPlayerState = AVPlayerState.IDLE;
  @Local videoStateIndex: number = 0
  @Provider() navDestinationUpdateListeners: Map<string, (info: uiObserver.NavDestinationInfo) => void> = new Map();
  @Local breakpointModel: BreakpointModel = new BreakpointModel();
  @Local pipWindowModel: PiPWindowModel = AppStorageV2.connect(PiPWindowModel, () => new PiPWindowModel())!;
  private displayFoldStatusChangeCallback = (data: display.FoldStatus) => {
    if (data === display.FoldStatus.FOLD_STATUS_FOLDED) {
      let isFullMode = isDisplayModeFull();
      if (isFullMode) {
        setOrientation(this.getUIContext(), window.Orientation.FOLLOW_DESKTOP)
      } else {
        setOrientation(this.getUIContext(), window.Orientation.USER_ROTATION_PORTRAIT)
      }
    }
  }

  @Computed
  get avPlayerManager() {
    return this.swipePlayerController.getAVPlayerMgr()!
  }

  @Monitor('videoNetwork.isCellular', 'videoState', 'videoStateIndex')
  onNetworkChange() {
    let videoState = this.avPlayerManager.getAVPlayer(this.currentIndex)?.state
    if (this.videoNetworkSetting?.remindWithoutWlan === 1) {
      this.videoNetwork!.hasUseMobileDataTip = false
    }
    if (videoState === AVPlayerState.PLAYING) {
      if (this.videoNetwork?.isCellular && !this.videoNetwork?.hasUseMobileDataTip) {
        toast(this.getUIContext(), {
          message: '正在使用流量播放',
          alignment: Alignment.Center,
        })
        if (this.videoNetwork && this.videoNetworkSetting?.remindWithoutWlan === 0) {
          this.videoNetwork.hasUseMobileDataTip = true
        }
      }
    }
  }

  @Monitor('currentBreakpoint')
  onCurrentBreakpointChange() {
    // 设置断点
    this.breakpointModel.currentBreakpoint = this.currentBreakpoint;
  }

  @Monitor('isShown')
  onChangeShown() {
    AppStorage.setOrCreate('isShown', this.isShown)
  }

  private fullScreenListener = (info: uiObserver.NavDestinationInfo) => {
    this.pipWindowModel.navDestinationUpdateListeners.forEach((callback, key) => {
      if (key === 'fullScreenListener') {
        callback(info)
      }
    })
  }

  aboutToAppear(): void {
    // 设置断点
    this.breakpointModel.currentBreakpoint = this.currentBreakpoint;
    this.swipePlayerController?.setSwiperController(this.swiperController);
    // 网络
    this.handleNetwork()
    this.createAVSession();
    // 当前视频的状态
    emitter.on(EventKey.SWIPER_VIDEO_PLAYER_STATE, (eventData: emitter.EventData) => {
      let state = eventData.data!.state as AVPlayerState;
      let index = eventData.data!.index as number;
      this.videoState = state;
      this.videoStateIndex = index
    })

    emitter.on(EventKey.DISABLE_PREVIOUS_NEXT, () => {
      this.avSessionController.releaseNextPreviousListener();
    })

    emitter.on(EventKey.ENABLE_PREVIOUS_NEXT, () => {
      this.avSessionController.setListener({
        playNext: this.sessionListener.playNext,
        playPrevious: this.sessionListener.playPrevious,
      });
    });

    // 无感监听路由变化
    uiObserver.on('navDestinationUpdate', this.fullScreenListener);

    AppStorage.setOrCreate('isShown', this.isShown)
  }

  aboutToDisappear(): void {
    this.avSessionController.destroy(this.getUIContext().getHostContext() as Context);
    emitter.off(EventKey.DISABLE_PREVIOUS_NEXT);
    emitter.off(EventKey.ENABLE_PREVIOUS_NEXT);
    emitter.off(EventKey.SWIPER_VIDEO_PLAYER_STATE);
    uiObserver.off('navDestinationUpdate', this.fullScreenListener);
  }

  async createAVSession() {
    if (!this.enableAVSession) {
      return;
    }

    if (!this.avSessionController.getSession()) {
      await this.avSessionController.create(this.getUIContext().getHostContext() as Context);
    }
    this.avSessionController.setListener(this.sessionListener);
    this.avSessionController.activate();
  }

  sessionListener: SessionListener = {
    play: () => {
      this.swipePlayerController.play();
    },
    pause: () => {
      this.swipePlayerController.pause();
    },
    playNext: () => {
      if (!this.options?.totalCount || this.currentIndex + 1 < this.options?.totalCount) {
        this.swipePlayerController.changeIndex(this.currentIndex + 1);
      }
    },
    playPrevious: () => {
      if (this.currentIndex <= 0) {
        // 重新播放
        this.swipePlayerController.seek(0);
        this.swipePlayerController.play();
        return;
      }
      this.swipePlayerController.changeIndex(this.currentIndex - 1);
    },
  };

  handleNetwork() {
    if (this.videoNetwork && !this.videoNetwork.hasNet) {
      toast(this.getUIContext(), {
        message: '网络连接不可用',
        alignment: Alignment.Center,
        textColor: Color.Red,
      })
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Swiper(this.swiperController) {
        LazyForEach(this.datasource, (item: VideoPlayerData, index: number) => {
          VideoPlayerView({
            videoData: item,
            index: index,
            autoPlay: this.options?.autoPlay,
            enableAVSession: this.enableAVSession,
            currentIndex: this.currentIndex,
            totalCount: this.options?.totalCount,
            swipePlayerController: this.swipePlayerController,
            videoItemAVPlayerController: this.videoItemAVPlayerController,
            videoNetwork: this.videoNetwork,
            videoNetworkSetting: this.videoNetworkSetting,
            videoLayerBuilder: this.videoLayerBuilder,
            fullBtnBuilder: this.fullBtnBuilder,
            pathStack: this.pathStack,
            isLandscape: this.isLandscape,
            isShown: this.isShown,
            breakpointModel: this.breakpointModel,
            playerStateCallback: this.playerStateCallback,
            playerTimeUpdateCallback: this.playerTimeUpdateCallback,
          })
        }, (item: VideoPlayerData, index: number) => JSON.stringify(item) + index);
      }
      .cachedCount(this.options?.cachedCount ?? 2)
      .width('100%')
      .height('100%')
      .vertical(true)
      .loop(false)
      .curve(Curve.Ease)
      .duration(300)
      .indicator(false)
      .backgroundColor(Color.Black)
      .effectMode(EdgeEffect.Spring)
      .onChange((index: number) => {
        this.currentIndex = index;
        if (this.options?.swiperCallback?.onChange) {
          this.options.swiperCallback?.onChange(index);
        }
      })
      .onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
        this.currentIndex = targetIndex;
        if (this.options?.swiperCallback?.onAnimationStart) {
          this.options.swiperCallback?.onAnimationStart(index, targetIndex, extraInfo);
        }
      })
    }
    .width('100%')
    .height('100%')
    .id('player')
    .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
      if (isExpanding && currentRatio >= 1.0) {
        let isFullMode = isDisplayModeFull();
        if (isFullMode || deviceInfo.deviceType === 'tablet') {
          setOrientation(this.getUIContext(), window.Orientation.FOLLOW_DESKTOP)
        } else {
          setOrientation(this.getUIContext(), window.Orientation.USER_ROTATION_PORTRAIT)
        }
        try {
          display.on('foldStatusChange', this.displayFoldStatusChangeCallback);
        } catch (e) {
          Logger.error(TAG, 'on foldStatusChange fail, error: ' + JSON.stringify(e));
        }
      }
      if (!isExpanding && currentRatio <= 0.0) {
        let allPathNames = this.pathStack.getAllPathName();
        let lastName = allPathNames[allPathNames.length - 1]
        if (lastName !== PageNameEnum.VIDEO_LANDSCAPE_PAGE) {
          setOrientation(this.getUIContext(), window.Orientation.FOLLOW_DESKTOP);
        }
        try {
          display.off('foldStatusChange', this.displayFoldStatusChangeCallback);
        } catch (e) {
          Logger.error(TAG, 'off foldStatusChange fail, error: ' + JSON.stringify(e));
        }
      }
    })
  }

  // 默认全屏播放按钮
  @Builder
  defaultFullBtnBuilder() {
    Row({ space: 4 }) {
      Image($r('app.media.ic_expand_full')).width(13).height(13)
      Text('全屏播放')
        .fontColor(Color.White)
        .fontSize(14).fontWeight(500)
    }
    .padding({
      left: 10,
      top: 8,
      bottom: 8,
      right: 10,
    })
    .border({
      width: 1,
      color: '#99ffffff',
      style: BorderStyle.Solid,
      radius: 30,
    })
  }
}

export class SwipePlayerOptions {
  cachedCount?: number;
  autoPlay?: boolean;
  swiperCallback?: SwiperCallback;
  bottomTabHeight?: Length;
  totalCount?: number;
}

export class SwiperCallback {
  onChange?: (index: number) => void;
  onAnimationStart?: (index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => void;
}