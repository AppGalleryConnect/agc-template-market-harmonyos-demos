@Extend(Row)
function buttonRow() {
  .backgroundColor('rgba(255, 255, 255, 0.9)')
  .borderRadius(16)
  .padding({
    left: 26,
    right: 26,
    top: 18,
    bottom: 18,
  });
}

@Entry
@Component
struct AttractionCard {
  /*
   * The action type.
   */
  readonly actionType: string = 'router';
  /*
   * The ability name.
   */
  readonly abilityName: string = 'EntryAbility';
  @State index: number = 0;
  /*
   * The width percentage setting.
   */
  readonly fullWidthPercent: string = '100%';
  /*
   * The height percentage setting.
   */
  readonly fullHeightPercent: string = '100%';

  build() {
    Stack() {
      Row().height(150).width(this.fullWidthPercent).backgroundColor('rgba(250, 250, 250, 0.85)').backdropBlur(135);

      Row({ space: 12 }) {
        Image($r('app.media.card')).size({ width: 126, height: 126 }).borderRadius(16).onClick(() => {
          postCardAction(this, {
            action: this.actionType,
            abilityName: this.abilityName,
            params: { index: 0 },
          });
        });
        Column() {
          Row({ space: 16 }) {
            Image($r('app.media.card_ticket')).size({ width: 24, height: 24 });
            Text('前往购票').opacity(0.9);
          }
          .buttonRow().onClick(() => {
            postCardAction(this, {
              action: this.actionType,
              abilityName: this.abilityName,
              params: { index: 1 },
            });
          });

          Row({ space: 16 }) {
            Image($r('app.media.card_guide')).size({ width: 24, height: 24 });
            Text('我的订单').opacity(0.9);
          }
          .buttonRow().onClick(() => {
            postCardAction(this, {
              action: this.actionType,
              abilityName: this.abilityName,
              params: { index: 3 },
            });
          });
        }.justifyContent(FlexAlign.SpaceBetween).height(this.fullHeightPercent);
      }.height(150).width(this.fullWidthPercent).padding(12);
    };
  }
}