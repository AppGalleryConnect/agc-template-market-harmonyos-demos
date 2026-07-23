import { uiObserver, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { AVPlayerController, VideoCard, VideoNetworkModel, VideoNetworkSetting } from 'module_swipeplayer';
import { CommonConstants, Logger, NetworkUtil, RouterMap, RouterUtils, TabBarType, TimeUtils } from 'lib_common';
import { NetworkExceptionView } from 'lib_widget';
import { VideoNewsData } from '../models/VideoModel';
import { RecommendPageVM } from '../viewmodels/RecommendPageVM';
import { TabPageType } from '../types/Index';

const TAG = '[RecommendPage]'

@ComponentV2({ freezeWhenInactive: true })
export struct RecommendPage {
  // tab页面的index
  @Param index: number = 2
  // 视频页里面的头部tabIndex
  @Param currentTabIndex: number = 2;
  @Local vm: RecommendPageVM = new RecommendPageVM()
  // WindowStage生命周期变化的监听回调函数
  private windowStageEventCallback = (type: window.WindowStageEventType) => {
    const allPathStack = RouterUtils.getStack().getAllPathName()
    const lastPathName = allPathStack[allPathStack.length - 1];
    if (this.currentTabIndex === this.index && this.vm.tabModel.selectedIndex === TabBarType.VIDEO &&
      lastPathName === RouterMap.INDEX_PAGE
    ) {
      if (type === window.WindowStageEventType.RESUMED || type === window.WindowStageEventType.SHOWN) {
        this.vm.avPlayerManager.play(this.vm.currentIndex);
      } else if (type === window.WindowStageEventType.PAUSED || type === window.WindowStageEventType.HIDDEN) {
        this.vm.avPlayerManager.pause(this.vm.currentIndex);
      }
    }
  }

  // 切换视频头部tab
  @Monitor('currentTabIndex')
  onChangeTabIndex() {
    if (this.currentTabIndex === this.index) {
      if (this.vm.settingInfo.network.autoPlayTabRecommend) {
        this.vm.avPlayerManager.play(this.vm.currentIndex);
      }
    } else {
      this.vm.avPlayerManager.pause(this.vm.currentIndex);
    }
    this.vm.tabModel.showTabBar = true;
  }

  // 切换底部tab
  @Monitor('vm.tabModel.selectedIndex')
  onChangeSelectedIndex() {
    if (this.currentTabIndex === this.index) {
      let swiperPlayerIdx = [TabPageType.FOLLOW, TabPageType.FEATURED, TabPageType.RECOMMEND];
      if (this.vm.tabModel.selectedIndex === TabBarType.VIDEO && swiperPlayerIdx.includes(this.currentTabIndex)) {
        this.vm.avPlayerManager.play(this.vm.currentIndex);
      } else {
        this.vm.avPlayerManager.pause(this.vm.currentIndex);
      }
    }
  }

  aboutToAppear(): void {
    this.vm.setLanes();
    // 模拟首次进入页面时，判断是否展示网络异常页面
    this.vm.showExceptionPage = !this.vm.networkModel.isNetworkAvailable
    // 获取数据
    this.vm.initVideoListDataSource();
    // 监听 windowStageEvent
    this.vm.windowStageModel.windowStageEventListeners.delete('recommendPage');
    this.vm.windowStageModel.windowStageEventListeners.set('recommendPage', (type) => {
      this.windowStageEventCallback(type)
    })
    // 监听路由变化的回调
    this.vm.navRouteModel.navDestinationUpdateListeners.delete('leaveVideoListListener')
    this.vm.navRouteModel.navDestinationUpdateListeners.set('leaveVideoListListener', (info) => {
      if (this.vm.navRouteModel.videoPauseByRoutePage.includes(info.name) &&
        info.state === uiObserver.NavDestinationState.ON_WILL_SHOW
      ) {
        this.vm.avPlayerManager.pause(this.vm.currentIndex);
        return;
      }
      if (info.name === RouterMap.INDEX_PAGE && this.vm.tabModel.selectedIndex === TabBarType.VIDEO &&
        info.state === uiObserver.NavDestinationState.ON_WILL_SHOW &&
        this.index === this.currentTabIndex
      ) {
        this.vm.avPlayerManager.play(this.vm.currentIndex);
      }
    })
  }

  build() {
    Column() {
      if (this.vm.showExceptionPage) {
        if (!this.vm.loading) {
          NetworkExceptionView({
            textFontColor: $r('sys.color.font_primary'),
            btnFontColor: $r('sys.color.font_primary'),
            btnBorderColor: $r('sys.color.font_primary'),
            refreshNetwork: () => {
              this.vm.loading = true;
              // 模拟请求判断网络能否使用
              let networkUtil = NetworkUtil.getInstance()
              networkUtil.handleNetworkAvailable();
              setTimeout(() => {
                // 模拟
                if (this.vm.networkModel.isNetworkAvailable) {
                  this.vm.initVideoListDataSource()
                  this.vm.showExceptionPage = false;
                } else {
                  this.vm.loading = false
                }
              }, 100)
            },
          })
        }
      } else {
        Refresh({ refreshing: $$this.vm.isRefreshing, builder: this.customRefreshComponent }) {
          WaterFlow({ scroller: this.vm.listScroller }) {
            LazyForEach(this.vm.videoListDataSource, (item: VideoNewsData, index: number) => {
              FlowItem() {
                VideoCard({
                  currentIndex: this.vm.currentIndex,
                  index: index,
                  videoData: item,
                  isShown: this.currentTabIndex === this.index && this.vm.tabModel.selectedIndex === TabBarType.VIDEO,
                  videoNetwork: this.vm.networkModel as VideoNetworkModel,
                  videoNetworkSetting: this.vm.settingInfo.network as VideoNetworkSetting,
                  currentBreakpoint: this.vm.breakPointModel.currentBreakpoint,
                  playerStateCallback: (state: string, id: string) => {
                    this.vm.onPlayerStateListen(state, id)
                  },
                  setUseMobileData: () => {
                    this.vm.networkModel.canUseMobileData = true
                  },
                  videoInfoViewBuilder: () => {
                    this.videoCardInfoView(item)
                  },
                  onClickEvent: (avPlayerController: AVPlayerController | undefined, callback: Function) => {
                    let param: Record<string, string | AVPlayerController | undefined> = {
                      'newsId': item.getVideoId(),
                      'avPlayerController': avPlayerController,
                    }
                    avPlayerController!.avPlayer?.pause().catch((e: BusinessError) => {
                      Logger.error(TAG, 'pause fail, error: ' + JSON.stringify(e));
                    });
                    // 监听页面跳转
                    this.vm.navRouteModel.navDestinationUpdateListeners.delete('clickVideoCardListener');
                    this.vm.navRouteModel.navDestinationUpdateListeners.set('clickVideoCardListener', (info) => {
                      // 离开推荐列表时，处理视频是否播放
                      if (info.name === RouterMap.INDEX_PAGE && this.currentTabIndex === TabPageType.RECOMMEND &&
                        info.state === uiObserver.NavDestinationState.ON_WILL_SHOW &&
                        this.vm.tabModel.selectedIndex === TabBarType.VIDEO
                      ) {
                        this.vm.tabModel.showTabBar = true
                        callback()
                      }
                    })
                    // 跳转到详情页
                    RouterUtils.pushPathByName(RouterMap.VIDEO_DETAIL_PAGE, param, () => {
                      this.vm.isActive = true;
                    });
                    this.vm.isActive = false;
                  },
                  onPlayItem: (playIndex: number) => {
                    Logger.info(TAG, 'onPlayItem play video index is ' + playIndex)
                    this.vm.handleListScrollByUserClick(playIndex)
                  },
                })
              }
              .width(CommonConstants.FULL_PERCENT)
              .onAppear(() => {
                // 即将触底时提前增加数据，即执行数据预加载
                if (index + 5 === this.vm.videoListDataSource.totalCount()) {
                  this.vm.loadMore()
                }
              })
            }, (item: VideoNewsData, index: number) => JSON.stringify(item) + index)
            // 加载更多
            this.loadingBuilder()
          }
          .columnsTemplate(`repeat(${this.vm.lanesCount}, 1fr)`)
          .columnsGap(12)
          .rowsGap(8)
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .cachedCount(1)
          .scrollBar(BarState.Off)
          .friction(0.6)
          .edgeEffect(EdgeEffect.None)
          .padding({ left: this.vm.getListPadding(), right: this.vm.getListPadding() })
          .onWillScroll((scrollOffset: number) => {
            this.vm.yOffset += scrollOffset
          })
          .onScrollFrameBegin((offset: number) => {
            this.vm.isUserActionScroll = true;
            return { offsetRemain: offset };
          })
          .onScrollIndex((first: number, last: number) => {
            this.vm.handleScrollIndex(first, last)
          })
          .onScrollStop(() => {
            this.vm.handleScrollStop()
            this.vm.isUserActionScroll = false;
          })
          .onReachStart(() => {
            this.vm.isScrollStart = true;
          })
        }
        .layoutWeight(1)
        .pullToRefresh(true)
        .pullDownRatio(this.vm.ratio)
        .refreshOffset(64)
        .accessibilityLevel('no')
        .onRefreshing(() => {
          this.vm.refreshList()
        })
        .onStateChange((state: RefreshStatus) => {
          this.vm.refreshStatus = state;
        })
        .onOffsetChange((offset: number) => {
          this.vm.offsetChanged(offset)
        })
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({
      top: this.vm.windowModel.windowTopPadding + 56
    })
  }

  @Builder
  customRefreshComponent() {
    Stack() {
      if (this.vm.refreshStatus === RefreshStatus.Refresh) {
        LoadingProgress()
          .height(32)
      } else if (this.vm.refreshStatus === RefreshStatus.OverDrag) {
        Text('释放可刷新页面')
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Body_M'))
      } else if (this.vm.refreshStatus === RefreshStatus.Drag) {
        Text('下拉刷新')
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Body_M'))
      }
    }
    .align(Alignment.Bottom)
    .padding({ top: 16, bottom: 16 })
    .clip(true)
    .constraintSize({ minHeight: 32 })
    .width('100%')
  }

  @Builder
  loadingBuilder() {
    Row() {
      LoadingProgress()
        .width(24)
        .height(24)
        .color($r('sys.color.icon_secondary'))
      Text('正在获取更多内容')
        .fontColor($r('sys.color.font_primary'))
        .fontSize(12)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({ top: CommonConstants.PADDING_XL, bottom: CommonConstants.PADDING_XL })
    .justifyContent(FlexAlign.Center)
    .visibility(this.vm.isLoadingMore ? Visibility.Visible : Visibility.Hidden)
  }

  @Builder
  videoCardInfoView(item: VideoNewsData) {
    Column({ space: 2 }) {
      Text(item.title)
        .fontSize(16)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(500)
        .lineHeight(21)
        .maxLines(2)

      Row({ space: 12 }) {
        Text(item.author.authorNickName)
          .fontSize(12)
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(16)
        Text(TimeUtils.formatDate(item.createTime))
          .fontSize(12)
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(16)
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: CommonConstants.PADDING_L,
      top: CommonConstants.PADDING_S,
      right: CommonConstants.PADDING_L,
      bottom: CommonConstants.PADDING_S,
    })
  }
}
