@ComponentV2
export struct CommonScroll {
  @Param
  bgColor: ResourceColor = $r('app.color.background_color_primary')
  @BuilderParam
  contentBuilder: () => void = this.buildEmpty;

  build() {
    Scroll() {
      Column({ space: 12 }) {
        this.contentBuilder()
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
    }
    .align(Alignment.Top)
    .width($r('app.string.size_percent_full'))
    .layoutWeight(1)
    .padding({
      left: $r('app.float.space_l'),
      right: $r('app.float.space_l'),
      bottom: $r('app.float.space_l'),
    })
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
    .backgroundColor(this.bgColor)
  }

  @Builder
  buildEmpty(){

  }
}