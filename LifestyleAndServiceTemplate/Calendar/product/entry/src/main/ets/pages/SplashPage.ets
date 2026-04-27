import { UserState } from 'common';
import { PersistenceV2, router } from '@kit.ArkUI';
import { advertising, identifier } from '@kit.AdsKit';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG: string = '[SplashPage]';

enum AdType {
  // 开屏广告的类型
  SPLASH_AD = 1
}

@Entry
@ComponentV2
struct SplashPage {
  @Local userState: UserState = PersistenceV2.connect(UserState, () => new UserState())!;
  private oaid: string = '';
  private adDisplayOptions: advertising.AdDisplayOptions = {
    // 是否静音，默认不静音
    mute: false,
  }
  // 广告配置
  private adOptions: advertising.AdOptions = {
    // 是否允许流量下载  0不允许 1允许，不设置以广告主设置为准
    allowMobileTraffic: 0,
    // 是否希望根据 COPPA 的规定将您的内容视为面向儿童的内容，: -1默认值，不确定 0不希望 1希望
    tagForChildProtection: -1,
    // 是否希望按适合未达到法定承诺年龄的欧洲经济区 (EEA) 用户的方式处理该广告请求 -1默认值，不确定 0不希望 1希望
    tagForUnderAgeOfPromise: -1,
    // 设置广告内容分级上限: W: 3+,所有受众 PI: 7+,家长指导 J:12+,青少年 A: 16+/18+，成人受众
    adContentClassification: 'A',
  }
  // 开屏图片广告请求参数
  private splashImageAdReqParams: advertising.AdRequestParams = {
    adId: 'testq6zq98hecj',
    adType: AdType.SPLASH_AD,
    adCount: 1,
  }

  private requestOAIDTrackingConsentPermissions(context: common.Context): void {
    // 进入页面时，向用户请求授权广告跨应用关联访问权限
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    try {
      atManager.requestPermissionsFromUser(context, ['ohos.permission.APP_TRACKING_CONSENT']).then((data) => {
        if (data.authResults[0] === 0) {
          UtilLog.info(0x0000, TAG, '%{public}s', 'succeeded in requesting permission');
          identifier.getOAID().then((data: string) => {
            this.oaid = data;
            UtilLog.info(0x0000, TAG, '%{public}s', `succeeded in getting adsIdentifierInfo by promise: ${this.oaid}`);
          }).catch((error: BusinessError) => {
            UtilLog.error(0x0000, TAG, '%{public}s', `getAdsIdentifierInfo failed, message: ${error.message}`);
          })
        } else {
          UtilLog.info(0x0000, TAG, '%{public}s', 'user rejected');
        }
      }).catch((err: BusinessError) => {
        UtilLog.error(0x0000, TAG, '%{public}s', `request permission failed, error: ${err.code} ${err.message}`);
      })
    } catch (err) {
      UtilLog.error(0x0000, TAG, '%{public}s', `catch err, code: ${err.code}, msg: ${err.message}`);
    }
  }

  private routePage(pageUri: string, ads?: Array<advertising.Advertisement | null>,
    displayOptions?: advertising.AdDisplayOptions) {
    let options: router.RouterOptions = {
      url: pageUri,
      params: {
        ads: ads,
        displayOptions: displayOptions,
      },
    }
    try {
      UtilLog.info(0x0000, TAG, '%{public}s', `routePage  + ${pageUri}`);
      this.getUIContext().getRouter().replaceUrl(options);
    } catch (error) {
      UtilLog.error(0x0000, TAG, '%{public}s', `routePage fail callback, code: ${error.code}, msg: ${error.message}`);
    }
  }

  requestAd(adReqParams: advertising.AdRequestParams, adOptions: advertising.AdOptions): void {
    // 给AdRequestParams设置oaid参数
    adReqParams.oaid = this.oaid;
    // 广告请求回调监听
    const adLoaderListener: advertising.AdLoadListener = {
      // 广告请求失败回调
      onAdLoadFailure: (errorCode: number, errorMsg: string) => {
        UtilLog.error(0x0000, TAG, '%{public}s', `request ad errorCode is: ${errorCode}, errorMsg is: ${errorMsg}`);
        this.getUIContext().getRouter().replaceUrl({
          url: 'pages/Index',
        })
      },
      // 广告请求成功回调
      onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
        UtilLog.info(0x0000, TAG, '%{public}s', 'succeeded in requesting ad!');
        // 保存请求到的广告内容用于展示
        if (canIUse('SystemCapability.Advertising.Ads')) {
          if (ads[0].adType === AdType.SPLASH_AD) {
            this.routePage('pages/SplashFullScreenAdPage', ads, this.adDisplayOptions);
          } else {
            UtilLog.info(0x0000, TAG, '%{public}s', 'error adType');
          }
        } else {
          this.getUIContext().getRouter().replaceUrl({
            url: 'pages/Index',
          })
        }
      },
    };
    // 创建AdLoader广告对象
    const load: advertising.AdLoader = new advertising.AdLoader(this.getUIContext().getHostContext() as common.Context);
    // 调用广告请求接口
    UtilLog.info(0x0000, TAG, '%{public}s', 'request ad!');
    try {
      load.loadAd(adReqParams, adOptions, adLoaderListener);
    } catch (e) {
      UtilLog.error(TAG, 'loadAd error' + e)
    }
  }

  init(): void {
    try {
      // 使用Promise回调方式获取OAID
      this.requestOAIDTrackingConsentPermissions(this.getUIContext().getHostContext() as common.Context);
      // 调用开屏广告
      this.requestAd(this.splashImageAdReqParams, this.adOptions)
    } catch (error) {
      UtilLog.error(0x0000, TAG, '%{public}s', `catch err, code: ${error.code}, message: ${error.message}`);
    }
    UtilLog.info(0x0000, TAG, '%{public}s', 'aboutToAppear');
  }

  aboutToAppear(): void {
    setTimeout(() => {
      this.checkAgreedPrivacy();
    }, 0);
  }

  checkAgreedPrivacy(): void {
    if (this.userState.isAgreedPrivacy) {
      this.init();
    } else {
      this.getUIContext().getRouter().replaceUrl({ url: 'pages/SafePage' })
    }
  }

  build() {
    Column() {
      Image($r('app.media.splash_app_icon')).width(108).height(108)
      Column() {
        Text('万年历')
          .fontColor('#7F1D20')
          .fontSize(24)
          .fontWeight(FontWeight.Regular)
        Text('择吉日·看运势·查天气')
          .fontColor('#7F1D20')
          .fontSize(16)
          .fontWeight(FontWeight.Regular)
      }
    }
    .width('100%').height('100%').justifyContent(FlexAlign.SpaceAround)
  }
}
