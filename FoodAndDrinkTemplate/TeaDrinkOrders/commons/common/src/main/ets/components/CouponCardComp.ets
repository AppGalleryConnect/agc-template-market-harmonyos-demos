import { Constants, CouponStateEnum } from '../constants/Common'
import { MyCoupon } from '../models/ResponseModel'
import { Decimal } from '@kit.ArkTS'
import { RouterMap } from '../constants/RouterMap'
import { TabBarType } from '../models/TabBarModel'
import { IndexPageRouter } from '../models/RouterModel'

@ComponentV2
export struct CouponCard {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Param @Require coupon: MyCoupon
  @Param totalMoney: number = 0
  @Local showInstruction: boolean = false
  @Param showUseNowBtn: boolean = true
  @Param showUseCheck: boolean = false
  @Param selectCouponId: string = ''
  @Event changeCoupon: (coupon: MyCoupon, isCheck: boolean) => void = () => {
  }

  build() {
    Column() {
      Stack() {
        Row() {
          Row() {
            Text($r('app.string.currency_symbol'))
              .fontColor($r('sys.color.comp_background_list_card'))
              .fontSize(18)
              .margin({ bottom: 10 })
            Text(this.coupon.reduce)
              .fontColor($r('sys.color.comp_background_list_card'))
              .fontSize(48)
              .margin({ left: 4 })
          }
          .width(102)
          .height(100)
          .padding({ left: 22, bottom: 20 })
          .alignItems(VerticalAlign.Bottom)

          Row() {
            Column() {
              Column() {
                Text(this.coupon.name)
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text($r('app.string.full_available', this.coupon.full))
                  .fontColor($r('app.color.mainColor'))
                  .fontSize(12)
                  .margin({ top: 4 })
                Text($r('app.string.valid_until', `${this.coupon.startTime}`, `${this.coupon.endTime}`))
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize(10)
                  .margin({ top: 4 })
              }.alignItems(HorizontalAlign.Start)

              if (this.totalMoney && Number(this.coupon.full) > this.totalMoney) {
                Row() {
                  Image($r('app.media.icon_error')).width(12)
                  Text($r('app.string.below_threshold',
                    new Decimal(this.coupon.full).sub(this.totalMoney).toNumber().toFixed(2)))
                    .fontColor($r('sys.color.font_secondary'))
                    .fontSize($r('sys.float.Caption_M'))
                    .lineHeight(16)
                    .margin({ left: 7 })
                }
              }
              Row() {
                Text($r('app.string.instruction'))
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.Caption_M'))
                Image(this.showInstruction ? $r('app.media.ic_up') : $r('app.media.ic_down'))
                  .width(12)
                  .margin({ left: 4 })
              }.margin({ top: Number(this.coupon.full) > this.totalMoney ? 0 : 8 })
            }.justifyContent(FlexAlign.SpaceBetween).alignItems(HorizontalAlign.Start).height(Constants.FULL_SIZE)

            if (this.showUseNowBtn && this.coupon.state === CouponStateEnum.USABLE &&
              new Date(this.coupon.endTime).getTime() > new Date().getTime()) {
              Column() {
                Text($r('app.string.use_now'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor('#486602')
                  .borderRadius(8)
                  .backgroundColor('#3361860b')
                  .height(28)
                  .padding({
                    left: 8,
                    right: 8,
                  })
                  .onClick(() => {
                    this.pageStack?.popToName(RouterMap.INDEX_PAGE, { index: TabBarType.ORDER } as IndexPageRouter)
                  })
              }
              .justifyContent(FlexAlign.Start).height(Constants.FULL_SIZE)
            }
            if (this.showUseCheck && Number(this.coupon.full) <= this.totalMoney) {
              Column() {
                Checkbox({ name: this.coupon.id, group: 'checkboxGroup' })
                  .select(!!this.selectCouponId && this.selectCouponId === this.coupon.id)
                  .height(16)
                  .width(16)
                  .selectedColor($r('app.color.mainColor'))
                  .shape(CheckBoxShape.CIRCLE)
                  .onChange((value: boolean) => {
                    this.changeCoupon(this.coupon, value)
                  })
              }.justifyContent(FlexAlign.Start).height(Constants.FULL_SIZE)
            }
          }
          .layoutWeight(1)
          .height(100)
          .padding({
            left: 19,
            top: 10,
            right: 6,
            bottom: 8,
          })
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width(Constants.FULL_SIZE)
        .borderRadius({ topRight: 8, bottomRight: 8 })
        .clip(true)
        .backgroundImage(this.canUseCoupon() ? $r('app.media.bg_coupon') : $r('app.media.bg_coupon_unusable'))
        .backgroundImageSize(ImageSize.FILL)
        .onClick(() => {
          this.showInstruction = !this.showInstruction
        })

        if (this.coupon.state === CouponStateEnum.USED) {
          Image($r('app.media.ic_coupon_used')).width(60)
        } else if (new Date(this.coupon.endTime).getTime() < new Date().getTime()) {
          Image($r('app.media.ic_coupon_expired')).width(60)
        }
      }.alignContent(Alignment.TopEnd)


      if (this.showInstruction) {
        Column({ space: 4 }) {
          Text($r('app.string.instruction_label'))
            .fontSize(10)
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Medium)
          ForEach(this.coupon.desc, (desc: string) => {
            Text(desc).fontSize(8).fontColor($r('sys.color.font_secondary'))
          }, (desc: string) => desc)
        }
        .alignItems(HorizontalAlign.Start)
        .width(Constants.FULL_SIZE)
        .margin({ top: 4 })
        .padding({
          top: 8,
          bottom: 8,
          left: 20,
          right: 20,
        })
      }
    }.width(Constants.FULL_SIZE).opacity(this.canUseCoupon() ? 1 : 0.4)
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
