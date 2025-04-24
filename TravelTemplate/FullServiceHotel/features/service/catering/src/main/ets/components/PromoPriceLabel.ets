@ComponentV2
export struct PromoPriceLabel {
  @Param
  promoPrice: string | number = 0;

  @Param
  originalPrice: string | number = 0;

  @Param
  promoFontSize: number | string | Resource = $r('app.string.font_size_48');

  @Param
  originalFontSize: number | string | Resource = $r('app.string.font_size_24');

  build() {
    Row() {
      Text() {
        Span('￥')
          .fontSize(this.originalFontSize)
          .fontColor($r('app.color.system_color_highlight'))
        Span(this.promoPrice ? this.promoPrice.toString() : '')
          .fontSize(this.promoFontSize)
          .fontColor($r('app.color.system_color_highlight'))
        Span(' ').letterSpacing(2)
        Span('￥' + (this.originalPrice ? this.originalPrice : ''))
          .fontSize(this.originalFontSize)
          .fontColor($r('app.color.font_color_level2'))
          .decoration({ type: TextDecorationType.LineThrough })
      }
    }
    .alignItems(VerticalAlign.Bottom);
  }
}