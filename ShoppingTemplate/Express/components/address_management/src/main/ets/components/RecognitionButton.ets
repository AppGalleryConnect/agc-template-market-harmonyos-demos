@ComponentV2
export struct RecognitionButton {
  // 传入参数
  @Param symbolResource: Resource = $r('sys.symbol.picture');
  @Param label: string = '';
  @Event clickAction: () => void;

  build() {
    Row({ space: 4 }) {
      SymbolGlyph(this.symbolResource)
        .fontSize(16)
        .fontColor([$r('sys.color.icon_emphasize')])
      Text(this.label)
        .fontSize(14)
        .fontColor($r('sys.color.font_emphasize'))
        .fontWeight(500)
        .lineHeight(19)
    }
    .padding({ left: 5, right: 5, top: 6, bottom: 6 })
    .borderRadius(16)
    .stateStyles({
      normal: { .backgroundColor($r('sys.color.comp_background_tertiary')) },
      pressed: { .backgroundColor($r('sys.color.interactive_pressed')) },
    })
    .onClick(() => {
      this.clickAction?.();
    })
  }
}