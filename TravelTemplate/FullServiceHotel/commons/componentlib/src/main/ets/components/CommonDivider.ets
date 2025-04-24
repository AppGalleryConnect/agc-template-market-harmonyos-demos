@ComponentV2
export struct CommonDivider {
  @Param color: ResourceColor = $r('app.color.system_color_grey_level2');

  @Param strokeWidth: string | number = 1;

  build() {
    Divider()
      .vertical(false)
      .color(this.color)
      .strokeWidth(this.strokeWidth)
      .lineCap(LineCapStyle.Butt)
      .margin({
        top: $r('app.string.margin_s'),
        bottom: $r('app.string.margin_s'),
      });
  }
}