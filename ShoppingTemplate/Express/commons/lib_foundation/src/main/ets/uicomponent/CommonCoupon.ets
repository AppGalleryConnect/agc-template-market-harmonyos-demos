import { Coupon } from '../model/ObserveModel'


@ComponentV2
export struct CommonCoupon {
  @Param isVip: boolean = true
  @Param coupon: Coupon | undefined = undefined
  @Param couponDialogController: CustomDialogController | undefined = undefined
  @Event onChange: (coupon: Coupon) => void = () => {
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text() {
            Span('¥')
              .fontSize(12)
            Span(this.coupon?.promotion.toString())
              .fontSize(24)
          }
          .fontWeight(FontWeight.Medium)
          .fontColor('#0A59F7')

          if (this.coupon?.promotion && this.coupon?.promotion > 0) {
            Text(this.coupon.promotionsLimit)
              .fontSize(10)
              .fontWeight(FontWeight.Regular)
              .fontColor('#0A59F7')
              .margin({ top: 2 })
          }
        }
        .width(90)
        .borderWidth({ right: 1 })
        .borderStyle(BorderStyle.Dashed)

        Row() {
          Column() {
            Row() {
              Text(this.coupon?.name)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
            }
            .height(24)
            .alignItems(VerticalAlign.Center)
            .margin({ bottom: 4 })

            Row() {
              Text(this.coupon?.goodsLimit)
                .fontSize(12)
                .fontWeight(FontWeight.Regular)
                .fontColor('#0A59F7')
            }
            .height(18)
            .alignItems(VerticalAlign.Center)
            .margin({ bottom: 2 })

            Row() {
              Text(this.coupon?.time)
                .fontSize(12)
                .fontWeight(FontWeight.Regular)
                .fontColor('#0A59F7')
            }
            .height(18)
            .alignItems(VerticalAlign.Center)
          }
          .alignItems(HorizontalAlign.Start)

          Column() {
            Row() {
              Text() {
                if (this.isVip) {
                  Span(this.coupon?.isAvailable ? '立即兑换' : '已兑换')
                } else {
                  Span('立即使用')
                }
              }
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
              .fontColor(Color.White)
            }
            .justifyContent(FlexAlign.Center)
            .width(72)
            .height(28)
            .borderRadius(8)
            .backgroundColor(!this.isVip ? '#0A59F7' : this.coupon?.isAvailable ? '#0A59F7' : '#999999')
            .margin({ bottom: 12 })
            .onClick(() => {
              this.onChange(this.coupon!!)
              this.couponDialogController?.close()
            })

            Image(this.coupon?.isShow ? $r('app.media.ic_chevron_up') : $r('app.media.ic_chevron_down'))
              .width(24)
              .height(24)
              .onClick(() => {
                this.coupon!.isShow = !this.coupon!.isShow
              })
          }
          .alignItems(HorizontalAlign.End)
        }
        .alignItems(VerticalAlign.Top)
        .justifyContent(FlexAlign.SpaceBetween)
        .flexGrow(1)
        .padding({ left: 20, right: 20 })
      }
      .width('100%')
      .padding({ top: 16, bottom: 14 })
      .backgroundColor(Color.White)
      .borderRadius(16)

      if (this.coupon?.isShow) {
        Column() {
          Text('使用说明')
          ForEach(this.coupon?.instructionList, (instruction: string) => {
            Text(instruction)
              .fontSize(8)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 6 })
          }, (item: string[]) => JSON.stringify(item))
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 8, left: 20 })
      }
    }
  }
}