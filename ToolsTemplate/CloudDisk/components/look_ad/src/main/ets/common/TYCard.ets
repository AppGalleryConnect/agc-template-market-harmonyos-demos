@ComponentV2
export struct TYCard {
  @Param topPadding: number = 16
  @Param bottomPadding: number = 16
  @Param leftPadding: number = 12
  @Param rightPadding: number = 12
  @Param bottomMargin: number = 0
  @BuilderParam content: () => void
  @Consumer('leftCount') leftCount:number = 0
  @Param award:string = '领看点'

  @Builder
  renderLeftText() {
      Text() {
        Span('看广告'+this.award+'(')
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(16)
        Span(this.leftCount + '')
          .fontWeight(FontWeight.Bold)
          .fontSize(16)
          .fontColor('#EC6E45')
        Span('/3)')
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(16)
      }
  }

  build() {
    Column() {
      Row() {
        this.renderLeftText()
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')

      if (this.content) {
        this.content()
      }

    }
    .width('100%')
    .margin({ top: 12, bottom: this.bottomMargin })
    .padding({
      top: this.topPadding,
      bottom: this.bottomPadding,
      left: this.leftPadding,
      right: this.rightPadding
    })
    .borderRadius(12)
    .backgroundImage($r('app.media.award_bg_linearGradient'))
    .backgroundImageSize(ImageSize.FILL)

  }
}