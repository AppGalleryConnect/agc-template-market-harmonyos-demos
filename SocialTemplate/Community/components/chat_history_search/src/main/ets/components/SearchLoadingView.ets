@ComponentV2
export struct SearchLoadingView {
  build() {
    Column() {
      LoadingProgress()
        .width($r('app.float.vp_32'))
        .height($r('app.float.vp_32'))
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .layoutWeight(1)
  }
}