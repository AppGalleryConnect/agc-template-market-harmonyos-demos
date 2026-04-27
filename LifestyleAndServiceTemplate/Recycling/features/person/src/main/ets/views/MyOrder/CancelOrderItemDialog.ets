import { promptAction } from '@kit.ArkUI'
import { RouterMap, TimeUtil } from 'common'
import { phoneRouterControl } from 'oh_router'
import { BuildMyOrderDetailPage } from '../../pages/MyOrderDetailPage'
import { MyOrderDetailPageInfo, MyOrderPageVM, OrderItem } from '../../viewmodel/MyOrderPageVM'

@ComponentV2
export struct CancelOrderItemDialog {
  @Param @Require vm: MyOrderPageVM
  @Param @Require orderInfo: OrderItem
  // 跳转来源
  @Param fromPage: string = 'MyOrderPage'

  build() {
    Column() {
      // 标题
      Text('是否取消订单')
        .width('100%')
        .height(56)
        .fontSize(20)
        .fontColor('rgba(0, 0, 0, 0.90)')
        .textAlign(TextAlign.Center)
        .margin({ top: 16, bottom: 16 })

      Row() {
        Text('取消')
          .height(40)
          .fontSize(16)
          .fontColor('rgba(0, 0, 0, 0.6)')
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .margin({ right: 8 })
          .border({ color: 'rgba(0, 0, 0, 0.2)', width: 1, radius: 22 })
          .backgroundColor('rgba(255, 255, 255, 1)')
          .onClick(() => {
            promptAction.closeCustomDialog(this.vm.cancelDialogId)
          })

        Text('确定')
          .height(40)
          .fontSize(16)
          .fontColor('rgba(255, 255, 255, 1)')
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .backgroundColor('rgba(255, 75, 75, 1)')
          .borderRadius(22)
          .onClick(() => {
            // 写入取消时间
            this.orderInfo.cancelTime = TimeUtil.formatDate(Date.now(), 'yyyy-MM-dd  HH:mm:ss')
            // 修改当前的item状态
            if (this.orderInfo.status === '待发货') {
              // 修改订单状态
              this.orderInfo.status = '已取消-待发货'
              if (this.fromPage === 'MyOrderPage') {
                // 跳转：已取消订单详情
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.MY_ORDER_DETAIL_PAGE,
                  builder: wrapBuilder(BuildMyOrderDetailPage),
                  param: this.buildJumpPageParam()
                })
              } else if (this.fromPage === 'MyOrderDetailPage') {
                // 跳转：已取消订单详情
                phoneRouterControl.replacePage({
                  pageName: RouterMap.MY_ORDER_DETAIL_PAGE,
                  builder: wrapBuilder(BuildMyOrderDetailPage),
                  param: this.buildJumpPageParam()
                })
              }
            } else {
              if (this.fromPage === 'MyOrderPage') {
                this.orderInfo.status = this.orderInfo.status + '-取消订单'
              } else if (this.fromPage === 'MyOrderDetailPage') {
                this.orderInfo.status = this.orderInfo.status + '-取消订单'
                phoneRouterControl.popPage()
              }
            }
            promptAction.closeCustomDialog(this.vm.cancelDialogId)
            // 给出提示
            promptAction.showToast({
              message: '订单已取消成功'
            })
          })
      }.width('100%').margin({ bottom: 24 })

    }.width('100%').padding({ left: 16, right: 16 })
  }

  /**
   * 构建跳转参数
   */
  buildJumpPageParam() {
    // 封装跳转页面的参数对象
    const paramInfo: MyOrderDetailPageInfo = new MyOrderDetailPageInfo()
    paramInfo.orderInfo = this.orderInfo
    paramInfo.orderProcessType = '取消订单'
    paramInfo.orderButtonType = 'delete'
    paramInfo.isExpand = true
    return paramInfo
  }
}