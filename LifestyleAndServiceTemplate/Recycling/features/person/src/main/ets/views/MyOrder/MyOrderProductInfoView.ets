import { OrderItem } from '../../viewmodel/MyOrderPageVM';

@ComponentV2
export struct MyOrderProductInfoView {
  @Param @Require order: OrderItem;

  build() {
    Column() {
      // 商品信息
      Row() {
        Text('商品信息')
          .font({ size: 16, weight: FontWeight.Medium })
          .fontColor('rgba(0, 0, 0, 0.9)')
          .margin({ left: 13 })
      }.height(50).alignItems(VerticalAlign.Center)

      // 商品图片和名称介绍
      Row() {
        Row() {
          Image(this.order.image).width(36).height(41)
        }
        .width(50)
        .height(50)
        .border({ width: 1, color: 'rgba(0, 0, 0, 0.1)', radius: 8 })
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)

        // 商品名称
        Column() {
          Text(this.order.name)
            .font({ size: 14, weight: FontWeight.Regular })
            .fontColor('rgba(0, 0, 0, 0.9)')
            .margin({ bottom: 2 })

          Text(this.order.selections || '国行 正常开机进入桌面 ID账号可退出')
            .font({ size: 10, weight: FontWeight.Regular })
            .fontColor('rgba(0, 0, 0, 0.4)')
        }.layoutWeight(1).margin({ left: 12, right: 12 }).height('100%').alignItems(HorizontalAlign.Start)
      }.width('100%').height(50).padding({ left: 12 }).margin({ bottom: 16 })

      // 回收价格和优惠
      Column() {
        // 回收价格
        Row() {
          Text('回收价').font({ size: 12, weight: FontWeight.Regular }).fontColor('rgba(0, 0, 0, 0.6)')

          Text(`¥${this.order.refundPrice.toString()}`)
            .font({ size: 12, weight: FontWeight.Medium })
            .fontColor('rgba(0, 0, 0, 0.9)')
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 })

        // 首单优惠
        Row() {
          Text('首单优惠').font({ size: 12, weight: FontWeight.Regular }).fontColor('rgba(0, 0, 0, 0.6)')

          Text(`+¥${(this.order.price - this.order.refundPrice).toString()}`)
            .font({ size: 12, weight: FontWeight.Medium })
            .fontColor('rgba(255, 75, 75, 1)')
        }.width('100%').justifyContent(FlexAlign.SpaceBetween)
      }.width('100%').padding({ left: 12, right: 12 }).margin({ bottom: 25 })

      // 商品预估价
      Row() {
        Text('商品预估价')
          .font({ size: 14, weight: FontWeight.Regular })
          .fontColor('rgba(0, 0, 0, 0.9)')
          .margin({ right: 6 })

        Text('¥').fontColor('rgba(255, 75, 75, 1)').font({ size: 18, weight: FontWeight.Regular }).margin({ top: 3 })

        Text(this.order.price.toFixed(2))
          .fontColor('rgba(255, 75, 75, 1)')
          .font({ size: 18, weight: FontWeight.Medium })
      }.width('100%').padding({ left: 12, right: 12, bottom: 16 }).justifyContent(FlexAlign.End)

    }.width('100%').backgroundColor(Color.White).borderRadius(8).alignItems(HorizontalAlign.Start)
  }
}
