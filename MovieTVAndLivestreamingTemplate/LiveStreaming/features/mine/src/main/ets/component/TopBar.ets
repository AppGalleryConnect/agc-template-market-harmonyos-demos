@ComponentV2
export struct TopBar {
  @Param title: string | Resource = '';
  @Param onClickBack: () => void = () => {
  }

  build() {
    Row() {
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize($r('app.float.vp_24'))
          .fontColor([$r('sys.color.icon_primary')])
          .onClick(() => {
            this.onClickBack()
          })
      }
      .justifyContent(FlexAlign.Center)
      .width($r('app.float.vp_40'))
      .height($r('app.float.vp_40'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .padding($r('app.float.vp_8'))
      .borderRadius($r('app.float.vp_40'))

      Text(this.title)
        .fontSize(20)
        .fontWeight(700)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: $r('app.float.vp_8') })
    }
  }
}
 