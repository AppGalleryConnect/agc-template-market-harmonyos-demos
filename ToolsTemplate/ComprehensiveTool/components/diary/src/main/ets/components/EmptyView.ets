@ComponentV2
export struct EmptyView {
  build() {
    Column() {
      Image($r('app.media.ic_diary_empty'))
        .width(120)
        .height(120)
        .draggable(false)

      Text('写下你的故事，让日记成为你最好的朋友。')
        .fontSize(12)
        .fontColor($r('sys.color.font_tertiary'))
    }
    .width('100%')
    .height('80%')
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}