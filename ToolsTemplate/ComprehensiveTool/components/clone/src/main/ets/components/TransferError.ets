@ComponentV2
export struct TransferError{
  build() {
    Row() {
      Text('部分文件传输失败')

      SymbolGlyph($r('sys.symbol.xmark_circle_fill'))
        .fontSize(24)
        .fontColor([$r('sys.color.warning')])
    }
    .width('100%')
    .height(71)
    .padding({ left: 12, right: 12 })
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(16)
  }
}