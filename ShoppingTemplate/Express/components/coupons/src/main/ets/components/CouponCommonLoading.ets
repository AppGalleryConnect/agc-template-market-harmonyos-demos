/** 优惠券模块内加载指示 */
@Builder
export function CouponCommonLoading() {
  Row() {
    LoadingProgress().width(32)
  }
  .layoutWeight(1)
  .width('100%')
  .justifyContent(FlexAlign.Center)
  .alignItems(VerticalAlign.Center)
}
