@Builder
export function MarkerRenderBuilder(name:string) {
  Column() {
    Text(name)
      .textAlign(TextAlign.Center)
      .fontColor($r('sys.color.font_on_primary'))
      .fontSize($r('sys.float.Body_M'))
      .maxLines(1)
      .padding({ top: 4, bottom: 4, left: 12, right: 12 })
      .backgroundColor($r('sys.color.mask_tertiary'))
      .borderRadius(56)
      .margin({ bottom:4 })
    SymbolGlyph($r('sys.symbol.local_fill'))
      .width(40)
      .height(40)
      .fontSize(40)
      .fontColor([$r('sys.color.warning')])
  }
}