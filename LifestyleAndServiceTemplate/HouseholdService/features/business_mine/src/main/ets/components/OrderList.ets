import { CommonConstants, FullOrderInfo, GridRowColSetting, OrderDetailList } from 'lib_foundation';
import { UIEmpty } from 'module_base';
import { IQueryListParam } from '../viewmodel/MyOrderVM';
import { OrderCard } from './OrderCard';

@ComponentV2
export struct OrderList {
  @Param breakpoint: string = '';
  @Param data: OrderDetailList = new OrderDetailList();
  @Param isRefreshing: boolean = false;
  @Param isLoading: boolean = false;
  @Event queryOrderList: (param?: IQueryListParam) => void = () => {
  };
  @Event refreshList: (param?: IQueryListParam) => void = () => {
  };

  build() {
    Column() {
      if (this.data.list.length) {
        Refresh({ refreshing: this.isRefreshing }) {
          Scroll() {
            Column({ space: 12 }) {
              ForEach(this.data.list, (v: FullOrderInfo) => {
                OrderCard({
                  breakpoint: this.breakpoint,
                  fullOrderInfo: v,
                  refreshList: () => {
                    this.queryOrderList({
                      showFullLoading: true,
                    });
                  },
                  jumpTab: (tabIndex: number) => {
                    this.queryOrderList({
                      tabIndex,
                      showFullLoading: true,
                    });
                  },
                })
              }, (item: FullOrderInfo) => JSON.stringify(item))
            }.width(CommonConstants.FULL_PERCENT)
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .padding({
            top: 12,
            bottom: 12,
            left: GridRowColSetting.getPageMargin(this.breakpoint),
            right: GridRowColSetting.getPageMargin(this.breakpoint)
          })
        }
        .onRefreshing(() => {
          this.refreshList({
            showFullLoading: false,
          });
        })
      }
      if (!this.isLoading && this.data.list.length === 0) {
        UIEmpty({ emptyDesc: '暂无订单', fg: 12 }).margin({ bottom: 100 })
      }
    }
  }
}