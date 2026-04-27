import { RouterMap, routerStack } from 'lib_foundation'
import { RedemptionOrder } from 'lib_network'
import { RedemptionOrderCard } from '../components/RedemptionOrderCard'
import { RedemptionListVM } from '../viewmodels/RedemptionListVM'
import { CommonConfirmDialog } from 'lib_widget'

@Builder
export function buildRedemptionListPage() {
  RedemptionListPage()
}

const TAB_LABELS: string[] = ['全部', '待发货', '待收货', '已完成']

@ComponentV2
struct RedemptionListPage {
  vm: RedemptionListVM = new RedemptionListVM()
  private tabController: TabsController = new TabsController()

  build() {
    NavDestination() {
      Column() {
        this.buildTabBarRow()
        Tabs({ barPosition: BarPosition.Start, controller: this.tabController, index: this.vm.currentTabIndex }) {
          ForEach(TAB_LABELS, (label: string, index: number) => {
            TabContent() {
              Column() {
                if (this.vm.isLoading) {
                  LoadingProgress().width(32)
                } else if (this.vm.currentTabIndex === index && !this.vm.isLoading) {
                  this.buildList()
                }
              }
              .layoutWeight(1)
            }
            .layoutWeight(1)
            .align(Alignment.Top)
            .width($r('app.string.size_percent_full'))
            .backgroundColor($r('app.color.background_color_grey'))
            .padding({ left: $r('app.float.space_l'), right: $r('app.float.space_l'), top: $r('app.float.space_l') })
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          }, (label: string) => label)
        }
        .layoutWeight(1)
        .width($r('app.string.size_percent_full'))
        .barHeight(0)
        .onChange((index: number) => {
          this.vm.loadList(index)
        })
      }
      .alignItems(HorizontalAlign.Start)
      .width($r('app.string.size_percent_full'))
      .layoutWeight(1)
    }
    .title('积分兑换记录')
    .backgroundColor($r('app.color.background_color_grey'))
    .onReady(() => {
      this.vm.loadList(0)
    })
  }

  @Builder
  buildTabBarRow() {
    Row() {
      ForEach(TAB_LABELS, (label: string, index: number) => {
        this.buildTabBar(label, index)
      }, (label: string) => label)
    }
    .padding({
      left: $r('app.float.space_l'),
      right: $r('app.float.space_l'),
    })
  }

  @Builder
  buildTabBar(label: string, index: number) {
    Button(label)
      .fontColor(this.vm.currentTabIndex === index
        ? $r('sys.color.font_on_primary')
        : $r('sys.color.font_primary'))
      .backgroundColor(this.vm.currentTabIndex === index
        ? $r('app.color.theme_color')
        : $r('app.color.background_color_button_grey'))
      .fontSize($r('sys.float.Body_M'))
      .height(36)
      .margin({
        right: $r('app.float.space_m'),
      })
      .onClick(() => {
        this.tabController.changeIndex(index)
      })
  }

  @Builder
  buildList() {
    if (this.vm.list.length === 0) {
      Column() {
        Text('暂无兑换记录')
          .fontSize($r('app.float.font_size_14'))
          .fontColor($r('app.color.font_color_level3'))
      }
      .width($r('app.string.size_percent_full'))
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List({ space: 12 }) {
        ForEach(this.vm.list, (order: RedemptionOrder) => {
          ListItem() {
            RedemptionOrderCard({
              order,
              onClickCard: () => {
                routerStack.pushPath({
                  name: RouterMap.USER_REDEMPTION_INFO,
                  param: order.orderId,
                  onPop: () => {
                    this.vm.loadList(this.vm.currentTabIndex)
                  },
                })
              },
              onModifyAddress: () => {
                this.vm.openAddressSheet(order)
              },
              onUrge: () => {
                this.vm.urgeShipment(order.orderId)
              },
              onConfirmReceipt: () => {
                CommonConfirmDialog.show({
                  content:'确认已收到商品？',
                  primaryTitle:'确认收货',
                  confirm:()=>{
                    this.vm.confirmReceipt(order.orderId)
                  }
                })
              },
              onDelete: () => {
                CommonConfirmDialog.show({
                  content:'确认删除该兑换记录？',
                  primaryTitle:'删除订单',
                  confirm:()=>{
                    this.vm.deleteOrder(order.orderId)
                  }
                })
              },
              onViewExpress: () => {
                this.vm.navigateToExpress(order)
              },
            })
          }
        }, (order: RedemptionOrder) => order.orderId)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
  }
}
