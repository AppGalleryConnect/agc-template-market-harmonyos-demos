@ComponentV2
export struct NoneData {
  build() {
    Column() {
      Image($r('app.media.none_file'))
        .width(120)
        .height(120)
      Text('暂无数据')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
    }
    .margin({ top: 68 })
    .height(`calc(100% - 108vp)`)
  }
}