import { CommonLoading, CommonScroll, ContainerColumn, NavTitleBar } from 'lib_widget';
import { buildButtonList, buildOrderInfoCard } from '../components/OrderInfoCard';
import { buildNoOrderCard } from '../components/NoOrderCard';
import { OrderItem } from 'lib_network';
import { OrderListPageVM } from '../viewmodels/OrderListPageVM';

@ComponentV2
struct OrderSearchPage {
  vm: OrderListPageVM = new OrderListPageVM();

  build() {
    NavDestination() {
      NavTitleBar({
        title: '订单搜索',
      })

      this.buildSearch();

      CommonScroll({ bgColor: $r('app.color.background_color_grey') }) {
        if (this.vm.isLoading) {
          CommonLoading()
        } else {
          Column() {
            if ( this.vm.keywords) {
              if(!this.vm.orderList.length){
                buildNoOrderCard()
              }
              List() {
                Repeat(this.vm.orderList)
                  .each((ri: RepeatItem<OrderItem>) => {
                    ListItem() {
                      ContainerColumn() {
                        buildOrderInfoCard(ri.item)
                        buildButtonList(ri.item.orderInfo, ControlSize.SMALL, (actionType) => {
                          this.vm.handleOrderItem(ri.item, actionType)
                        })
                      }
                    }
                  })
              }
              .cachedCount(4)
              .layoutWeight(1)
              .edgeEffect(EdgeEffect.Spring)
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
              .scrollBar(BarState.Off)
              .onReachEnd(() => {
                this.vm.getOrderList()
              })
            }
          }
        }
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background_color_grey'))
  }

  @Builder
  buildSearch() {
    Row() {
      Search({
        value: $$this.vm.searchKey,
        controller: this.vm.searchController,
        placeholder: '输入商品名称',
      })
        .width('100%')
        .backgroundColor($r('app.color.background_color_primary'))
        .borderColor($r('sys.color.font_fourth'))
        .defaultFocus(true)
        .placeholderColor($r('app.color.font_color_level2'))
        .caretStyle({ color: $r('app.color.theme_color') })
        .onSubmit((value) => {
          this.vm.searchOrder(value);
        })
    }
    .width($r('app.string.size_percent_full'))
    .padding({
      left: $r('app.float.space_l'),
      right: $r('app.float.space_l'),
    })
  }
}

@Builder
export function buildOrderSearchPage() {
  OrderSearchPage()
}


