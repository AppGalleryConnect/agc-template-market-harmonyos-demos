import { Constant, HotlineInfo, SystemUtil } from 'module_base';

@ComponentV2
export struct Hotline {
  @Param @Require hotlines: HotlineInfo[];
  @Local showCallTelSheet: boolean = false;
  @Local callPhone: string = '';

  @Builder
  CallTelSheetComponent() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
      Column() {
        Text(this.callPhone)
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
          SystemUtil.triggerForCall(this.getUIContext(), this.callPhone);
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
          this.showCallTelSheet = false;
        });
      }
      .flexGrow(1)
    }
    .width(Constant.FULL_PERCENT)
    .height(Constant.FULL_PERCENT)
    .margin({ left: 8, right: 16, bottom: 16 })
    .constraintSize({ maxWidth: Constant.FULL_PERCENT });
  }

  build() {
    Column({ space: 12 }) {
      ForEach(this.hotlines, (item: HotlineInfo) => {
        Row() {
          Column({ space: 2 }) {
            Text(item.phone)
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium);
            Text(item.title).fontColor($r('sys.color.font_secondary')).fontSize($r('sys.float.Body_M'));
          }.alignItems(HorizontalAlign.Start);

          SymbolGlyph($r('sys.symbol.phone'))
            .width(40)
            .height(40)
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .borderRadius(1000)
            .padding(8)
            .onClick(() => {
              this.callPhone = item.phone;
              this.showCallTelSheet = true;
            });
        }
        .padding(12)
        .backgroundColor($r('sys.color.comp_background_primary'))
        .borderRadius(16)
        .width(Constant.FULL_PERCENT)
        .justifyContent(FlexAlign.SpaceBetween);
      }, (item: HotlineInfo) => item.title.toString());
    }.bindSheet($$this.showCallTelSheet, this.CallTelSheetComponent(), {
      height: 253, title: { title: '联系客服' }, preferType: SheetType.CENTER,
    });
  }
}