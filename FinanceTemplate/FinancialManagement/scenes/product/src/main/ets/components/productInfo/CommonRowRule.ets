@ComponentV2
export struct CommonRowRule {
  @Param text: string = ''
  @Param value: string = ''

  build() {
    Row() {
      Row() {
        Text(this.text)
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('25%')

      Row() {
        Text(this.value)
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
      }
      .justifyContent(FlexAlign.End)
      .width('75%')
    }
    .margin({ bottom: 12 })
  }
}