import { Constants } from 'common'

@ComponentV2
export struct ATag {
  /**
   * defaultSlot 默认插槽
   */
  @BuilderParam defaultBuilder?: CustomBuilder
  /**
   * 背景颜色
   */
  @Require @Param backGroundColor: ResourceColor | string = ''

  build() {
    Column() {
      if (this.defaultBuilder) {
        this.defaultBuilder()
      } else {
        Text($r('app.string.not_passed'))
      }
    }
    .padding($r('app.float.record_tag_padding'))
    .margin({ left: $r('app.float.record_tag_margin') })
    .backgroundColor(this.backGroundColor)
    .borderRadius(Constants.RADIUS_FIFTEEN)
  }
}
