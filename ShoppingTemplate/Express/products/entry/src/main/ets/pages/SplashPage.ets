import { RouterModule, RouterMap } from 'lib_foundation'
import { AdvertisementComponent } from 'module_advertisement';

@Builder
export function buildSplashPage() {
  SplashPage()
}

@ComponentV2
export struct SplashPage {
  @Local isShowAd: boolean = false;

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        AdvertisementComponent({
          adType: 1,
          testAd: 'testd7c5cewoj6',
          skipAd: () => {
            RouterModule.replace({ url: RouterMap.MAIN_ENTRY })
          },
          showAdCallback: () => {
            this.isShowAd = true;
          }
        })

        Image($r('app.media.app_icon'))
          .width('288px')
          .height('288px')
          .visibility(this.isShowAd ? Visibility.Hidden : Visibility.Visible)
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
  }
}