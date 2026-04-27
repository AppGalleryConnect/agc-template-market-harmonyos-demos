import { CommonConstants } from 'lib_common';

@ObservedV2
export class SettingItemModel {
  @Trace icon: Resource = $r('sys.symbol.arrow_right');
  @Trace label: string = '';
  @Trace clickEvent: () => void = () => {
  };
}

@ComponentV2
export struct SettingItemView {
  @Require @Param item: SettingItemModel = new SettingItemModel();

  build() {
    Row({ space: 16 }) {
      SymbolGlyph(this.item.icon)
        .fontSize(24)
        .fontColor([$r('sys.color.font_primary')])

      Text(this.item.label)
        .fontSize($r('sys.float.Subtitle_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(24)
        .fontColor([$r('sys.color.font_fourth')])
    }
    .width('100%')
    .constraintSize({ minHeight: 48 })
    .borderRadius(16)
    .padding({
      top: CommonConstants.PADDING_M,
      bottom: CommonConstants.PADDING_M,
      left: CommonConstants.PADDING_S,
      right: CommonConstants.PADDING_S,
    })
    .stateStyles({
      normal: {
        .backgroundColor(Color.Transparent)
      },
      pressed: {
        .backgroundColor($r('sys.color.interactive_pressed'))
      },
    })
    .onClick(() => {
      this.item.clickEvent();
    })
  }
}