/**
 * @usage: 用于页面顶部导航栏，展示页面标题和返回按钮。关键参数：title标题文本，onClickBack返回按钮点击回调。
 * @layout: 横向排列。左侧为返回按钮（圆形背景的向左箭头图标），右侧为标题文本，左对齐排列。
 * @constraints:
 * @zhName: 顶部导航栏
 * @fileType: component
 * @isGen: true
 */
@ComponentV2
export struct TopBar {
  @Param title: string | Resource = '';
  @Param onClickBack: () => void = () => {
  }

  build() {
    Row() {
      Row() {
        Image($r('app.media.chevron_backward'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.onClickBack()
          })
      }
      .width(40)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .padding(8)
      .borderRadius(40)

      Text(this.title)
        .fontSize(20)
        .fontWeight(700)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: 8 })
    }
  }
}
 