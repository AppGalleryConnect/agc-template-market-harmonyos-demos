@ComponentV2
export struct CommonDivider {
  build() {
    Divider()
      .vertical(false)
      .color($r('sys.color.comp_divider'))
      .strokeWidth('1px')
      .lineCap(LineCapStyle.Butt)
      .margin({
        top: 8,
        bottom: 8,
      });
  }
}