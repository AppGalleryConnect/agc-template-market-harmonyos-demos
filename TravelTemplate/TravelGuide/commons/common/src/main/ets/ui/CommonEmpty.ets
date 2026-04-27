@ComponentV2
export struct CommonEmpty {
  build() {
    Column() {
      Column(){
        Image($r('app.media.empty_img'))
          .width(120)
          .height(120)
          .margin({ bottom: 18 })
        Text('暂无内容')
          .fontColor('rgba(0, 0, 0, 0.40)')
          .fontSize(12)
      }
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}

