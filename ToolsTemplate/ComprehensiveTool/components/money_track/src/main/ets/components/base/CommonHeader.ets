@Preview
@ComponentV2
export struct MoneyTrackHeader {
  @Param title: string = '';
  @Param bgColor: ResourceStr = $r('app.color.system_color_background_transparent');
  @Param stack: NavPathStack = new NavPathStack()
  @BuilderParam rightContent: () => void = this.buildEmpty
  private _topBannerHeight: number = 56;

  @Computed
  get showBackButton() {
    return Boolean(this.stack?.size?.() > 0);
  }

  build() {
    Row() {
      if (this.showBackButton) {
        Row() {
          Image($r('app.media.ic_arrow_left'))
            .fillColor($r('app.color.font_color_level1'))
            .height(20)
        }
        .backgroundColor($r('app.color.system_color_background_grey_level2'))
        .borderRadius($r('app.string.border_radius_capsule'))
        .height(40)
        .width(40)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.stack.pop();
        });
      }
      Text(this.title)
        .fontSize($r('app.string.font_size_20'))
        .fontColor($r('app.color.font_color_level1'))
        .margin({ left: $r('app.string.space_s') })
        .fontWeight(FontWeight.Bold);
      Blank()
      this.rightContent()
    }
    .width($r('app.string.width_percent_full'))
    .backgroundColor(this.bgColor)
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .height(this._topBannerHeight)
    .padding({ left: $r('app.string.space_l'), right: $r('app.string.space_l') })
    .margin({ bottom: $r('app.string.space_s') })
  }

  @Builder
  buildEmpty() {
  }
}