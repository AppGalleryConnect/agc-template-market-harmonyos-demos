import { BaseTextStyleModifier } from 'base_apis'

@ComponentV2
export struct VipNavTitle {
  @Param title: ResourceStr = ''
  @Param routerModule: NavPathStack = new NavPathStack()
  @Param bg: ResourceStr | Color = ''

  build() {
    Row({ space: 8 }) {
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
          .fontWeight(FontWeight.Normal)
      }
      .width(40)
      .height(40)
      .type(ButtonType.Circle)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.routerModule.pop()
      })

      Text(this.title)
        .attributeModifier(new BaseTextStyleModifier(`font_primary/Title_S/Bold`))
        .padding({ left: 8 })
    }
    .height(60)
    .width('100%')
    .backgroundColor(this.bg)
    .padding({ left: 16, right: 16 })
  }
}