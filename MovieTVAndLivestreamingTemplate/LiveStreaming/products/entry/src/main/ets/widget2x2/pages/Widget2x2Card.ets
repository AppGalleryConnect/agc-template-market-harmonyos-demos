@Entry
@Component
struct Widget1Card {
  /*
  * The max lines.
  */
  readonly maxLines: number = 1;
  /*
  * The action type.
  */
  readonly actionType: string = 'router';
  /*
  * The message.
  */
  readonly message: string = 'add detail';
  /*
  * The ability name.
  */
  readonly abilityName: string = 'EntryAbility';
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
      Image($r('app.media.cover_1'))
        .width(this.fullWidthPercent)
        .height(this.fullHeightPercent)
        .objectFit(ImageFit.Cover)

      Row(){
        Image($r('app.media.app_icon'))
          .width(20)
          .height(20)
          .margin({ right: 5 })

        Text($r('app.string.EntryFormAbility_label'))
          .fontSize($r('app.float.title_immersive_font_size'))
          .fontColor($r('sys.color.gray_01'))
          .fontWeight(FontWeight.Medium)
      }
      .width(this.fullWidthPercent)
      .height(this.fullHeightPercent)
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.Start)
      .padding($r('app.float.column_padding'))

      Row(){
        Column() {
          Text($r('app.string.title_immersive'))
            .fontSize($r('app.float.title_immersive_font_size'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor($r('sys.color.gray_01'))
            .fontWeight(FontWeight.Medium)
            .maxLines(this.maxLines)
          Text($r('app.string.detail_immersive'))
            .fontSize($r('app.float.detail_immersive_font_size'))
            .margin({ top: $r('app.float.item_margin_top') })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor($r('sys.color.gray_04'))
            .fontWeight(FontWeight.Regular)
            .maxLines(this.maxLines)
        }

        .height(this.fullHeightPercent)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.End)

      }
      .width(this.fullWidthPercent)
      .height(this.fullHeightPercent)
      .alignItems(VerticalAlign.Bottom)
      .justifyContent(FlexAlign.Start)
      .padding($r('app.float.column_padding'))
      .linearGradient({
        direction: GradientDirection.Top,
        colors:[[Color.Orange, 0.1], ['transparent', 0.5]]
      })

    }
    .width(this.fullWidthPercent)
    .height(this.fullHeightPercent)
    .onClick(() => {
      postCardAction(this, {
        action: this.actionType,
        abilityName: this.abilityName,
        params: {
          message: this.message
        }
      });
    })
  }
}