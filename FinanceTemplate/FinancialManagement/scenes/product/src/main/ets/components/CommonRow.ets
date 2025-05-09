@ComponentV2
export struct CommonRow {
  @Param text: string = ''
  @Param value: string = ''

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      Text(this.text)
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
      Text(this.value)
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
    }
    .margin({ bottom: 12 })
  }
}