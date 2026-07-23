@ComponentV2
export struct OperateButton {
  @Param symbol: Resource = $r('sys.symbol.circle');
  @Param text: string = '';
  @Param isActive: boolean = false;
  @Event onTap: () => void = () => {};

  build() {
    Column({ space: 8 }) {
      Row() {
        SymbolGlyph(this.symbol)
          .fontColor(this.isActive ? [$r('sys.color.icon_on_primary')] : [$r('sys.color.icon_primary')])
          .fontSize(24);
      }
      .backgroundColor(this.isActive ? $r('sys.color.multi_color_aux_06') : '#FFFFFF')
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .borderRadius(20);

      Text(this.text)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_on_primary'))
        .lineHeight(19);
    }
    .onClick(this.onTap);
  }
}
