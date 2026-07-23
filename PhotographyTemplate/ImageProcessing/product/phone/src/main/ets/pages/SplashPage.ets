import { RouterModule, RouterMap, WindowUtil, CommonConstants } from 'commonlib'
import { AdvertisementComponent } from 'module_advertisement';

@Builder
export function buildSplashPage() {
  SplashPage()
}

@ComponentV2
export struct SplashPage {
  @Local isShowAd: boolean = false;

  aboutToAppear(): void {
    WindowUtil.setWindowScreen(true);
  }

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
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .onWillDisappear(() => {
      WindowUtil.setWindowScreen(false);
    })
  }
}