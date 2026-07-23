import { Constant, SystemUtil } from 'module_base';

@Builder
export function CallTelSheetBuilder(phone: string, uiContext: UIContext, callback: () => void) {
  Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
    Column() {
      Text(phone)
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold);
    }
    .justifyContent(FlexAlign.Center)
    .width(Constant.FULL_PERCENT)
    .flexGrow(3)

    Column({ space: 12 }) {
      Button() {
        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.phone_fill'))
            .width(24)
            .height(24)
            .fontSize(24)
            .fontColor([$r('sys.color.icon_on_primary')]);
          Text('一键拨号');
        };

      }
      .fontColor($r('sys.color.font_on_primary'))
      .width(Constant.FULL_PERCENT)
      .height(40)
      .backgroundColor($r('sys.color.multi_color_04'))
      .onClick(() => {
        SystemUtil.triggerForCall(uiContext, phone);
      });

      Row() {
        Text('取消')
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium);
      }
      .justifyContent(FlexAlign.Center)
      .width(Constant.FULL_PERCENT)
      .height(36)
      .borderRadius(20)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        callback();
      });
    }
    .flexGrow(1)
  }
  .width(Constant.FULL_PERCENT)
  .height(Constant.FULL_PERCENT)
  .margin({ left: 8, right: 16, bottom: 16 })
  .constraintSize({ maxWidth: Constant.FULL_PERCENT });
}