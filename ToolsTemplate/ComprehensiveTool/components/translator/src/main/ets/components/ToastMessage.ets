@ComponentV2
export struct ToastMessage {
  build() {
    Row() {
      Text('请说出常用语言')
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
    }
    .width('100%')
    .height(72)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
}