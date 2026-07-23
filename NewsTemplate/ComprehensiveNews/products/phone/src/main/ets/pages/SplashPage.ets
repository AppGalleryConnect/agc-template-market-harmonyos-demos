import { CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { AdvertisementComponent } from 'module_advertisement'

@Builder
export function SplashPageBuilder() {
  SplashPage()
}

@ComponentV2
struct SplashPage {
  build() {
    Column() {
      AdvertisementComponent({
        adType: 1,
        testAd: 'testd7c5cewoj6',
        skipAd: () => {
          RouterUtils.replacePathByName(RouterMap.INDEX_PAGE);
        }
      })
    }
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
  }
}