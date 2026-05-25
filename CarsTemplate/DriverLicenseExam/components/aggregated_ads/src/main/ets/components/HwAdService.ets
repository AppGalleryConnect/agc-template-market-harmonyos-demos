import { AdComponent, advertising, identifier } from '@kit.AdsKit';
import { AdStatus, AdType } from '../common/Constant';
import { Prompt } from '@kit.ArkUI';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0xFF00;
const TAG: string = 'HwAdService';

@ComponentV2
export struct HwAdService {
  @Param adId: string = '';
  @Param closeCallBack: () => void = () => {
  };
  @Local oaid: string = '';
  @Local isShow: boolean = false;
  private ads: Array<advertising.Advertisement> = [];
  private splashImageAdReqParams: advertising.AdRequestParams = {
    adId: '',
    adType: AdType.SPLASH_AD,
    adCount: 1,
  };
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private adDisplayOptions: advertising.AdDisplayOptions = {
    mute: false,
  };
  @Local adOptions: advertising.AdOptions = {
    allowMobileTraffic: 0,
    tagForChildProtection: -1,
    tagForUnderAgeOfPromise: -1,
    adContentClassification: 'A',
  };

  aboutToAppear(): void {
    this.splashImageAdReqParams.adId = this.adId;
    try {
      this.requestOAIDTrackingConsentPermissions(this.context);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `requestOAIDTrackingConsent failed, code: ${error.code}, message: ${error.message}`);
    }
  }

  private requestOAIDTrackingConsentPermissions(context: common.Context): void {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    try {
      atManager.requestPermissionsFromUser(context, ['ohos.permission.APP_TRACKING_CONSENT']).then((data) => {
        identifier.getOAID().then((data: string) => {
          this.oaid = data;
          this.requestAd(this.splashImageAdReqParams, this.adOptions);
        }).catch((error: BusinessError) => {
          hilog.error(DOMAIN, TAG, `getOAID failed, code: ${error.code}, message: ${error.message}`);
        });
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, `requestPermissions failed, code: ${err.code}, message: ${err.message}`);
      });
    } catch (err) {
      hilog.error(DOMAIN, TAG, `requestPermissionsFromUser failed: ${JSON.stringify(err)}`);
    }
  }

  private requestAd(adReqParams: advertising.AdRequestParams, adOptions: advertising.AdOptions): void {
    adReqParams.oaid = this.oaid;
    const adLoaderListener: advertising.AdLoadListener = {
      onAdLoadFailure: (errorCode: number, errorMsg: string) => {
        Prompt.showToast({
          message: `Failed to request ad, errorCode is:  ${errorCode} , errorMsg is: ${errorMsg}`,
          duration: 1000,
        });
        this.closeCallBack()
      },
      onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
        if (canIUse('SystemCapability.Advertising.Ads')) {
          this.ads = ads as Array<advertising.Advertisement>;
          this.isShow = true;
        }
      },
    };
    const load: advertising.AdLoader = new advertising.AdLoader(this.context);
    load.loadAd(adReqParams, adOptions, adLoaderListener);
  }

  @Builder
  splashScreenBuilder(he: string) {
    AdComponent({
      ads: this.ads, displayOptions: this.adDisplayOptions,
      interactionListener: {
        onStatusChanged: (status: string) => {
          switch (status) {
            case AdStatus.AD_OPEN:
              break;
            case AdStatus.AD_CLICKED:
              break;
            case AdStatus.AD_CLOSED:
              this.closeCallBack();
              break;
          }
        },
      },
    }).width('100%').height(he);
  }

  @Builder
  splashHalfScreenBuilder() {
    Column() {
      this.splashScreenBuilder('90%');
      Column() {
        Row() {
          Image($r('app.media.video'))
            .width(36)
            .height(36)
            .margin({ right: 8 });
          Text('video')
            .fontColor('#1A1A1A');
        }.margin({ bottom: 8 });

        Text('Copyright © 2022-2024 Huawei Technologies Co., Ltd.')
          .fontColor('#1A1A1A')
          .fontSize(10);
      }
      .height('10%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 16 });
    }.height('100%');
  }

  build() {
    if (this.isShow) {
      if (this.ads[0].isFullScreen) {
        this.splashScreenBuilder('100%');
      } else {
        this.splashHalfScreenBuilder();
      }
    }
  }
}