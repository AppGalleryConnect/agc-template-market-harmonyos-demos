@ComponentV2
export struct PlayerSpeedRateView {
  @Param leftRateOpacity: number = 0;
  @Param rightRateOpacity: number = 1;
  @Param offsetTop: number = 120

  build() {
    Row() {
      Row() {
        Image($r('app.media.ic_rate'))
          .width(7)
          .height(8)
          .opacity(this.leftRateOpacity)
          .animation({
            duration: 300,
            curve: Curve.Linear,
            iterations: -1,
            playMode: PlayMode.Alternate,
            expectedFrameRateRange: {
              min: 0,
              max: 1,
              expected: 1,
            },
          })
        Image($r('app.media.ic_rate'))
          .width(7)
          .height(8)
          .opacity(this.rightRateOpacity)
          .animation({
            duration: 300,
            curve: Curve.Linear,
            iterations: -1,
            playMode: PlayMode.Alternate,
            expectedFrameRateRange: {
              min: 0,
              max: 1,
              expected: 0,
            },
          })
        Text('2.0X快进中')
          .fontColor(Color.White)
          .fontSize(12)
          .lineHeight(16)
          .margin({ left: 4 })
      }
      .accessibilityLevel('yes')
      .accessibilityGroup(true)
    }
    .height(48)
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .offset({ top: this.offsetTop })
  }
}