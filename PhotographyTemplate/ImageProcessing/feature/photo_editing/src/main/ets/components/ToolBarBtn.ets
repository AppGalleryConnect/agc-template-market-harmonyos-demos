@ComponentV2
export struct ToolBarBtn {
  @Param symbol: string = '';
  @Param fontColor: ResourceColor = $r('sys.color.font_primary')
  @Param btnSize: Length = 40
  @Param iconSize: number = 24
  @Param btnBg: ResourceColor = $r('sys.color.comp_background_tertiary')
  @Param enable: boolean = false;
  @Event onClickAction: () => void;

  build() {
    Button({ stateEffect: this.enable }) {
      SymbolGlyph($r(this.symbol))
        .fontColor(this.enable ? [this.fontColor] : ['#9c9c9a'])
        .fontSize(this.iconSize)
    }
    .width(this.btnSize)
    .height(this.btnSize)
    .onClick(() => {
      if (this.enable) {
        this.onClickAction?.()
      }
    })
    .backgroundColor(this.enable ? this.btnBg : $r('sys.color.comp_background_tertiary'))
  }
}