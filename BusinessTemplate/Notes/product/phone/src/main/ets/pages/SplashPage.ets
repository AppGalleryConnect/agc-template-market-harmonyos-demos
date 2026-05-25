import { AdvertisementComponent } from 'aggregated_ads';
import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
export function buildSplashPage() {
  SplashPage()
}

@Entry
@ComponentV2
export struct SplashPage {
  private static readonly FALLBACK_TIMEOUT_MS: number = 6000;
  private fallbackTimerId: number = -1;
  @Local private hasNavigated: boolean = false;

  aboutToAppear(): void {
    this.fallbackTimerId = setTimeout(() => {
      this.navigateToIndex();
    }, SplashPage.FALLBACK_TIMEOUT_MS);
  }

  aboutToDisappear(): void {
    if (this.fallbackTimerId >= 0) {
      clearTimeout(this.fallbackTimerId);
      this.fallbackTimerId = -1;
    }
  }

  private navigateToIndex(): void {
    if (this.hasNavigated) {
      return;
    }
    this.hasNavigated = true;
    if (this.fallbackTimerId >= 0) {
      clearTimeout(this.fallbackTimerId);
      this.fallbackTimerId = -1;
    }
    try {
      router.replaceUrl({
        url: 'pages/Index',
      });
    } catch (error) {
      hilog.error(0x0000, 'SplashPage', `路由跳转失败: ${JSON.stringify(error)}`);
      try {
        router.pushUrl({
          url: 'pages/Index',
        });
      } catch (pushError) {
        hilog.error(0x0000, 'SplashPage', `pushUrl 也失败: ${JSON.stringify(pushError)}`);
      }
    }
  }


  build() {
    Column(){
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.startIcon'))
          .width('300vp')
          .height('300vp')

        AdvertisementComponent({
          adType: 1,
          testAd: 'testd7c5cewoj6',
          skipAd: () => {
            this.navigateToIndex();
          },
        })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}