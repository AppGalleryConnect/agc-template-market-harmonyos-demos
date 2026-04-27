@ComponentV2
export struct FullLoadingComponent {
  build() {
    Column() {
      LoadingProgress().width(32).height(32)
    }
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .backgroundColor(Color.Transparent)
  }
}