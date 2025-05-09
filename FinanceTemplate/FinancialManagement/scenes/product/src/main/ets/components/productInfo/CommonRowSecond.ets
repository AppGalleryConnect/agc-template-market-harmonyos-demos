@ComponentV2
export struct CommonRowSecond {
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
    .padding({
      top: 18,
      bottom: 17,
      left: 12,
      right: 12
    })
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .margin({ bottom: 12 })
  }
}