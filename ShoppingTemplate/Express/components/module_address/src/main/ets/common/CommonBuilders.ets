@Builder
export function buildLoadingMask(): void {
  Column() {
    LoadingProgress()
      .width(32)
      .height(32)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .hitTestBehavior(HitTestMode.Block)
}
