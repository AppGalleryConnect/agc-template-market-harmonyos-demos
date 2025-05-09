import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { advertising, identifier } from '@kit.AdsKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { router } from '@kit.ArkUI';

const TAG = 'TEMPLATE Ads';

enum AdType {
  // 开屏广告的类型
  SPLASH_AD = 1
}

/**
 * 流量变现服务是依托华为终端强大的平台与数据能力为您提供的App流量变现服务，依托HarmonyOS系统让您无需集成SDK，轻松实现广告的接入，
 * 您通过该服务可以在自己的App中获取并向用户展示精美的、高价值的广告内容，并从中获得广告收益，帮助您解决流量变现的难题。
 **/

@Entry
@Component
struct SplashPage {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private oaid: string = '';
  // 广告展示参数
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
          hilog.info(0x0000, TAG, '%{public}s', 'succeeded in requesting permission');
          identifier.getOAID().then((data: string) => {
            this.oaid = data;
            hilog.info(0x0000, TAG, '%{public}s', `succeeded in getting adsIdentifierInfo by promise: ${this.oaid}`);
          }).catch((error: BusinessError) => {
            hilog.error(0x0000, TAG, '%{public}s', `getAdsIdentifierInfo failed, message: ${error.message}`);
          })
        } else {
          hilog.info(0x0000, TAG, '%{public}s', 'user rejected');
        }
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, '%{public}s', `request permission failed, error: ${err.code} ${err.message}`);
      })
    } catch (err) {
      hilog.error(0x0000, TAG, '%{public}s', `catch err, code: ${err.code}, msg: ${err.message}`);
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
      hilog.info(0x0000, TAG, '%{public}s', `routePage  + ${pageUri}`);
      router.replaceUrl(options);
    } catch (error) {
      hilog.error(0x0000, TAG, '%{public}s', `routePage fail callback, code: ${error.code}, msg: ${error.message}`);
    }
  }

  private requestAd(adReqParams: advertising.AdRequestParams, adOptions: advertising.AdOptions): void {
    // 给AdRequestParams设置oaid参数
    adReqParams.oaid = this.oaid;
    // 广告请求回调监听
    const adLoaderListener: advertising.AdLoadListener = {
      // 广告请求失败回调
      onAdLoadFailure: (errorCode: number, errorMsg: string) => {
        hilog.error(0x0000, TAG, '%{public}s', `request ad errorCode is: ${errorCode}, errorMsg is: ${errorMsg}`);
        router.replaceUrl({
          url: 'pages/Index',
        })
      },
      // 广告请求成功回调
      onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
        hilog.info(0x0000, TAG, '%{public}s', 'succeeded in requesting ad!');
        // 保存请求到的广告内容用于展示
        if (canIUse('SystemCapability.Advertising.Ads')) {
          if (ads[0].adType === AdType.SPLASH_AD) {
            this.routePage('pages/SplashFullScreenAdPage', ads, this.adDisplayOptions);
          } else {
            hilog.info(0x0000, TAG, '%{public}s', 'error adType');
          }
        } else {
          router.replaceUrl({
            url: 'pages/Index',
          })
        }
      },
    };
    // 创建AdLoader广告对象
    const load: advertising.AdLoader = new advertising.AdLoader(this.context);
    // 调用广告请求接口
    hilog.info(0x0000, TAG, '%{public}s', 'request ad!');
    load.loadAd(adReqParams, adOptions, adLoaderListener);
  }

  aboutToAppear() {
    try {
      // 使用Promise回调方式获取OAID
      this.requestOAIDTrackingConsentPermissions(this.context);
    } catch (error) {
      hilog.error(0x0000, TAG, '%{public}s', `catch err, code: ${error.code}, message: ${error.message}`);
    }
    hilog.info(0x0000, TAG, '%{public}s', 'aboutToAppear');
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          Column() {
            Image($r('app.media.ic_splash'))
              .width(300)
              .aspectRatio(1)
              .objectFit(ImageFit.Contain)
              .transition(TransitionEffect.asymmetric(TransitionEffect.OPACITY.animation({
                duration: 1000,
                curve: Curve.Ease,
              }), TransitionEffect.OPACITY.animation({
                duration: 0,
              })))
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
        .padding({ bottom: '17%', top: 24 })
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor('#AEE0EB')
        .height('100%')
        .width('100%')
      }
    }
    .height('100%')
    .width('100%')
    .onAppear(() => {
      // 调用开屏广告
      this.requestAd(this.splashImageAdReqParams, this.adOptions)
    })
  }
}