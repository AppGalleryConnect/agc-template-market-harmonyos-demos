import { Constant } from 'common';
import { AccommodationInfo } from 'types';
import { CateringInfo } from 'types';

@ComponentV2
export struct ListItemCard {
  @Param @Require data: CateringInfo | AccommodationInfo;
  @Param @Require routeToDetailPage: (event: ClickEvent) => void;

  build() {
    Row({ space: 8 }) {
      Image(this.data.banner).objectFit(ImageFit.Contain).width('20%');
      Column({ space: 6 }) {
        Text(this.data.name).fontSize(18).fontWeight(500).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis });
        Row() {
          Row() {
            Image($r('app.media.location')).size({ width: 16, height: 16 });
            Text(this.data.address)
              .fontSize(12)
              .maxLines(2)
              .opacity(0.6)
              .width(200)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
          };

          Text(`${this.data.distance === 0 ? '--' : this.data.distance}m`).fontSize(12);
        }.alignItems(VerticalAlign.Top).justifyContent(FlexAlign.SpaceBetween).width(Constant.FULL_PERCENT);

        Row() {
          Text() {
            Span('￥').fontSize(12).fontColor('#E84026').fontWeight(500);
            Span(`${this.data.rating}`)
              .fontColor('#E84026')
              .fontSize(20)
              .fontWeight(500);
          }.textAlign(TextAlign.JUSTIFY);

          Button('预定').backgroundColor('#64BB5C').size({ width: 64, height: 28 });
        }.justifyContent(FlexAlign.SpaceBetween).width(Constant.FULL_PERCENT);
      }.alignItems(HorizontalAlign.Start).width('80%');
    }.onClick(this.routeToDetailPage);
  }
}