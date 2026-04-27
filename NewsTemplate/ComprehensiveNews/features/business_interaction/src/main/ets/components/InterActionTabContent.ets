import { CommonConstants } from 'lib_common'
import { LoadMoreFooter } from 'lib_flex_layout';
import { NewsResponse } from 'lib_news_api';
import { Topic } from 'module_post';
import { TabEnum, TabItem } from '../common/Constants';
import { InteractionViewModel } from '../viewmodels/InteractionViewModel';
import { InteractionFeedCard } from './InteractionFeedCard'
import { NoWatcher } from './NoWatcher';

@ComponentV2
export struct InterActionTabContent {
  @Param @Require resource: TabItem
  @Param @Require selectedId: number
  @Param topic: Topic = { id: '', title: '' }
  @Param paddingTop: number = 16;
  @Local vm: InteractionViewModel = new InteractionViewModel(this.getUIContext());

  @Monitor('selectedId')
  setSelectId() {
    this.vm.selectedId = this.selectedId;
    if (this.selectedId === this.resource.id) {
      this.vm.refresh()
    }
  }

  aboutToAppear(): void {
    this.vm.init(this.resource.id);
    this.vm.setOnListenRefresh();
    this.vm.setTopic(this.topic);
    this.vm.selectedId = this.selectedId;
  }

  aboutToDisappear(): void {
    this.vm.setOffListenRefresh()
  }

  @Builder
  loadMoreFooter() {
    LoadMoreFooter({ 'isLoading': this.vm.isLoading })
  }

  build() {
    Column() {
      if (!this.vm.interactionList.length && this.resource.id === TabEnum.Watch) {
        Column() {
          NoWatcher()
        }
        .justifyContent(FlexAlign.Center)
        .height(CommonConstants.FULL_PERCENT)
        .width(CommonConstants.FULL_PERCENT)
      }
      Refresh({ refreshing: $$this.vm.isRefreshing }) {
        WaterFlow({ footer: this.loadMoreFooter, scroller: this.vm.scroller }) {
          Repeat(this.vm.interactionList)
            .each((repeatItem: RepeatItem<NewsResponse>) => {
              FlowItem() {
                InteractionFeedCard({
                  resource: this.resource,
                  cardInfo: repeatItem.item,
                  index: repeatItem.index,
                })
              }
              .id('action_flow' + this.resource.id + repeatItem.index)
              .width(CommonConstants.FULL_PERCENT)
              .backgroundColor($r('sys.color.background_primary'))
              .borderRadius(16)
              .clip(true)
              .padding(CommonConstants.PADDING_M)
            })
            .key((item: NewsResponse) => this.vm.getEachId(item))
            .virtualScroll()
        }
        .cachedCount(2)
        .onReachEnd(() => {
          // 滚动到列表底部时触发加载
          this.vm.loadMore()
        })
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .edgeEffect(EdgeEffect.Spring)
        .columnsTemplate(`repeat(${this.vm.lanesCount.getLanes()}, 1fr)`)
        .columnsGap(16)
        .rowsGap(12)
        .scrollBar(BarState.Off)
        .layoutWeight(1)
        .nestedScroll({
          scrollForward: NestedScrollMode.PARENT_FIRST,
          scrollBackward: NestedScrollMode.SELF_FIRST,
        })
        .padding({
          left: this.vm.lanesCount.breakpointModel.pagePadding,
          right: this.vm.lanesCount.breakpointModel.pagePadding,
        })
        .margin({ top: this.paddingTop })
      }
      .layoutWeight(1)
      .pullToRefresh(true)
      .accessibilityLevel('no')
      .onRefreshing(() => {
        this.vm.refresh()
      })
    }
    .layoutWeight(1)
  }
}