@ComponentV2
export struct ContainerRow {
  @BuilderParam customBuilderParam: () => void;

  build() {
    Row() {
      this.customBuilderParam();
    }
    .width($r('app.string.width_percent_full'))
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r('app.color.system_color_background_white'))
    .borderRadius($r('app.string.border_radius_16'))
    .padding($r('app.string.padding_m'))
    .margin({
      bottom: $r('app.string.margin_m'),
    });
  }
}