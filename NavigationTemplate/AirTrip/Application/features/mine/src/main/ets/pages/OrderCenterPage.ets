import { AppRouter, BaseTabBarItem, CommonFuncResult, OrderApi, OrderInfo, OrderListResult } from 'common'
import { BaseTitle, GlobalDialog } from 'components'
import { OrderListView } from '../components/OrderListView'

@Builder
export function orderCenterPageBuilder() {
  OrderCenterPage()
}

@ComponentV2
export struct OrderCenterPage {
  // 当前tabIndex
  @Local categoryTabIndex: number = 0
  // 当前展示的列表类型
  @Local currentType: string = ''
  // 订单列表
  @Local orderList: OrderInfo[] = []

  tabList: BaseTabBarItem[] = [
    new BaseTabBarItem('', '全部'),
    new BaseTabBarItem('1', '待支付'),
    new BaseTabBarItem('2', '待出行')
  ]

  getOrderList() {
    GlobalDialog.showLoadingDialog()
    OrderApi.getOrderList(this.currentType).then((res) => {
      let result = res.result as OrderListResult
      if (result.ret.code === 0) {
        this.orderList = result.result
      }
    }).finally(() => {
      GlobalDialog.close()
    })
  }

  // 删除订单
  deleteOrder(item: OrderInfo, index: number) {
    GlobalDialog.showTextDialog({
      title: '删除订单',
      content: '请确认是否删除订单？',
      primaryButName: '确定',
      secondaryButName: '取消',
      primaryButAction: () => {
        OrderApi.deleteOrder(item).then((res) => {
          let result = res.result as CommonFuncResult
          if (result.ret.code === 0 && (result.result === 1 || result.result === 0)) {
            GlobalDialog.showToast('删除成功')
            this.orderList.splice(index, 1)
          } else {
            GlobalDialog.showToast('删除失败')
          }
        }).catch(() => {
          GlobalDialog.showToast('删除失败')
        })
        GlobalDialog.close()
      },
      secondaryButAction: () => {
        GlobalDialog.close()
      }
    })
  }

  // 取消订单
  cancelOrder(item: OrderInfo, index: number) {
    GlobalDialog.showTextDialog({
      title: '取消订单',
      content: '请确认是否取消订单？',
      primaryButName: '确定',
      secondaryButName: '取消',
      primaryButAction: () => {
        OrderApi.cancelOrder(item).then((res) => {
          let result = res.result as CommonFuncResult
          if (result.ret.code === 0 && (result.result === 1 || result.result === 0)) {
            this.getOrderList()
            GlobalDialog.showToast('取消成功')
          } else {
            GlobalDialog.showToast('取消失败')
          }
        }).catch(() => {
          GlobalDialog.showToast('取消失败')
        })
        GlobalDialog.close()
      },
      secondaryButAction: () => {
        GlobalDialog.close()
      }
    })
  }

  build() {
    NavDestination() {
      Column() {
        BaseTitle({
          title: '订单中心',
          bgColor: $r('sys.color.white'),
          showBackBtn: true,
          onBack: () => {
            AppRouter.pop()
          }
        })

        Tabs({index: this.categoryTabIndex}) {
          ForEach(this.tabList, (item: BaseTabBarItem) => {
            TabContent() {
              OrderListView({
                orderList: this.orderList,
                refreshList: () => {
                  this.getOrderList()
                },
                deleteOrderItem: (orderData: OrderInfo, index: number) => {
                  this.deleteOrder(orderData, index)
                },
                cancelOrderItem: (orderData: OrderInfo, index: number) => {
                  this.cancelOrder(orderData, index)
                },
                payOrder: (orderData: OrderInfo) => {
                  AppRouter.push({
                    url: 'PayPage',
                    param: orderData
                  })
                }
              })
            }
            .tabBar(
              new SubTabBarStyle(item.text)
                .labelStyle({
                  unselectedColor: $r('sys.color.black'),
                  selectedColor: '#466DFA',
                  font: {
                    size: 16,
                  }
                })
                .indicator({
                  color: '#466DFA',
                  height: 2,
                  width: 50,
                  borderRadius: 2,
                  marginTop: 15,
                })
            )
          })
        }
        .width('100%')
        .layoutWeight(1)
        .barHeight(56)
        .scrollable(false)
        .animationMode(AnimationMode.NO_ANIMATION)
        .onChange((index: number) => {
          this.categoryTabIndex = index
          this.currentType = index ? '' + index : ''
          this.getOrderList()
        })
        .barBackgroundColor($r('sys.color.white'))
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.color_page_bg'))
    .onReady((cxt) => {
      this.categoryTabIndex = Number(cxt.pathInfo.param as string) || 0
      this.currentType = cxt.pathInfo.param as string
    })
    .onWillShow(() => {
      this.getOrderList()
    })
  }
}