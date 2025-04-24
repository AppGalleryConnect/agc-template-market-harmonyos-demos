import { CommonDivider, CommonHeader } from 'componentlib';
import { CommonConstants, FormatUtil, RouterMap, RouterModule, TelUtil } from 'commonlib';
import { MockImageMap } from 'network/src/main/ets/mocks/Constants';

@Builder
export function introductionPageBuilder() {
  IntroductionPage();
}

@ComponentV2
export struct IntroductionPage {
  @Local title: string = '酒店介绍';
  @Local img: PixelMap | ResourceStr | undefined = undefined;

  build() {
    NavDestination() {
      CommonHeader({ title: this.title });
      Scroll() {
        Column() {
          Image(FormatUtil.getImgResource(MockImageMap.IMG_HOTEL_INTRODUCTION))
            .width($r('app.string.width_percent_full'));
        };
      }
      .layoutWeight(1)
      .width($r('app.string.width_percent_full'))
      .edgeEffect(EdgeEffect.Spring)

      Row() {
        Row() {
          Image($r('app.media.ic_tel')).width(20).margin({ right: 10 });
          Text('联系我们');
        }
        .onClick(() => {
          TelUtil.makeCall(CommonConstants.TEL_NUMBER);
        });

        Divider()
          .strokeWidth(1)
          .color($r('app.color.system_color_grey_level1'))
          .vertical(true)
          .height(24)
        Row() {
          Image($r('app.media.ic_address')).width(20).margin({ right: 10 });
          Text('公司地址');
        }
        .onClick(() => {
          RouterModule.push({
            url: RouterMap.COMMON_LOCATION,
          });
        });
      }
      .padding({
        top:$r('app.string.padding_m'),
      })
      .width($r('app.string.width_percent_full'))
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.SpaceAround)
      .borderWidth({
        top: 1,
      })
      .borderColor($r('app.color.system_color_grey_level1'));
    }
    .backgroundColor($r('app.color.system_color_background_white'))
    .height('100%')
    .hideTitleBar(true);
  }
}