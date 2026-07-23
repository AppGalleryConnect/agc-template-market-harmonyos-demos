import { CommonConstants } from 'lib_common'

@Builder
export function LoadMoreFooter(params: Record<string, boolean>) {
  Row({ space: CommonConstants.SPACE_S }) {
    LoadingProgress()
      .height(32)
      .width(48)
    Text('正在加载')
      .fontSize(14)
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Regular)
  }
  .width(CommonConstants.FULL_PERCENT)
  .height(40)
  .margin({ bottom: params.isHomePage ? 84 : 100 })
  .justifyContent(FlexAlign.Center)
  .visibility(params.isLoading ? Visibility.Visible : Visibility.Hidden)
}