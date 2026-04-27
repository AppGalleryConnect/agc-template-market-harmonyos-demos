import { AdServicePage, AdType, ChannelType } from 'aggregated_ads';
import { CommonConstants, PreferenceUtil, RouterMap, RouterModule } from 'commonlib';

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
      .backgroundColor('#FDF7F8');
    }
    .hideTitleBar(true)
  }

  jumpUrl() {
    let privacyState = PreferenceUtil.getInstance().get(CommonConstants.PRIVACY_POLICY_KEY, '0') as string
    if (privacyState === '1') {
      RouterModule.replace(RouterMap.MAIN_ENTRY)
    } else {
      RouterModule.replace(RouterMap.PRIVACY_POLICY_PAGE)
    }
  }
}