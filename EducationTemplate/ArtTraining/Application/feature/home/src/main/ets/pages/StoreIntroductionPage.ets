import { RouterMap, RouterModule, StoreInfo } from 'commonlib';
import { CommonHeader } from 'componentlib';

@Builder
export function storeIntroductionPageBuilder() {
  StoreIntroductionPage();
}

@ComponentV2
export struct StoreIntroductionPage {
  @Local storeInfo: StoreInfo | null = null;

  build() {
    NavDestination() {
      CommonHeader({ title: '关于我们' });
      Scroll() {
        if (this.storeInfo) {
          Column() {
            Image(this.storeInfo.bannerImg)
              .width($r('app.string.width_percent_full'));
            Row() {
              Image(this.storeInfo.logoUrl)
                .width(40)
                .height(40)
                .borderRadius($r('app.string.border_radius_capsule'))
                .margin({ right: $r('app.string.margin_m') });
              Column() {
                Text(this.storeInfo.shopName)
                  .fontColor($r('app.color.font_color_level1'))
                  .fontSize($r('app.string.font_size_14'))
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: $r('app.string.margin_s') });
                Text(this.storeInfo.address)
                  .fontColor($r('app.color.font_color_level2'))
                  .fontSize($r('app.string.font_size_12'));
              }
              .alignItems(HorizontalAlign.Start);
            }
            .padding($r('app.string.padding_l'))
            .justifyContent(FlexAlign.Start);

            Row() {
              Image(this.storeInfo.desc)
                .width($r('app.string.width_percent_full'));
            }
            .padding({
              left: $r('app.string.padding_l'),
              right: $r('app.string.padding_l'),
            })
            .layoutWeight(1);
          }
          .width($r('app.string.width_percent_full'))
          .alignItems(HorizontalAlign.Start);
        }
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring);
    }
    .hideTitleBar(true)
    .onReady(() => {
      const param = RouterModule.getNavParam<StoreInfo>({
        url: RouterMap.HOME_STORE_INTRODUCTION,
      });
      if (param) {
        this.storeInfo = param;
      }
    });
  }
}