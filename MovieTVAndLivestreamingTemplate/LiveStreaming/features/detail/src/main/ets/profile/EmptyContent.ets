@ComponentV2
export struct EmptyContent{
  @Param text: string = ''

  build() {
    Column() {
      Image($r('app.media.profile_qiqiu'))
        .width(120)
        .aspectRatio(1)

      Text(this.text)
        .fontSize(14)
        .fontWeight(400)
        .fontColor($r('sys.color.font_secondary'))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}