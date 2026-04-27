@ComponentV2
export struct CommonLoading {
  @Param showLoadingProgress: boolean = true;
  @Param loadingWidth: Length = 72;
  @Param loadingHeight: Length = 72;
  @Param text: ResourceStr = '加载中';

  build() {
    Column({ space: 8 }) {
      LoadingProgress()
        .width(this.loadingWidth)
        .height(this.loadingHeight)
        .color($r('sys.color.icon_secondary'))
      Text(this.text)
        .fontColor($r('sys.color.font_secondary'))
        .textAlign(TextAlign.Center)
        .fontSize(16)
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: 56 })
    .justifyContent(FlexAlign.Center)
  }
}
