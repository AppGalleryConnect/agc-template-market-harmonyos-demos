import { BreakpointNameEnum, CommonConstants, loadingPage, NetworkUtil, VideoLiveStatus } from 'lib_common';
import { NetworkExceptionView } from 'lib_widget';
import { LiveNoticePreview } from '../components/LiveNoticePreview';
import { LivestreamCard } from '../components/LivestreamCard';
import { VideoNewsData } from '../models/VideoModel';
import { LivestreamPageVM } from '../viewmodels/LivestreamPageVM';

@ComponentV2
export struct LivestreamPage {
  // tab页面的index
  @Param index: number = 3
  // 视频页里面的头部tabIndex
  @Param currentTabIndex: number = 3;
  vm: LivestreamPageVM = new LivestreamPageVM()

  async aboutToAppear(): Promise<void> {
    // 模拟首次进入页面时，判断是否展示网络异常页面
    this.vm.showExceptionPage = !this.vm.networkModel.isNetworkAvailable;
    this.vm.pageLoading = true;
    await this.vm.init();
    this.vm.pageLoading = false;
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
              setTimeout(async () => {
                // 模拟
                if (this.vm.networkModel.isNetworkAvailable) {
                  await this.vm.init()
                  this.vm.showExceptionPage = false;
                } else {
                  this.vm.loading = false
                }
              }, 100)
            },
          })
        }
      } else if (this.vm.pageLoading) {
        loadingPage()
      } else {
        Refresh({ refreshing: $$this.vm.isRefreshing, builder: this.customRefreshComponent }) {
          Scroll() {
            Column({ space: CommonConstants.SPACE_M }) {
              // 直播预告
              LiveNoticePreview({
                swiperData: this.vm.livestreamPreviewList,
              })

              // 直播Banner
              Row() {
                this.liveBannerView()
              }

              // 直播预约
              Column() {
                this.liveTitle('即将直播')
                this.liveReservationListView()
              }
              .width(CommonConstants.FULL_PERCENT)
              .visibility(this.vm.liveReservationList.length ? Visibility.Visible : Visibility.None)

              // 正在直播
              Column() {
                this.liveTitle('正在直播')
                this.liveListView()
              }
              .width(CommonConstants.FULL_PERCENT)
              .visibility(this.vm.liveList.length ? Visibility.Visible : Visibility.None)

              // 精彩回放
              Column() {
                this.liveTitle('精彩回放')
                this.liveHighlightsView()
              }
              .width(CommonConstants.FULL_PERCENT)
            }
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.Start)
            .padding({
              bottom: CommonConstants.PADDING_L,
            })
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .align(Alignment.Top)
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
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
    .padding({
      left: CommonConstants.PADDING_L,
      top: this.vm.windowModel.windowTopPadding + 56,
      right: CommonConstants.PADDING_L,
    })
  }

  @Builder
  liveBannerView() {
    Swiper() {
      Repeat(this.vm.liveBannerList)
        .virtualScroll()
        .key((item: VideoNewsData) => item.id)
        .each((item: RepeatItem<VideoNewsData>) => {
          LivestreamCard({
            cardData: item.item,
            liveStatus: item.index,
            imgBorderRadius: 16,
            titleFontSize: 16,
          })
        })
    }
    .displayCount(this.vm.getDisplayCount())
    .itemSpace(12)
    .loop(false)
    .indicator(false)
  }

  @Builder
  liveTitle(title: string) {
    Row() {
      Text(title)
        .fontWeight(700)
        .fontColor($r('sys.color.font_primary'))
        .fontSize(18)
        .lineHeight(24)
    }
    .width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Start)
    .padding({ top: CommonConstants.PADDING_M, bottom: CommonConstants.PADDING_S })
  }

  @Builder
  liveListView() {
    List({
      space: this.vm.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ?
        CommonConstants.SPACE_L : CommonConstants.SPACE_XL,
    }) {
      Repeat(this.vm.liveList)
        .virtualScroll()
        .key((item: VideoNewsData) => item.id)
        .each((item: RepeatItem<VideoNewsData>) => {
          ListItem() {
            LivestreamCard({
              cardData: item.item,
              liveStatus: VideoLiveStatus.LIVE,
            })
          }
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height('auto')
    .edgeEffect(EdgeEffect.None)
    .scrollBar(BarState.Off)
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST,
    })
    .lanes(
      this.vm.lanesOptions.getValue(this.vm.breakPointModel.currentBreakpoint),
      this.vm.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ? 8 : 12,
    )
  }

  @Builder
  liveReservationListView() {
    Swiper() {
      Repeat(this.vm.liveReservationList)
        .virtualScroll()
        .key((item: VideoNewsData) => item.id)
        .each((item: RepeatItem<VideoNewsData>) => {
          LivestreamCard({
            cardData: item.item,
            liveStatus: VideoLiveStatus.FUTURE,
          })
        })
    }
    .displayCount(this.vm.lanesOptions.getValue(this.vm.breakPointModel.currentBreakpoint))
    .itemSpace(12)
    .loop(false)
    .indicator(false)
  }

  @Builder
  liveHighlightsView() {
    List({
      space: this.vm.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ?
        CommonConstants.SPACE_L : CommonConstants.SPACE_XL,
    }) {
      Repeat(this.vm.liveHighlightsList)
        .virtualScroll()
        .key((item: VideoNewsData) => item.id)
        .each((item: RepeatItem<VideoNewsData>) => {
          ListItem() {
            LivestreamCard({
              cardData: item.item,
              liveStatus: VideoLiveStatus.EXPIRED,
            })
          }
          .padding({ bottom: item.index === this.vm.liveHighlightsList.length - 1 ? 100 : 0})
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height('auto')
    .edgeEffect(EdgeEffect.None)
    .scrollBar(BarState.Off)
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST,
    })
    .lanes(
      this.vm.lanesOptions.getValue(this.vm.breakPointModel.currentBreakpoint),
      this.vm.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ? 8 : 12,
    )
  }

  @Builder
  customRefreshComponent() {
    Stack() {
      LoadingProgress()
        .height(32)
    }
    .align(Alignment.Bottom)
    .padding({ top: 16, bottom: 16 })
    .clip(true)
    .constraintSize({ minHeight: 32 })
    .width('100%')
  }
}