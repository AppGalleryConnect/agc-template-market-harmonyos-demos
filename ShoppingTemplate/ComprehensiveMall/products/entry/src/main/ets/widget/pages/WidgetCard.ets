@Entry
@Component
struct WidgetCard {

  /*
   * The action type.
   */
  readonly actionType: string = 'router';
  /*
   * The ability name.
   */
  readonly abilityName: string = 'EntryAbility';
  /*
   * The message.
   */
  readonly message: string = 'add detail';
  /*
   * The height percentage setting.
   */
  readonly fullHeightPercent: string = '100%';

  build() {
    FormLink({
      action: this.actionType,
      abilityName: this.abilityName,
      params: {
        message: this.message
      }
    }) {
      Row() {
        Image($r('app.media.ic_logo'))
          .height(30)
          .objectFit(ImageFit.Contain)
          .margin({ left: 16, right: 16 })
        Text('综合商城')
          .fontSize($r('app.float.font_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }
      .height(this.fullHeightPercent)
      .justifyContent(FlexAlign.Start)
    }
  }
}