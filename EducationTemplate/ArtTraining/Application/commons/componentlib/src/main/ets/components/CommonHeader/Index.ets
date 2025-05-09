import { RouterModule } from 'commonlib';


@ComponentV2
export struct CommonHeader {
  @Param title: string = '';
  @Param bgColor: ResourceStr = $r('app.color.system_color_background_white');
  private _topBannerHeight: number = 56;

  @Computed
  get showBackButton() {
    return Boolean(RouterModule.size() > 0);
  }

  build() {
    Row() {
      if (this.showBackButton) {
        Row() {
          Image($r('app.media.ic_arrow_left'))
            .fillColor($r('app.color.font_color_level1'))
            .height($r('app.integer.icon_size_24'))
            .margin({ right: $r('app.string.margin_m') });
        }
        .onClick(() => {
          RouterModule.pop();
        });
      }
      Text(this.title)
        .fontSize(this.showBackButton ? $r('app.string.font_size_20') : $r('app.string.font_size_24'))
        .fontColor($r('app.color.font_color_level1'))
        .fontWeight(FontWeight.Medium);
    }
    .width($r('app.string.width_percent_full'))
    .backgroundColor(this.bgColor)
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .height(this._topBannerHeight)
    .padding({ left: $r('app.string.padding_xl') });
  }
}