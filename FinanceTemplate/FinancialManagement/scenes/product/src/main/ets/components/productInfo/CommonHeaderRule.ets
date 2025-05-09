@ComponentV2
export struct CommonHeaderRule {
  @Param text: string = ''
  @Event changeValue: () => void = () => {
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      Text(this.text)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
      Row() {
        Text('更多')
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
        Image($r('app.media.icc_arrow_right'))
          .width(12)
          .height(24)
      }
      .onClick(() => {
        this.changeValue()
      })
    }
    .margin({ top: 8, bottom: 16 })
  }
}