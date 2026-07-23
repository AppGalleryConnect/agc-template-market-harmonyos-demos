import { AppStorageV2 } from '@kit.ArkUI';
import { Constant, UserInfo } from 'module_base';
import { AccommodationInfo, CateringInfo, CateringTabBarType } from '../model/Index';

@ComponentV2
export struct ListItemCard {
  @Param @Require type: CateringTabBarType;
  @Param @Require data: CateringInfo | AccommodationInfo;
  @Param @Require routeToDetailPage: (event: ClickEvent) => void;
  @Local userInfo: UserInfo = AppStorageV2.connect(UserInfo, 'userInfo', () => new UserInfo())!;

  build() {
    Row({ space: 16 }) {
      Image(this.data.banner).objectFit(ImageFit.Contain).width(72).height(96);
      Column({ space: 6 }) {
        Column({ space: 4 }) {
          Text(this.data.name)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          Row() {
            Row({ space: 4 }) {
              SymbolGlyph($r('sys.symbol.local'))
                .width(16)
                .height(16)
                .fontSize(16)
                .fontColor([$r('sys.color.icon_secondary')])
              Text(this.data.address)
                .fontSize($r('sys.float.Body_S'))
                .maxLines(2)
                .fontColor($r('sys.color.font_secondary'))
                .layoutWeight(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
            }.layoutWeight(1).alignItems(VerticalAlign.Top);

          }.width(Constant.FULL_PERCENT);

        }.width(Constant.FULL_PERCENT).alignItems(HorizontalAlign.Start)

        Row() {
          Text() {
            Span('￥').fontSize($r('sys.float.Body_S'))
            Span(`${this.data.startPrice}`).fontSize($r('sys.float.Subtitle_L')).fontWeight(FontWeight.Medium)
            Span(`起`).fontSize($r('sys.float.Body_S'))
          }.fontColor($r('sys.color.warning')).align(Alignment.End);

          Button('预定', { controlSize: ControlSize.SMALL })
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor($r('sys.color.multi_color_04'))
            .width(72);
        }.justifyContent(FlexAlign.SpaceBetween).width('100%');
      }.alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.SpaceBetween).layoutWeight(1).height(96);
    }
    .padding(12)
    .borderRadius(16)
    .onClick(this.routeToDetailPage)
    .backgroundColor($r('sys.color.comp_background_primary'));
  }
}