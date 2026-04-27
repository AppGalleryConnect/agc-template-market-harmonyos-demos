@ComponentV2
export struct TransferSuccess{
  build() {
    Row() {
      Text('所有文件传输完成')

      SymbolGlyph($r('sys.symbol.checkmark_circle_fill'))
        .fontSize(24)
        .fontColor([$r('sys.color.confirm')])
    }
    .width('100%')
    .height(71)
    .padding({ left: 12, right: 12 })
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(16)
  }
}