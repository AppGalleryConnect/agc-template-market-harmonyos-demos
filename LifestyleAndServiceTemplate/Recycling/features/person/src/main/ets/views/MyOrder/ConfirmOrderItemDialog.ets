import { promptAction } from '@kit.ArkUI'
import { phoneRouterControl } from 'oh_router'
import { MyOrderPageVM, OrderItem } from '../../viewmodel/MyOrderPageVM'

@ComponentV2
export struct ConfirmOrderItemDialog {
  @Param @Require vm: MyOrderPageVM
  @Param @Require orderInfo: OrderItem
  // 跳转来源
  @Param fromPage: string = 'MyOrderPage'

  build() {
    Column() {
      // 标题
      Text('是否确认收款')
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
            promptAction.closeCustomDialog(this.vm.confirmDialogId)
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
            // 修改当前的item状态
            if (this.orderInfo.status === '待处理-已质检-确认收款') {
              // 修改订单状态
              this.orderInfo.status = '已完成'
            }
            if (this.fromPage === 'MyOrderDetailPage') {
              phoneRouterControl.popPage()
            }
            promptAction.closeCustomDialog(this.vm.confirmDialogId)
            // 给出提示
            promptAction.showToast({
              message: '订单已确认收款'
            })
          })
      }.width('100%').margin({ bottom: 24 })

    }.width('100%').padding({ left: 16, right: 16 })
  }
}