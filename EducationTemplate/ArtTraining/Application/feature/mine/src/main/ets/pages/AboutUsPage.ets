import { AccountUtil, RouterMap, RouterModule, UserInfoModel } from 'commonlib';
import { CommonHeader, ContainerRow } from 'componentlib';

@Builder
export function aboutUsPageBuilder() {
  AboutUsPage();
}

@ComponentV2
export struct AboutUsPage {
  @Local userInfo: UserInfoModel = AccountUtil.getUserInfo();

  build() {
    NavDestination() {
      CommonHeader({ title: '关于我们' });
      Column() {
        Image($r('app.media.img_about_us'))
          .width(96)
          .height(96)
          .margin({
            top: $r('app.string.margin_xl'),
            bottom: $r('app.string.margin_l'),
          });
        Text('艺术培训模板')
          .fontColor($r('app.color.font_color_level1'))
          .lineHeight(20);
        Blank().height(80);
        ContainerRow() {
          Text('隐私声明')
            .layoutWeight(1)
            .fontColor($r('app.color.font_color_level1'))
            .fontSize($r('app.string.font_size_14'));
          Image($r('app.media.ic_arrow_right'))
            .width(16)
            .fillColor($r('app.color.icon_color_level2'))
            .onClick(() => {
              RouterModule.push({
                url: RouterMap.MINE_PRIVACY,
              });
            });
        };
      }
      .layoutWeight(1)
      .backgroundColor($r('app.color.system_color_background_auxiliary'))
      .width($r('app.string.width_percent_full'))
      .padding($r('app.string.padding_l'));

    }
    .hideTitleBar(true);
  }
}
