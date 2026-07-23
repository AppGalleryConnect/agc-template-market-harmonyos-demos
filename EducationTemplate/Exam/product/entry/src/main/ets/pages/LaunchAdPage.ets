import { AdServicePage, AdType, ChannelType } from 'aggregated_ads';
import { PreferConstant, PreferenceUtil, RouterMap, RouterModule } from 'commonlib';

@Builder
export function LaunchAdPageBuilder() {
  LaunchAdPage()
}

@ComponentV2
struct LaunchAdPage {
  build() {
    NavDestination() {
      Column() {
        AdServicePage({
          channelType: ChannelType.HUAWEI_AD,
          // todo 替换广告id
          adId: 'testd7c5cewoj6',
          adType: AdType.SPLASH_AD,
          closeCallBack: () => {
            this.jumpUrl()
          },
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FDF7F8')
    }
    .hideTitleBar(true)
  }

  jumpUrl() {
    //读取状态值，如果为空设置为true
    let isFirstLaunch = PreferenceUtil.getInstance().get(PreferConstant.FIRST_LAUNCH, true) as boolean;
    if (isFirstLaunch) {
      //隐私政策
      RouterModule.replace({ url: RouterMap.PRIVACY_AGREEMENT_PAGE });
      return;
    }
    RouterModule.replace({ url: RouterMap.MAIN_PAGE });
  }
}