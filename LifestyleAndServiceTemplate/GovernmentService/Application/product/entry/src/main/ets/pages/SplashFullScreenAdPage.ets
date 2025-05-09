import { router } from '@kit.ArkUI';
import { advertising, AdComponent } from '@kit.AdsKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'Ads SplashFullScreenAdPage';

@Entry
@Component
struct SplashFullScreenAdPage {
  private ads: Array<advertising.Advertisement> = [];
  private displayOptions?: advertising.AdDisplayOptions;

  aboutToAppear() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Start to splashFullScreenAdPage aboutToAppear');
    const params: Record<string, Object> = router.getParams() as Record<string, Object>;
    if (params && params.ads as Array<advertising.Advertisement> &&
      params.displayOptions as advertising.AdDisplayOptions) {
      this.ads = params.ads as Array<advertising.Advertisement>;
      this.displayOptions = params.displayOptions as advertising.AdDisplayOptions;
    } else {
      hilog.info(0x0000, 'testTag', '%{public}s', 'Router params are empty');
    }
  }

  build() {
    Column() {
      // 运行在提供方进程里
      AdComponent({
        ads: this.ads, displayOptions: this.displayOptions,
        interactionListener: {
          onStatusChanged: (status: string, ad: advertising.Advertisement, data: string) => {
            switch (status) {
              case AdStatus.AD_OPEN:
                hilog.info(0x0000, 'testTag', '%{public}s', 'Status is onAdOpen');
                break;
              case AdStatus.AD_CLICKED:
                hilog.info(0x0000, 'testTag', '%{public}s', 'Status is onAdClick');
                break;
              case AdStatus.AD_CLOSED:
                hilog.info(0x0000, 'testTag', '%{public}s', 'Status is onAdClose');
                router.replaceUrl({
                  url: 'pages/MainPage',
                })
                break;
            }
          }
        }
      })
        .width('100%')
        .height('100%')

    }.width('100%').height('100%')
  }
}

export enum AdStatus {
  AD_OPEN = 'onAdOpen',
  AD_CLICKED = 'onAdClick',
  AD_CLOSED = 'onAdClose'
}