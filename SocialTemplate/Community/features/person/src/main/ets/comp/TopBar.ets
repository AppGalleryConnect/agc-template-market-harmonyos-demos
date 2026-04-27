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
 