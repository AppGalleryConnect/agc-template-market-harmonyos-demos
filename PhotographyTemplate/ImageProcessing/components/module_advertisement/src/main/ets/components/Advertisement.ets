import { common } from '@kit.AbilityKit';
import { AdComponent, advertising, AutoAdComponent } from '@kit.AdsKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { requestOAID } from '../utils/OaidUtils';
import { RewardAdStatusHandler } from '../utils/RewardAdStatusHandler';

const TAG = '[AdvertisementComponent]';

@ComponentV2
export struct AdvertisementComponent {
  // 标识传入的广告类型，当前1为全屏广告，8为横幅广告，与官网保持一致
  @Param @Require adType: number = 1
  // 传入的广告Ad，默认为全屏广告testd7c5cewoj6，横幅广告Ad为'testw6vs28auh3',
  @Param @Require testAd: string
  // 全屏广告的跳过方法
  @Event skipAd: () => void = () => {
  }
  // 广告展示回调
  @Event showAdCallback: () => void = () => {
  }
  // 横幅广告是否可见
  @Local visibilityState: boolean = false;
  // 测试Ad
  @Local ad: advertising.Advertisement | undefined = undefined;
  // 广告请求参数
  @Local adRequestParams: advertising.AdRequestParams = {
    adId: '',
  };
  private oaId: string = '';
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  // 是否超时
  private isTimeOut: boolean = false;
  // 超时时间(单位毫秒)，开发者可根据实际情况修改
  private timeOutDuration: number = 1000;
  // 超时index
  private timeOutIndex: number = -1;
  // 广告配置参数
  private adOptions: advertising.AdOptions = {
    // 是否允许流量下载 0：不允许，1：允许，不设置以广告主设置为准
    allowMobileTraffic: 0,
    // 是否希望根据 COPPA 的规定将您的内容视为面向儿童的内容: -1: 默认值，不确定 0: 不希望 1: 希望
    tagForChildProtection: -1,
    // 是否希望按适合未达到法定承诺年龄的欧洲经济区 (EEA) 用户的方式处理该广告请求 -1: 默认值，不确定 0: 不希望 1: 希望
    tagForUnderAgeOfPromise: -1,
    // 设置广告内容分级上限 W: 3+,所有受众 PI: 7+,家长指导 J: 12+,青少年 A: 16+/18+,成人受众
    adContentClassification: 'A',
  };
  // 横幅广告的宽高比
  private ratio: number = 1;
  // 广告展示参数，默认为全屏广告视频参数
  private adDisplayOptions: advertising.AdDisplayOptions = {
    // 是否静音
    mute: true,
  };
  @Local translateX: string = '-100%'
  @Local adOpen: boolean = false

  aboutToAppear(): void {
    requestOAID(this.context).then((data) => {
      if (data) {
        this.oaId = data
        this.loadAd(this.testAd)
        if (this.adType === 8) {
          this.visibilityState = true;
          if (this.adRequestParams.adWidth && this.adRequestParams.adHeight) {
            // 横幅广告的宽高比
            this.ratio = 328 / 96;
          }
        }
      }
    })
  }

  build() {
    if (this.adType === 1) {
      NavDestination() {
        if (this.ad) {
          this.fullAd()
        }
      }.hideTitleBar(true)
    } else if (this.adType === 3) {
      if (this.ad) {
        this.nativeAd()
      }
    } else {
      if (this.adRequestParams.adId) {
        this.bannerAd()
      }
    }
  }

