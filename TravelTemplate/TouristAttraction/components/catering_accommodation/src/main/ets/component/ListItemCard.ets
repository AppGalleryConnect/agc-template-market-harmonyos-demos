import { AppStorageV2 } from '@kit.ArkUI';
import { UserInfo } from 'module_base';
import { AccommodationInfo, CateringInfo, CateringTabBarType } from '../model/Index';

@ComponentV2
export struct ListItemCard {
  @Param @Require type: CateringTabBarType;
  @Param @Require data: CateringInfo | AccommodationInfo;
  @Param @Require routeToDetailPage: (event: ClickEvent) => void;
  @Local userInfo: UserInfo = AppStorageV2.connect(UserInfo, 'userInfo', () => new UserInfo())!;

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
              .width('calc(80% - 16vp)')
              .textOverflow({ overflow: TextOverflow.Ellipsis });
          }.width('80%');

          Text(`${this.data.distance === 0 ? '--' : this.data.distance}m`).fontSize(12);
        }.alignItems(VerticalAlign.Top).justifyContent(FlexAlign.SpaceBetween).width('100%');

        Row() {
          if (this.type === CateringTabBarType.CATERING && this.data.rating) {
            Row() {
              Rating({ rating: this.data.rating, indicator: true })
                .stars(5)
                .stepSize(0.1);
              Text(`${this.data.rating}`).fontSize(14).fontWeight(500).fontColor('#E84026').margin({ left: 4 });
            };
          } else {
            Text('')
          }

          Button('预定').backgroundColor('#64BB5C').size({ width: 64, height: 28 });
        }.justifyContent(FlexAlign.SpaceBetween).width('100%');
      }.alignItems(HorizontalAlign.Start).width('80%');
    }.height(120).onClick(this.routeToDetailPage);
  }
}