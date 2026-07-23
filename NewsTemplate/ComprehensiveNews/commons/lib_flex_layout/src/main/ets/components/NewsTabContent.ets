import { CommonConstants } from 'lib_common'
import { RequestListData } from 'lib_news_api';
import { emptyBuilder, NetworkExceptionView } from 'lib_widget';
import { NewsContentVM } from '../viewmodel/NewsContentVM';
import { NoLoginPage } from './NoLoginPage';
import { LoadMoreFooter } from './LoadMoreFooter';
import { FlexLayoutPage } from './FlexLayoutPage';
import { RendNewsInfo } from '../model/Model';

@ComponentV2
export struct NewsTabContent {
  @Param @Require channelItem: RendNewsInfo
  @Param rendNewsInfoList: RendNewsInfo[] = []
  @Param bgColor: ResourceStr = $r('sys.color.background_primary')
  @Local newsContentVM: NewsContentVM = new NewsContentVM()

  aboutToAppear(): void {
    this.newsContentVM.init(this.channelItem.id, this.rendNewsInfoList)
  }

  aboutToDisappear(): void {
    this.newsContentVM.emitterOff()
  }

  @Builder
  loadMoreFooter() {
    LoadMoreFooter({ 'isLoading': this.newsContentVM.isLoading, 'isHomePage': true })
  }

  build() {
    Column() {
      Column() {
        if (this.channelItem.id === 'follow' && !this.newsContentVM.userInfoModel.isLogin) {
          Column() {
            NoLoginPage()
          }
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('sys.color.background_primary'))
          .height(CommonConstants.FULL_PERCENT)
          .width(CommonConstants.FULL_PERCENT)
        }
      }

      Refresh({ refreshing: $$this.newsContentVM.isRefreshing }) {
        if (this.newsContentVM.showExceptionPage) {
          if (!this.newsContentVM.isRefreshing) {
            NetworkExceptionView({
              textFontColor: $r('sys.color.font_primary'),
              btnFontColor: $r('sys.color.font_primary'),
              btnBorderColor: $r('sys.color.font_primary'),
              refreshNetwork: () => {
                this.newsContentVM.reloadData()
              },
            })
          }
        } else if (!this.newsContentVM.isRefreshing && this.channelItem.newsList.totalCount() === 0) {
          emptyBuilder({
            fontSizeRatio: this.newsContentVM.settingInfo.fontSizeRatio,
          })
        } else {
          WaterFlow({ scroller: this.newsContentVM.scroller, footer: this.loadMoreFooter }) {
            LazyForEach(this.channelItem.newsList, (value: RequestListData, index: number) => {
              FlowItem() {
                FlexLayoutPage({
                  channelItem: this.channelItem,
                  setting: JSON.parse(value.navInfo.setting),
                  articles: value.articles,
                  extraInfo: value.extraInfo,
                  flowIndex: index,
                  ignoreNews: () => {
                    this.channelItem.newsList.deleteData(index);
                  },
                  ignoreAuthor: (authorId) => {
                    // 删除当前屏蔽的条目
                    this.channelItem.newsList.deleteData(index);
                    // 删除列表中该作者其他的条目
                    for (let indexLoop = this.channelItem.newsList.originDataArray.length - 1; indexLoop >= 0;
                      indexLoop--) {
                      const element = this.channelItem.newsList.getData(indexLoop);
                      if (element.articles[0]?.author.authorId === authorId) {
                        this.channelItem.newsList.deleteData(indexLoop);
                      }
                    }
                  },
                })
              }
              .backgroundColor($r('sys.color.background_primary'))
              .id('news_flow_' + this.channelItem.id + '_' + index + '_' + value.extraInfo.flexId)
            }, (value: RequestListData, index: number) => index + JSON.stringify(value.articles?.[0]))
          }
          .onReachEnd(
            // 防止回弹时额外触发
            this.newsContentVM.throttle(() => {
              // 滚动到列表底部时触发加载
              this.newsContentVM.loadMore(this.channelItem.newsList)
            }, 800),
          )
          .edgeEffect(EdgeEffect.Spring)
          .columnsTemplate(this.newsContentVM.isNeedTemplate(this.channelItem.id))
          .columnsGap(16)
          .rowsGap(12)
          .scrollBar(BarState.Off)
          .cachedCount(1)
          .parallelGesture(
            PinchGesture({ fingers: 2 })
              .onActionStart(() => this.newsContentVM.lanesGestureUtils.onActionStart())
              .onActionUpdate((event: GestureEvent) => this.newsContentVM.lanesGestureUtils.onActionUpdate(event))
              .onActionEnd(() => this.newsContentVM.lanesGestureUtils.onActionEnd()),
          )
        }
      }
      .pullToRefresh(true)
      .height(CommonConstants.FULL_PERCENT)
      .accessibilityLevel('no')
      .onRefreshing(() => {
        this.newsContentVM.refresh()
      })
    }
    .height(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Start)
  }
}