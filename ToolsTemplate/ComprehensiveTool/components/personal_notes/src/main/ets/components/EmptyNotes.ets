@ComponentV2
export struct EmptyNotes {
  build() {
    Column() {
      Image($r('app.media.empty_notes'))
        .width(120)
        .height(120)

      Text('岁月悠悠，心事悄悄，记录一下吧')
        .fontSize(12)
        .fontColor($r('sys.color.font_tertiary'))
    }
    .width('100%')
    .height('55%')
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}