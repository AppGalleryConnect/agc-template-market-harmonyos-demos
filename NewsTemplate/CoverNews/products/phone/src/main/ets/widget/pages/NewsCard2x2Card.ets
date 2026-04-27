const storageWidget = new LocalStorage();

@Entry(storageWidget)
@Component
struct NewsCard2x2Card {
  @LocalStorageProp('newsId') newsId: string = '';
  @LocalStorageProp('newsTitle') newsTitle: string = '';
  readonly actionType: string = 'router';
  readonly abilityName: string = 'PhoneAbility';
  readonly fullWidthPercent: string = '100%';
  readonly fullHeightPercent: string = '100%';

  build() {
    Stack() {
      Stack() {
        Image($r('app.media.widget_img'))
          .width(this.fullWidthPercent)
          .height(this.fullHeightPercent)
        Column() {
          Text(this.newsTitle)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2)
            .textAlign(TextAlign.Start)
        }
        .width(this.fullWidthPercent)
        .height(this.fullHeightPercent)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.End)
        .padding(12)
      }
      .width(this.fullWidthPercent)
      .height(this.fullHeightPercent)
      .alignContent(Alignment.Bottom)

      Image($r('app.media.icon_20_20'))
        .width(20)
        .height(20)
        .borderRadius(4)
        .clip(true)
        .margin(12)
    }
    .width(this.fullWidthPercent)
    .height(this.fullHeightPercent)
    .alignContent(Alignment.TopEnd)
    .onClick(() => {
      postCardAction(this, {
        action: this.actionType,
        abilityName: this.abilityName,
        params: {
          newsId: this.newsId,
        },
      });
    })
  }
}