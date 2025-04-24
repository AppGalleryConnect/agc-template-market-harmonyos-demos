import { BanquetRoomItem } from '../types';


@ComponentV2
export struct BanquetCard {
  @Param @Require
  private banquetItem: BanquetRoomItem;

  build() {
    Flex({
      alignItems: ItemAlign.Center,
    }) {
      if (this.banquetItem.banner) {
        Image(this.banquetItem.banner)
          .height(100)
          .aspectRatio(4 / 3)
          .objectFit(ImageFit.Cover)
          .draggable(false)
          .borderRadius(8)
          .margin({ right: $r('app.string.margin_s') });
      } else {
        Image($r('app.media.ic_no_data'))
          .height(100)
          .aspectRatio(4 / 3)
          .margin({ right: $r('app.string.margin_s') })
          .objectFit(ImageFit.Contain);
      }


      Column() {
        Text(this.banquetItem.banquetName)
          .fontSize($r('app.string.font_size_28'))
          .fontColor('#FF191919')
          .fontWeight(500)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: $r('app.string.margin_s') });

        if (this.banquetItem.profile) {
          Text(this.banquetItem.profile)
            .fontSize($r('app.string.font_size_24'))
            .fontColor('#FF666666')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: $r('app.string.margin_s') });
        }

        Row() {
          ForEach(
            this.banquetItem.labelList,
            (item: string) => {
              this.tagBuilder(item);
            },
            (item: string) => item,
          );
        }
        .margin({ bottom: $r('app.string.margin_xs') });

        Blank();

        Button('立即前往')
          .fontSize($r('app.string.font_size_24'))
          .backgroundColor('#FF007DFF')
          .height(24)
          .padding({
            left: $r('app.string.padding_s'),
            right: $r('app.string.padding_s'),
          });
      }
      .alignItems(HorizontalAlign.Start)
      .height(100)
      .layoutWeight(1);
    }
    .width('100%')
    .height(120)
    .margin({ top: $r('app.string.margin_s'), bottom: $r('app.string.margin_s') })
    .padding({ left: $r('app.string.padding_m'), right: $r('app.string.padding_m') });
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