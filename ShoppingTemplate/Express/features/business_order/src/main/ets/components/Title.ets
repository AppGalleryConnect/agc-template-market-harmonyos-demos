@ComponentV2
export struct Title {
  build() {
    Row() {
      Text('查快递')
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
    }
    .width('100%')
    .height(56)
    .margin({ left: 24, bottom: 8 })
  }
}