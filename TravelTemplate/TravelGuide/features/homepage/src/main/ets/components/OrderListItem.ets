import { phoneRouterControl } from 'oh_router';
import { TValueType } from 'common';
import { OrderListItemConfig } from '../common/model';


/**
 * 订单列表项组件
 */
@ComponentV2
export struct OrderListItem {
  @Param @Require config: OrderListItemConfig
  @Param index: number = 0

  build() {
    Row() {
      Row() {
        Column() {
          Row() {
            Text() {
              if (this.config.discountPrice && this.index === 0) {
                Span('¥')
                  .fontSize(12)
                  .fontColor('#FF4A26')
                Span(this.config.totalPrice.toString())
                  .fontSize(22)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FF4A26')
                Span('已优惠¥' + this.config.discountPrice.toString())
                  .fontSize(10)
                  .fontColor('#FF4A26')
              } else {
                Span('¥')
                  .fontSize(12)
                  .fontColor('#FF4A26')
                Span(this.config.totalPrice.toString())
                  .fontSize(22)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FF4A26')
              }
            }
          }
          .margin({ bottom: 6 })
          .justifyContent(FlexAlign.Start)

          ForEach(this.config.description, (desc: string, descIndex: number) => {
            Row() {
              Text(desc)
                .fontSize(12)
                .fontColor('#000000')
                .opacity(0.4)
            }
            .margin({ bottom: descIndex < this.config.description.length - 1 ? 4 : 0 })
            .justifyContent(FlexAlign.Start)
          }, (desc: string, index: number) => desc + index.toString())
        }
        .alignItems(HorizontalAlign.Start)
      }
      .justifyContent(FlexAlign.Start)
      .layoutWeight(1)

      Row() {
        Text('订')
      }
      .borderRadius(24)
      .justifyContent(FlexAlign.Center)
      .width(54)
      .height(34)
      .backgroundColor('#FEE231')
      .onClick(() => {
        if (this.config.onOrderClick) {
          this.config.onOrderClick()
        }
        phoneRouterControl.jumpPage({
          pageName: this.config.orderPageName,
          builder: this.config.orderPageBuilder,
          param: this.config.orderData
        })
      })
    }
    .height(70)
    .alignItems(VerticalAlign.Center)
    .padding(12)
    .width('100%')
    .borderRadius(12)
    .backgroundColor('#fff')
  }
}
