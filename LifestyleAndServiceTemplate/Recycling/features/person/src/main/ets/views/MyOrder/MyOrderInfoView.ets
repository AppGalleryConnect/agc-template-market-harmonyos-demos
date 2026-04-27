import { OrderItem } from '../../viewmodel/MyOrderPageVM';
import { CopyBoardUtil } from '../../utils/CopyBoardUtil';

@ComponentV2
export struct MyOrderInfoView {
  @Param @Require order: OrderItem;
  @Param isExpand: boolean = false;

  aboutToAppear(): void {
  }

  build() {
    Column() {
      // 订单信息
      Row() {
        Text('订单信息')
          .font({ size: 16, weight: FontWeight.Medium })
          .fontColor('rgba(0, 0, 0, 0.9)')
          .margin({ left: 13 })
      }.height(50).alignItems(VerticalAlign.Center)

      // 回收价格和优惠
      Column() {
        // 收款方式
        Row() {
          Text('收款方式').font({ size: 12, weight: FontWeight.Regular }).fontColor('rgba(0, 0, 0, 0.6)')

          Column() {
            Text(`${this.order.payType.split('|')[0]}`)
              .font({ size: 12, weight: FontWeight.Regular })
              .fontColor('rgba(0, 0, 0, 0.9)')

            Text(`${this.order.payType.split('|')[1]}`)
              .font({ size: 12, weight: FontWeight.Regular })
              .fontColor('rgba(0, 0, 0, 0.9)')
          }.height(32).alignItems(HorizontalAlign.End)

        }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 }).alignItems(VerticalAlign.Top)

        // 订单编号
        Row() {
          Text('订单编号').font({ size: 12, weight: FontWeight.Regular }).fontColor('rgba(0, 0, 0, 0.6)')

          Text(`${this.order.id.toString()} | 复制`)
            .font({ size: 12, weight: FontWeight.Regular })
            .fontColor('rgba(0, 0, 0, 0.9)')
            .onClick(() => {
              // 复制到粘贴板
              CopyBoardUtil.instance.copy(this.order.id.toString(), '订单编号')
            })
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 })

        // 创建时间
        Row() {
          Text('创建时间').font({ size: 12, weight: FontWeight.Regular }).fontColor('rgba(0, 0, 0, 0.6)')

          Text(`${this.order.time}`).font({ size: 12, weight: FontWeight.Regular }).fontColor('rgba(0, 0, 0, 0.9)')
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 })

        if (this.isExpand) {
          // 取消时间
          Row() {
            Text('取消时间').font({ size: 12, weight: FontWeight.Regular }).fontColor('rgba(0, 0, 0, 0.6)')

            Text(`${this.order.cancelTime}`)
              .font({ size: 12, weight: FontWeight.Regular })
              .fontColor('rgba(0, 0, 0, 0.9)')
          }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 })

          // 取件信息
          Row() {
            Text('取件信息').font({ size: 12, weight: FontWeight.Regular }).fontColor('rgba(0, 0, 0, 0.6)')

            Text(`${this.order.orderConfig.visitAddress.user} ${this.order.orderConfig.visitAddress.phone}`)
              .font({ size: 12, weight: FontWeight.Regular })
              .fontColor('rgba(0, 0, 0, 0.9)')
          }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 })

          // 取件地址
          Row() {
            Text('取件地址').font({ size: 12, weight: FontWeight.Regular }).fontColor('rgba(0, 0, 0, 0.6)')

            Text(`${this.order.orderConfig.visitAddress.address}`)
              .width('60%')
              .maxLines(2)
              .textAlign(TextAlign.End)
              .font({ size: 12, weight: FontWeight.Regular })
              .fontColor('rgba(0, 0, 0, 0.9)')
          }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 })
        }

      }.width('100%').padding({ left: 12, right: 12 }).margin({ bottom: 16 })

    }.width('100%').backgroundColor(Color.White).borderRadius(8).alignItems(HorizontalAlign.Start)
  }
}