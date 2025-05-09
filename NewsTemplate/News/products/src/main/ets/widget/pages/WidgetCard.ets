@Entry
@Component
struct HotelCard {
  readonly MAX_LINES: number = 1;

  readonly ACTION_TYPE: string = 'router';

  readonly ABILITY_NAME: string = 'EntryAbility';

  readonly FULL_WIDTH_PERCENT: string = '100%';

  readonly FULL_HEIGHT_PERCENT: string = '100%';

  build() {
    FormLink({
      action: this.ACTION_TYPE,
      abilityName: this.ABILITY_NAME,
    }) {
      Stack() {
        Image($r('app.media.ic_picture'))
          .width(this.FULL_WIDTH_PERCENT)
          .height(this.FULL_HEIGHT_PERCENT)
          .objectFit(ImageFit.Cover)
        Column() {
          Text('xx新闻资讯')
            .fontSize(16)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor($r('app.color.font_color_level1_invert'))
            .fontWeight(FontWeight.Medium)
            .maxLines(this.MAX_LINES);
        }
        .width(this.FULL_WIDTH_PERCENT)
        .height(this.FULL_HEIGHT_PERCENT)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.End)
        .padding(12);
      }
      .width(this.FULL_WIDTH_PERCENT)
      .height(this.FULL_HEIGHT_PERCENT);
    };
  }
}