import { RouterMap, routerStack } from 'lib_foundation'
import { OrderItem, RedemptionOrder } from 'lib_network'
import { RedemptionOrderCard } from '../components/RedemptionOrderCard'
import { RedemptionListVM } from '../viewmodels/RedemptionListVM'
import { buildPointsAddressSheetOptions } from '../utils/PointsAddressUtil'
import { RedemptionOrderStatus } from '../commons/Enums'

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
      List() {
        ForEach(this.vm.list, (order: RedemptionOrder) => {
          ListItem() {
            RedemptionOrderCard({
              order,
              onClickCard: () => {
                routerStack.pushPath({
                  name: RouterMap.POINTS_REDEMPTION_INFO,
                  param: order.orderId,
                  onPop: () => {
                    this.vm.loadList(this.vm.currentTabIndex)
                  },
                })
              },
              onModifyAddress: () => {
                this.openAddressSheet(order)
              },
              onUrge: () => {
                this.vm.urgeShipment(order.orderId)
              },
              onConfirmReceipt: () => {
                AlertDialog.show({
                  title: '确认收货',
                  message: '确认已收到商品？',
                  primaryButton: {
                    value: '取消',
                    action: () => {},
                  },
                  secondaryButton: {
                    value: '确认',
                    fontColor: $r('app.color.theme_color'),
                    action: () => {
                      this.vm.confirmReceipt(order.orderId)
                    },
                  },
                })
              },
              onDelete: () => {
                AlertDialog.show({
                  title: '删除订单',
                  message: '确认删除该兑换记录？',
                  primaryButton: {
                    value: '取消',
                    action: () => {},
                  },
                  secondaryButton: {
                    value: '删除',
                    fontColor: $r('app.color.theme_color'),
                    action: () => {
                      this.vm.deleteOrder(order.orderId)
                    },
                  },
                })
              },
              onViewExpress: order.status === RedemptionOrderStatus.PENDING_RECEIPT
                ? () => { this.navigateToExpress(order) }
                : () => {},
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

  private navigateToExpress(order: RedemptionOrder): void {
    const orderItemParam: OrderItem = {
      orderInfo: {
        status: 3,
        orderNo: order.orderId,
        addressInfo: order.addressInfo,
        orderTime: order.orderTime,
        originalPrice: order.product.price,
        finalPrice: order.product.price,
        discounts: [],
        receivingMethod: 1,
      },
      logisticInfo: order.logisticInfo ?? [],
      skuInfo: [],
    }
    routerStack.pushPath({ name: RouterMap.POINTS_EXPRESS_INFO, param: orderItemParam })
  }

  private openAddressSheet(order: RedemptionOrder): void {
    const options = buildPointsAddressSheetOptions({
      originalAddress: order.addressInfo,
      orderId: order.orderId,
      handleSubmitSuccess: () => {
        this.vm.loadList(this.vm.currentTabIndex)
      },
    })
    routerStack.pushPath({
      name: RouterMap.UPDATE_ADDRESS,
      param: options,
    })
  }
}
