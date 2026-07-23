import { RouterMap, RouterModule } from 'lib_foundation';
import { AdvertisementComponent } from 'module_advertisement';

@Builder
export function splashAdBuilder() {
  SplashAd()
}

@ComponentV2
export struct SplashAd {
  build() {
    Column() {
      AdvertisementComponent({
        adType: 1,
        testAd: 'testd7c5cewoj6',
        skipAd: () => {
          RouterModule.replace({ url: RouterMap.MAIN });
        },
      })
    }
    .width('100%')
    .height('100%')
  }
}