  @Builder
  private bannerAd() {
    if (this.visibilityState) {
      Row() {
        Stack() {
          AutoAdComponent({
            adParam: this.adRequestParams,
            adOptions: this.adOptions,
            displayOptions: this.adDisplayOptions,
            interactionListener: {
              onStatusChanged: (status: string, ad: advertising.Advertisement, data: string) => {
                switch (status) {
                  case AdStatus.AD_OPEN:
                    UtilLog.info(TAG, `Status is onAdOpen${JSON.stringify(ad)},data:${data}`);
                    this.adOpen = true
                    break;
                  case AdStatus.AD_CLICKED:
                    UtilLog.info(TAG, 'Status is onAdClick');
                    break;
                  case AdStatus.AD_CLOSED:
                    UtilLog.info(TAG, 'Status is onAdClose');
                    this.visibilityState = false;
                    break;
                  case AdStatus.AD_LOAD:
                    UtilLog.info(TAG, 'Status is onAdLoad');
                    break;
                  case AdStatus.AD_FAIL:
                    UtilLog.error(TAG, 'Status is onAdFail');
                    this.visibilityState = false;
                    break;
                }
              },
            },
          })
          Stack() {
            Text()
              .width('100%')
              .height(100)
              .backgroundColor($r('sys.color.background_secondary'))

            Text()
              .width('100%')
              .height(100)
              .translate({ x: this.translateX })
              .onAppear(() => {
                this.translateX = '100%'
              })
              .animation({
                duration: 1500,
                iterations: -1,
              })
              .linearGradient({
                angle: 90,
                colors: [
                  ['rgba(255,255,255,0)', 0],
                  ['rgba(255,255,255,1)', 0.5],
                  ['rgba(255,255,255,0)', 1],
                ],
              })
          }
          .width('100%')
          .height(100)
          .clip(true)
          .visibility(this.adOpen ? Visibility.None : Visibility.Visible)
        }
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  private fullAd() {
    AdComponent({
      ads: [this.ad!],
      displayOptions: this.adDisplayOptions,
      interactionListener: {
        onStatusChanged: (status: string, ad: advertising.Advertisement, data: string) => {
          switch (status) {
            case AdStatus.AD_OPEN:
              UtilLog.info(TAG, `Status is onAdOpen${JSON.stringify(ad)},data:${data}`);
              this.showAdCallback();
              break;
            case AdStatus.AD_CLICKED:
              UtilLog.info(TAG, 'Status is onAdClick');
              break;
            case AdStatus.AD_CLOSED:
              UtilLog.info(TAG, 'Status is onAdClose');
              this.skipAd();
            case AdStatus.AD_FAIL:
              this.skipAd();
              break;
          }
        },
      },
    })
      .zIndex(1)
      .width('100%')
      .height('100%')
  }

  @Builder
  private nativeAd() {
    AdComponent({
      ads: [this.ad!],
      displayOptions: this.adDisplayOptions,
      interactionListener: {
        onStatusChanged: (status: string, ad: advertising.Advertisement, data: string) => {
          switch (status) {
            case AdStatus.AD_OPEN:
              UtilLog.info(TAG, `Status is onAdOpen${JSON.stringify(ad)},data:${data}`);
              this.showAdCallback();
              break;
            case AdStatus.AD_CLICKED:
              UtilLog.info(TAG, 'Status is onAdClick');
              break;
            case AdStatus.AD_CLOSED:
              UtilLog.info(TAG, 'Status is onAdClose');
              this.skipAd();
            case AdStatus.AD_FAIL:
              this.skipAd();
              break;
          }
        },
      },
    })
      .width(312)
      .height(284)
  }

  // 请求广告
  private async loadAd(adId: string): Promise<void> {
    this.adOptions = {
      allowMobileTraffic: 0,
      adContentClassification: 'A',
      tagForUnderAgeOfPromise: -1,
      tagForChildProtection: -1,
    };
    // 1为全屏广告，3为原生广告，7为激励广告，8为横幅广告
    if (this.adType === 1) {
      // 广告请求参数
      this.adRequestParams = {
        // 广告位ID
        adId: adId,
        // 开屏广告类型
        adType: this.adType,
        // 请求的广告数量
        adCount: 1,
        // 开放匿名设备标识符
        oaid: this.oaId,
      };
      this.adDisplayOptions = {
        mute: true,
      };
      // 广告请求回调监听
      const adLoadListener: advertising.AdLoadListener = {
        // 广告请求失败回调
        onAdLoadFailure: (errorCode: number, errorMsg: string) => {
          UtilLog.error(TAG, `Failed to load ad. Code is ${errorCode}, message is ${errorMsg}`);
        },
        // 广告请求成功回调
        onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
          clearTimeout(this.timeOutIndex);
          if (this.isTimeOut) {
            return;
          }
          UtilLog.info(TAG, 'Succeeded in loading ad');
          this.ad = ads[0];
        },
      };
      // 创建AdLoader广告对象
      const adLoader: advertising.AdLoader = new advertising.AdLoader(this.context);
      this.timeOutHandler();
      // 调用广告请求接口
      try {
        adLoader.loadAd(this.adRequestParams, this.adOptions, adLoadListener);
      } catch (e) {
        UtilLog.error(TAG, 'loadAd fail, error: ' + JSON.stringify(e));
      }
    } else if (this.adType === 3) { // 原生广告
      // 广告请求参数
      this.adRequestParams = {
        // 广告位ID
        adId: adId,
        // 开屏广告类型
        adType: this.adType,
        // 开放匿名设备标识符
        oaid: this.oaId,
        // 原生广告扩展参数，是否直接返回广告，不用等待所有广告素材下载完成
        enableDirectReturnVideoAd: true,
      };
      this.adDisplayOptions = {
        mute: false,
      };
      // 广告请求回调监听
      const adLoadListener: advertising.AdLoadListener = {
        // 广告请求失败回调
        onAdLoadFailure: (errorCode: number, errorMsg: string) => {
          UtilLog.error(TAG, `Failed to load ad. Code is ${errorCode}, message is ${errorMsg}`);
        },
        // 广告请求成功回调
        onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
          clearTimeout(this.timeOutIndex);
          if (this.isTimeOut) {
            return;
          }
          UtilLog.info(TAG, 'Succeeded in loading ad');
          this.ad = ads[0];
        },
      };
      // 创建AdLoader广告对象
      const adLoader: advertising.AdLoader = new advertising.AdLoader(this.context);
      this.timeOutHandler();
      // 调用广告请求接口
      try {
        adLoader.loadAd(this.adRequestParams, this.adOptions, adLoadListener);
      } catch (e) {
        UtilLog.error(TAG, 'loadAd fail, error: ' + JSON.stringify(e));
      }
    } else if (this.adType === 7) { // 激励广告
      // 广告请求参数
      this.adRequestParams = {
        // 广告位ID
        adId: adId,
        // 开屏广告类型
        adType: this.adType,
        // 开放匿名设备标识符
        oaid: this.oaId
      };
      // 广告请求回调监听
      const adLoadListener: advertising.AdLoadListener = {
        // 广告请求失败回调
        onAdLoadFailure: (errorCode: number, errorMsg: string) => {
          UtilLog.error(TAG, `Failed to load ad. Code is ${errorCode}, message is ${errorMsg}`);
        },
        // 广告请求成功回调
        onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
          UtilLog.info(TAG, 'Succeeded in loading ad');
          try {
            // 注册激励广告状态监听器
            RewardAdStatusHandler.instance.registerPPSReceiver()
            // 广告展示参数，开发者可根据项目实际情况设置
            const adDisplayOptions: advertising.AdDisplayOptions = {
              // 是否静音
              mute: true,
            };
            // 此处ads[0]表示请求到的第一个广告，开发者可根据项目实际情况选择
            advertising.showAd(ads[0], adDisplayOptions, this.context);
          } catch (e) {
            UtilLog.error(TAG, `Failed to show ad. Code is ${e.code}, message is ${e.message}`);
          }
        }
      };
      // 创建AdLoader广告对象
      const adLoader: advertising.AdLoader = new advertising.AdLoader(this.context);
      try {
        // 调用广告请求接口
        adLoader.loadAd(this.adRequestParams, this.adOptions, adLoadListener);
      } catch (e) {
        UtilLog.error(TAG, `Failed to load ad. Code is ${e.code}, message is ${e.message}`);
      }
    } else  {
      this.adRequestParams = {
        adId: adId,
        adType: this.adType,
        // 宽和高当前只支持360*57和360*144两种尺寸
        adWidth: 360,
        adHeight: 144,
        oaid: this.oaId,
      };
      this.adDisplayOptions = {
        refreshTime: 30000,
      };
    }
  }

  private timeOutHandler(): void {
    this.isTimeOut = false;
    // 超时处理
    this.timeOutIndex = setTimeout(() => {
      this.isTimeOut = true;
      this.skipAd();
      UtilLog.error(TAG, 'Load ad time out');
    }, this.timeOutDuration);
  }
}

// 广告状态变化的枚举值
enum AdStatus {
  AD_OPEN = 'onAdOpen',
  AD_CLICKED = 'onAdClick',
  AD_CLOSED = 'onAdClose',
  AD_LOAD = 'onAdLoad',
  AD_FAIL = 'onAdFail'
}