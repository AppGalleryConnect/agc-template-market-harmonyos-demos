import { AdComponent, advertising, identifier } from '@kit.AdsKit';
import { Prompt, window } from '@kit.ArkUI';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { AdStatus, AdType } from '../constant/Enum';
import { RouterUtils } from '../utils/RouterUtils';

@Builder
export function HwAdPageBuilder() {
  HwAdPage();
}

@ComponentV2
export struct HwAdPage {
  @Local oaid: string = '';
  @Local isShow: boolean = false;
  private ads: Array<advertising.Advertisement> = [];
  private splashImageAdReqParams: advertising.AdRequestParams = {
    // todo 替换为您的广告位ID
    adId: 'testq6zq98hecj',
    adType: AdType.SPLASH_AD,
    adCount: 1,
  };
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private adDisplayOptions: advertising.AdDisplayOptions = {
    mute: false,
  };
  @Local adOptions: advertising.AdOptions = {
    allowMobileTraffic: 0,
    tagForChildProtection: -1,
    tagForUnderAgeOfPromise: -1,
    adContentClassification: 'A',
  };

  setWindowScreen(isFull: boolean) {
    window.getLastWindow(this.getUIContext().getHostContext()).then((win) => {
      win.setWindowLayoutFullScreen(isFull).catch((err: BusinessError) => {
        UtilLog.error('set window layout failed. error: ' + JSON.stringify(err));
      });
    }).catch((err: BusinessError) => {
      UtilLog.error('get last window failed. error: ' + JSON.stringify(err));
    });
  }

  aboutToAppear(): void {
    try {
      this.requestOAIDTrackingConsentPermissions(this.context);
    } catch (error) {
      UtilLog.error(`Catch err, code: ${error.code}, message: ${error.message}`);
    }
  }

  private requestOAIDTrackingConsentPermissions(context: common.Context): void {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    try {
      atManager.requestPermissionsFromUser(context, ['ohos.permission.APP_TRACKING_CONSENT']).then((data) => {
        if (data.authResults[0] === 0) {
          identifier.getOAID().then((data: string) => {
            this.oaid = data;
            this.requestAd(this.splashImageAdReqParams, this.adOptions);
          }).catch((error: BusinessError) => {
            UtilLog.error(`Get Oaid failed, code: ${error.code}, message: ${error.message}`);
          });
        }
      }).catch((err: BusinessError) => {
        UtilLog.error(`Get permission failed, code: ${err.code}, message: ${err.message}`);
      });
    } catch (err) {
      UtilLog.error(`Catch err, code: ${err.code}, message: ${err.message}`);
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
        // 加载广告失败，直接进入首页
        RouterUtils.replacePathByName('Main', null);
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

  build() {
    NavDestination() {
      if (this.isShow) {
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
                  RouterUtils.replacePathByName('Main', null);
                  break;
              }
            },
          },
        }).width('100%').height('100%');
      }
    }.hideTitleBar(true).onShown(() => {
      this.setWindowScreen(true);
    })
    .onHidden(() => {
      this.setWindowScreen(false);
    });
  }
}