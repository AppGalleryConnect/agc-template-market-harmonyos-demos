@Entry
@Component
export struct MiniCard {
  readonly ACTION_TYPE: string = 'router';

  readonly ABILITY_NAME: string = 'EntryAbility';

  build() {
    Row({space:8}) {
      Row() {
        Image($r('app.media.ic_widget_home'))
          .width(30)
          .height(30)
        Text('首页').fontSize(12)
      }
      .onClick(() => {
        postCardAction(this, {
          action: this.ACTION_TYPE,
          abilityName: this.ABILITY_NAME,
          params: {
            cardType:'mini',
            message:'home',
          },
        });
      });
      Row() {
        Image($r('app.media.ic_widget_check_in'))
          .width(30)
          .height(30)
        Text('打卡').fontSize(12)
      }
      .onClick(() => {
        postCardAction(this, {
          action: this.ACTION_TYPE,
          abilityName: this.ABILITY_NAME,
          params: {
            cardType:'mini',
            message:'checkIn',
          },
        });
      });
    }
    .height($r('app.string.height_percent_full'))
    .padding($r('app.string.padding_s'))
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)

  }
}