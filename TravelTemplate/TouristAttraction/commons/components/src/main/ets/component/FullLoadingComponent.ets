@ComponentV2
export struct FullLoadingComponent {
  build() {
    Column() {
      LoadingProgress().width(30).height(30)
    }
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .backgroundColor(Color.Transparent)
  }
}