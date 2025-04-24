import { Constants, OrderModel, OrderStateEnum, OrderTypeEnum } from 'common'

@Component
export struct ReductionCard {
  @Prop @Watch('orderInfoChange') orderInfo: OrderModel
  @State order: OrderModel = new OrderModel()

  aboutToAppear(): void {
    this.orderInfoChange()
  }

  orderInfoChange() {
    this.order = this.orderInfo
  }

  build() {
    Column({ space: 8 }) {
      Row() {
        Row() {
          Image($r('app.media.ic_order_coupon')).width(16).height(16)
          Text($r('app.string.coupon_label'))
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .margin({ left: 4 })
        }

        Text() {
          Span($r('app.string.currency_symbol_pre_params', '-')).fontSize($r('sys.float.Caption_S'))
          Span(`${Number(this.order.yhqMoney)}`).fontSize($r('sys.float.Body_M'))
        }.fontColor($r('sys.color.multi_color_08')).fontWeight(FontWeight.Medium)
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)

      // 优惠
      Row() {
        Row() {
          Image($r('app.media.ic_reduction')).width(16)
          Text(this.order.xyhMoney !== '0' ? $r('app.string.new_user_discount_label') :
          $r('app.string.store_discount_label'))
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .margin({ left: 4 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }.layoutWeight(1)

        Text() {
          Span($r('app.string.currency_symbol_pre_params', '-')).fontSize($r('sys.float.Caption_S'))
          Span(this.order.xyhMoney !== '0' ? `${Number(this.order.xyhMoney)}` :
            `${Number(this.order.mjMoney)}`).fontSize($r('sys.float.Body_M'))
        }.fontColor($r('sys.color.multi_color_08')).fontWeight(FontWeight.Medium)
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)


      if (Number(this.order.orderType) === OrderTypeEnum.PICKING) {
        Row() {
          Row() {
            Image($r('app.media.ic_takeaway')).width(16)
            Text($r('app.string.packing_box'))
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ left: 4 })
          }

          Text() {
            Span($r('app.string.currency_symbol')).fontSize($r('sys.float.Caption_S'))
            Span(`${this.order.boxMoney}`).fontSize($r('sys.float.Body_M'))
          }.fontColor($r('sys.color.multi_color_08')).fontWeight(FontWeight.Medium)
        }
        .width(Constants.FULL_SIZE)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      if (Number(this.order.dnState) === OrderStateEnum.noFinished) {
        Divider().margin({ top: 8 })
        // 实付金额
        Row() {
          Text() {
            Span($r('app.string.discount_money')).fontSize($r('sys.float.Body_M')).lineHeight(20)
            Span($r('app.string.currency_symbol'))
              .fontSize(8)
              .fontWeight(FontWeight.Medium)
              .lineHeight(14)
              .margin({ left: 4 })
            Span(this.order.reductionMoney?.toString())
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .lineHeight(20)
          }.fontColor($r('sys.color.multi_color_08'))

          Text() {
            Span($r('app.string.should_pay')).fontSize($r('sys.float.Body_M')).lineHeight(20)
            Span($r('app.string.currency_symbol'))
              .fontSize(8)
              .fontWeight(FontWeight.Medium)
              .lineHeight(14)
              .margin({ left: 4 })
            Span(`${this.order.money}`)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .lineHeight(20)
          }.fontColor($r('sys.color.font_primary')).margin({ left: 20 })
        }
        .width(Constants.FULL_SIZE)
        .padding({ top: 16 })
        .justifyContent(FlexAlign.End)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })
      } else {
        // 支付方式
        Row() {
          Text($r('app.string.pay_type'))
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))

          Text($r('app.string.huawei_pay'))
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
        }
        .width(Constants.FULL_SIZE)
        .justifyContent(FlexAlign.SpaceBetween)

        // 实付金额
        Row() {
          Text($r('app.string.real_pay')).fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_secondary'))
          Row() {
            Text($r('app.string.currency_symbol'))
              .fontSize($r('sys.float.Caption_S'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_secondary'))
            Text(`${Number(this.order.money)}`)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_primary'))
          }
        }
        .justifyContent(FlexAlign.End)
        .width(Constants.FULL_SIZE)
        .justifyContent(FlexAlign.SpaceBetween)
      }


    }
    .width(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 16,
    })
  }
}