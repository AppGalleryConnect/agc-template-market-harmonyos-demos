import { CommonConstants } from 'commonlib';


@ComponentV2
export struct ToolBarHeader {
  @BuilderParam centerBuilder: CustomBuilder
  @Event close: () => void;
  @Event confirm: () => void;

  build() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontColor([$r('sys.color.icon_primary')])
          .fontSize(24)
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.close?.()
      })

      if (this.centerBuilder) {
        this.centerBuilder()
      }

      Button() {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontColor([$r('sys.color.icon_primary')])
          .fontSize(24)
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.confirm?.()
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 4, right: 4 })
  }
}