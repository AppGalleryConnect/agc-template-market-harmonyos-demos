import { CommonEmpty } from 'lib_foundation'
import { OrderInfo } from '../models/Model';
import { QueryPageVM } from '../viewModels/QueryPageVM'
import { OrderItemCard } from './OrderItemCard';

@ComponentV2
export struct OrderListView {
  @Param list: OrderInfo[] = [];
  @Param index: number = 0;
  vm: QueryPageVM = QueryPageVM.instance;
  // 跟手滑动系数
  @Local ratio: number = 1;
  // 下拉最到高度
  @Local maxRefreshingHeight: number = 140.0;
  // 下拉刷新组件的状态
  @Local refreshStatus: RefreshStatus = RefreshStatus.Inactive;

  build() {
    Refresh({ refreshing: $$this.vm.isRefreshing, builder: this.customRefreshBuilder() }) {
      if (this.list.length > 0) {
        WaterFlow({ layoutMode: WaterFlowLayoutMode.SLIDING_WINDOW, footer: this.footerBuilder() }) {
          Repeat(this.list)
            .each((orderInfo: RepeatItem<OrderInfo>) => {
              FlowItem() {
                OrderItemCard({
                  orderInfo: orderInfo.item,
                })
              }
              .width('100%')
            })
            .key((item: OrderInfo) => JSON.stringify(item))
            .virtualScroll()
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .columnsTemplate(`repeat(${this.vm.waterFlowLanes}, 1fr)`)
        .columnsGap(12)
        .rowsGap(8)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      } else {
        Column() {
          this.emptyView()
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .pullToRefresh(true)
    .onStateChange((state: RefreshStatus) => {
      this.refreshStatus = state;
    })
    .onOffsetChange((offset: number) => {
      // 越接近最大距离，下拉跟手系数越小
      this.ratio = 1 - Math.pow(offset / this.maxRefreshingHeight, 3);
    })
    .onRefreshing(() => {
      if (this.vm.selectedIndex === this.index) {
        this.vm.queryOrderList(true)
      }
    })
  }

  @Builder
  customRefreshBuilder() {
    Stack() {
      if (this.refreshStatus === RefreshStatus.OverDrag ||
        this.refreshStatus === RefreshStatus.Drag) {
        LoadingProgress()
          .height(32)
      }
    }
    .align(Alignment.Bottom)
    .padding({ top: 16, bottom: 16 })
    .clip(true)
    .constraintSize({ minHeight: 32 })
    .width('100%')
  }

  @Builder
  emptyView() {
    Column() {
      CommonEmpty({
        emptyDesc: '暂无快递',
        emptyIcon: $r('app.media.ic_send_null'),
      })
    }
    .width('100%')
    .height(232)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  footerBuilder() {
    Row().width('100%').height(12)
  }
}


