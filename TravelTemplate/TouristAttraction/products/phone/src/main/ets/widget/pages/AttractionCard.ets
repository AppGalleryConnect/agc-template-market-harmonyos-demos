@Extend(Row)
function buttonRow() {
  .backgroundColor($r('sys.color.comp_background_tertiary'))
  .borderRadius(12)
  .width('100%')
  .layoutWeight(1)
  .justifyContent(FlexAlign.Center);
}

@Entry
@ComponentV2
struct AttractionCard {
  /*
   * The action type.
   */
  readonly actionType: string = 'router';
  /*
   * The ability name.
   */
  readonly abilityName: string = 'EntryAbility';
  @Local index: number = 0;
  /*
   * The width percentage setting.
   */
  readonly fullWidthPercent: string = '100%';
  /*
   * The height percentage setting.
   */
  readonly fullHeightPercent: string = '100%';

  build() {
    Column() {
      Row({ space: 12 }) {
        Image($r('app.media.card')).height('100%').aspectRatio(1).borderRadius(16).onClick(() => {
          postCardAction(this, {
            action: this.actionType,
            abilityName: this.abilityName,
            params: { index: 0 },
          });
        });
        Column({ space: 12 }) {
          Row({ space: 16 }) {
            SymbolGlyph($r('sys.symbol.coupon'))
              .fontSize(24)
              .width(24)
              .height(24)
              .fontColor([$r('sys.color.icon_secondary')]);
            Text('前往购票')
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium);
          }
          .buttonRow().onClick(() => {
            postCardAction(this, {
              action: this.actionType,
              abilityName: this.abilityName,
              params: { index: 1 },
            });
          });

          Row({ space: 16 }) {
            Image($r('app.media.card_bag')).size({ width: 24, height: 24 });
            Text('我的订单')
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium);
          }
          .buttonRow().onClick(() => {
            postCardAction(this, {
              action: this.actionType,
              abilityName: this.abilityName,
              params: { index: 3 },
            });
          });
        }.justifyContent(FlexAlign.SpaceBetween).height(this.fullHeightPercent).layoutWeight(1);
      }
      .height(this.fullHeightPercent)
      .width(this.fullWidthPercent)
      .padding(12)
      .backgroundColor($r('sys.color.comp_background_primary'));
    };
  }
}