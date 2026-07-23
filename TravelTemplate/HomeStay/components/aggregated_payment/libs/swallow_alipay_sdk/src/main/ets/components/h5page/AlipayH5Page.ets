
@ComponentV2
export struct AlipayH5Page {
  @Param
  public progress: number = 0;
  @Param
  public title: string | Resource = '';
  @Param
  public showRefresh: boolean = true;
  @Param
  public showHeader: boolean = true;
  @Param
  public showProgress: boolean = true;
  @Param
  public navPageIntent: Map<string, Object> = new Map();
  @Param
  public isFullScreen: boolean = true;
  @Param
  public statusBarHeight: number = 0;
  public build(): void {
    NavDestination() {
      Column() {
        Text('Swallow: page not implemented.')
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .hideBackButton(false)
  }
}
