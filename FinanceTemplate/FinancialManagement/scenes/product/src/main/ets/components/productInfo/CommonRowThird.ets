@ComponentV2
export struct CommonRowThird {
  @Param text: string = ''
  @Param value: string = ''

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      Text(this.text)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Text(this.value)
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
    }
  }
}