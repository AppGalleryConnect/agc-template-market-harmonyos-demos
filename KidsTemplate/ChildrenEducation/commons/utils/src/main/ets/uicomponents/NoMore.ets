import { CommonConstants } from '../constants/CommonConstants'

@Builder
export function NoMoreTab(text : ResourceStr) {
  Row() {
    Divider()
      .height(1)
      .layoutWeight(1)
    Text(text)
      .fontColor($r('sys.color.mask_tertiary'))
      .fontSize($r('app.float.15fp'))
      .margin($r('app.float.12vp'))
    Divider()
      .height(1)
      .layoutWeight(1)
  }
  .alignItems(VerticalAlign.Center)
  .width(CommonConstants.FULL_PERCENT)
  .margin({ bottom: '50' })
}