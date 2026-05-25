import { AdServicePage, AdType, ChannelType } from 'aggregated_ads';
import { promptAction } from '@kit.ArkUI';
import { Constants, TCRouter } from 'common';

@Entry
@ComponentV2
export struct LaunchAdPage {
  build() {
    RelativeContainer() {
      AdServicePage({
        channelType: ChannelType.HUAWEI_AD,
        adId: 'testq6zq98hecj',
        adType: AdType.SPLASH_AD,
        closeCallBack: () => {
          // todo 这里需要自行编写路由到其他页面的代码
          TCRouter.replace(Constants.HOME_ROUTER);
        },
      })
    }
    .width('100%')
    .height('100%')
  }
}