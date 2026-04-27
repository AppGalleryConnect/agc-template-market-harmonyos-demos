@ComponentV2
export struct CommonLoading {
  @Param showLoadingProgress: boolean = true

  build() {
    Column() {
      if (this.showLoadingProgress) {
        LoadingProgress()
          .width(32)
          .height(32)
      }
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: 56 })
    .justifyContent(FlexAlign.Center)
    .hitTestBehavior(HitTestMode.Block)
  }
}
