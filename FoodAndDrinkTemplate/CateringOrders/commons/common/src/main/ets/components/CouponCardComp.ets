import { Constants, CouponStateEnum } from '../constants/Common'
import { MyCouponResp } from '../models/ResponseModel'
import { TabBarType } from '../models/TabBarModel'

@Component
export struct CouponCard {
  @Consume('pageStack') pageStack: NavPathStack
  @Prop coupon: MyCouponResp
  @Prop isOrder: boolean = false
  @Prop selectId: string = ''
  @Prop totalMoney: number = 0
  @State showInstruction: boolean = false
  selectCoupon: (coupon: MyCouponResp) => void = () => {
  }

  build() {
    Column() {
      Stack() {
        Row() {
          Column() {
            Row() {
              Text($r('app.string.currency_symbol'))
                .fontColor($r('sys.color.font_on_primary'))
                .fontSize($r('sys.float.Subtitle_L'))
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 10 })
              Text(this.coupon.reduce)
                .fontColor($r('sys.color.font_on_primary'))
                .fontSize($r('sys.float.Display_M'))
                .fontWeight(FontWeight.Medium)
                .margin({ left: 4 })
            }.alignItems(VerticalAlign.Bottom)

            if (Number(this.coupon.full) > 0) {
              Text($r('app.string.full_available', `${Number(this.coupon.full)}`))
                .fontColor($r('sys.color.font_on_primary'))
                .fontSize($r('sys.float.Caption_M'))
            }
          }
          .width(100)
          .height(100)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)

          Column() {
            Text(this.coupon.name)
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Subtitle_L'))
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text($r('app.string.coupon_type'))
              .fontColor(this.canUseCoupon() ? $r('sys.color.multi_color_09') :
              $r('sys.color.font_secondary'))
              .fontSize($r('sys.float.Body_S'))
              .margin({ top: 2 })
            Text($r('app.string.valid_until', `${this.coupon.endTime}`))
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.Caption_M'))
              .margin({ top: 5 })
            if (this.isOrder && Number(this.coupon.full) > this.totalMoney &&
            this.canUseCoupon()) {
              Row() {
                Image($r('app.media.icon_error')).width(12)
                Text($r('app.string.below_threshold', Number(this.coupon.full) - this.totalMoney))
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize($r('sys.float.Caption_M'))
                  .lineHeight(16)
                  .margin({ left: 7 })
              }
            } else {
              Row() {
                Text($r('app.string.instruction'))
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.Caption_M'))
                Image(this.showInstruction ? $r('app.media.ic_up') : $r('app.media.ic_down'))
                  .width(12)
                  .margin({ left: 4 })
              }.margin({ top: 8 })
              .onClick(() => {
                this.showInstruction = !this.showInstruction
              })
            }

          }
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 20 })
          .layoutWeight(1)
          .padding({
            left: 17,
            top: 10,
            right: 16,
            bottom: 8,
          })
        }
        .width(Constants.FULL_SIZE)
        .borderRadius({ topRight: 8, bottomRight: 8 })
        .clip(true)

        Row() {
          if (this.coupon.state === CouponStateEnum.USED) {
            Image($r('app.media.ic_coupon_used')).width(60)
          } else if (new Date(this.coupon.endTime).getTime() < new Date().getTime()) {
            Image($r('app.media.ic_coupon_expired')).width(60)
          } else if (this.isOrder) {
            if (Number(this.coupon.full) <= this.totalMoney) {
              Radio({ value: '', group: 'radioGroup' })
                .checked(this.selectId === this.coupon.couponId)
                .radioStyle({
                  checkedBackgroundColor: $r('sys.color.multi_color_09'),
                })
                .height(20)
                .width(20)
                .onChange(() => {
                  this.selectCoupon(this.coupon)
                })
            }
          } else {
            Column() {
              Text($r('app.string.use_now'))
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.multi_color_09'))
                .borderRadius(8)
                .backgroundColor('rgba(237,111,33,0.2) ')
                .padding({
                  left: 8,
                  right: 8,
                  top: 4,
                  bottom: 4,
                })
                .onClick(() => {
                  this.pageStack.popToName('HomePage', TabBarType.HOMEPAGE)
                })
            }.margin({ top: 8, right: 8 })
          }
        }
        .justifyContent(FlexAlign.Center)
      }
      .alignContent(Alignment.TopEnd)
      .opacity((!this.isOrder && this.canUseCoupon()) ||
        (this.isOrder && this.canUseCoupon() && Number(this.coupon.full) <= this.totalMoney) ? 1 : 0.4)
      .backgroundImage(this.canUseCoupon() ? $r('app.media.bg_coupon') : $r('app.media.bg_coupon_unusable'))
      .backgroundImageSize(ImageSize.FILL)


      if (this.showInstruction) {
        Column({ space: 6 }) {
          Text($r('app.string.instruction_label'))
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_secondary'))
          ForEach(this.coupon.desc, (desc: string) => {
            Text(desc).fontSize($r('sys.float.Caption_S')).fontColor($r('sys.color.font_secondary'))
          }, (desc: string) => desc)
        }
        .alignItems(HorizontalAlign.Start)
        .width(Constants.FULL_SIZE)
        .backgroundImage($r('app.media.bg_coupon_instruction'))
        .backgroundImageSize(ImageSize.FILL)
        .padding({
          top: 8,
          bottom: 8,
          left: 20,
          right: 20,
        })
      }
    }.width(Constants.FULL_SIZE)

  }

  canUseCoupon() {
    if (new Date(this.coupon.endTime).getTime() > new Date().getTime() &&
      this.coupon.state === CouponStateEnum.USABLE) {
      return true
    } else {
      return false
    }
  }
}
