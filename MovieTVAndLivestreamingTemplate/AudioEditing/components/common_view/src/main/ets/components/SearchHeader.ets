import { phoneRouterControl } from 'oh_router'
import { SymbolGlyphModifier } from '@kit.ArkUI'

@ComponentV2
export struct SearchHeader {
  @Param searchVal: string = ''
  @Param @Require onSearchSubmit: (val: string) => void
  @Param onSearchChange: (val: string) => void = () => {
  }

  build() {
    Row() {
      Row() {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontColor([$r('sys.color.icon_on_primary')])
            .fontSize(24)
            .opacity(0.5)
        }
        .backgroundColor('#0CFFFFFF')
        .width(40)
        .height(40)
        .borderRadius(40)
        .onClick(() => {
          phoneRouterControl.popPage()
        })

      }

      Row() {
        Search({ value: this.searchVal, placeholder: '请输入' })
          .placeholderColor($r('sys.color.font_on_tertiary'))
          .fontColor($r('sys.color.font_on_tertiary'))
          .layoutWeight(1)
          .margin(0)
          .backgroundColor('#33F5F5F5')
          .searchIcon(new SymbolGlyphModifier($r('sys.symbol.AI_search')).fontSize(16)
            .fontColor([Color.White])
            .opacity(0.4))
          .cancelButton({
            style: CancelButtonStyle.CONSTANT,
            icon: new SymbolGlyphModifier($r('sys.symbol.xmark')).fontSize(12).fontColor([Color.White]).opacity(0.4)
          })

          .onSubmit((val: string) => {
            this.onSearchSubmit(val)
          })
          .onChange((value: string) => {
            this.onSearchChange(value)
          })
      }.layoutWeight(1).margin({ left: 8 })
      .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
    }.width('100%').justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: 8, right: 16, left: 16 })
  }
}