/** 优惠券模块内空状态 */
@Builder
export function buildCouponEmptyStatus(message?: ResourceStr) {
  Column() {
    Image($r('app.media.ic_search_empty'))
      .width(120)
      .height(120)
    Text(message ?? $r('app.string.coupon_empty_default'))
      .fontSize(14)
      .fontColor($r('app.color.font_color_level2'))
  }
  .width('100%')
  .layoutWeight(1)
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Center)
}
