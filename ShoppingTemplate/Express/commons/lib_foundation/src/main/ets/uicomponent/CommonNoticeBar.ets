
@ComponentV2
export struct CommonNoticeBar {
  @Param text: ResourceStr = '';
  @Param showIcon: boolean = false;
  @Param icon: Resource = $r('sys.symbol.chevron_right')
  @Event clickAction: () => void;

  build() {
    Row() {
      SymbolGlyph($r('sys.symbol.info_circle_fill'))
        .fontSize(16)
        .fontColor([Color.White])
        .margin({ right: 4 })

      Text(this.text)
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .fontColor(Color.White)
        .lineHeight(16)

      Blank()

      if (this.showIcon) {
        SymbolGlyph(this.icon)
          .fontSize(16)
          .fontColor([Color.White])
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: 12,
      right: 12,
      top: 8,
      bottom: 8,
    })
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_emphasize'))
    .onClick(() => {
      this.clickAction?.();
    })
  }
}