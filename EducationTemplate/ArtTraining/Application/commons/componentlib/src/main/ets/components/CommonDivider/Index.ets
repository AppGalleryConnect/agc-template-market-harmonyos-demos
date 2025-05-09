@ComponentV2
export struct CommonDivider {
  @Param color: ResourceColor = $r('app.color.system_color_divider');
  @Param strokeWidth: string | number = 1;
  @Param gap: Length = $r('app.string.margin_m');

  build() {
    Divider()
      .vertical(false)
      .color(this.color)
      .strokeWidth(this.strokeWidth)
      .lineCap(LineCapStyle.Butt)
      .margin({
        top: this.gap,
        bottom: this.gap,
      });
  }
}