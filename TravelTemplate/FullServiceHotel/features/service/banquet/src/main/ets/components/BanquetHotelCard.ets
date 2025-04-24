@ComponentV2
export struct BanquetHotelCard {
  @Param
  private title: string = '';
  @Param
  private address: string = '';
  @Param
  private cover: PixelMap | ResourceStr | DrawableDescriptor | undefined = undefined;
  @Param
  private maxArea: string = '';
  @Param
  private maxCapacity: string = '';

  build() {
    Column() {
      Image(this.cover)
        .draggable(false)
        .width('100%')
        .aspectRatio(4 / 3)
        .objectFit(ImageFit.Cover)
        .borderRadius(8);
      Row() {
        Text(this.title)
          .fontSize($r('app.string.font_size_36'))
          .fontColor('#FF191919')
          .margin({ right: $r('app.string.margin_s') });
        Row() {
          this.tagBuilder(this.maxCapacity);
          this.tagBuilder(this.maxArea);
        };
      }
      .alignItems(VerticalAlign.Center)
      .margin({ top: $r('app.string.margin_s') });

      Row() {
        Row() {
          Image($r('app.media.icon_local'))
            .height(12)
            .fillColor('#FF666666')
            .objectFit(ImageFit.Contain)
            .draggable(false)
            .margin({ right: 4 });
          Text(this.address)
            .fontSize(11)
            .fontColor('#FF666666');
        }
        .alignItems(VerticalAlign.Center);

        Button('即刻预订')
          .fontSize($r('app.string.font_size_24'))
          .backgroundColor('#FF007DFF')
          .height(24)
          .padding({
            left: $r('app.string.padding_s'),
            right: $r('app.string.padding_s'),
          });
      }
      .margin({ top: $r('app.string.margin_xs') })
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .alignItems(HorizontalAlign.Start)
    .padding({ left: $r('app.string.padding_m'), right: $r('app.string.padding_m') })
    .margin({ bottom: $r('app.string.margin_m') });
  }

  @Builder
  tagBuilder(tag: string) {
    Column() {
      Text(tag)
        .fontSize($r('app.string.font_size_16'))
        .fontColor('#FFFF5121')
        .maxLines(1)
        .margin({ left: $r('app.string.margin_xs'), right: $r('app.string.margin_xs') });
    }
    .height(15)
    .borderWidth(1)
    .borderColor('#FFFF5121')
    .borderRadius(3)
    .justifyContent(FlexAlign.Center)
    .margin({ right: $r('app.string.margin_xs') });
  }
}