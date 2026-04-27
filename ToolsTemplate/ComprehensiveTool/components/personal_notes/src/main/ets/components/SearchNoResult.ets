@ComponentV2
export struct SearchNoResult {
  build() {
    Column() {
      Text('没有找到匹配的笔记')
        .fontSize(16)
        .fontColor(Color.Gray);
    }
    .width('100%')
    .height(100)
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }
}