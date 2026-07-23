import { SignInClass } from '../model/SignInModel'
import { promptAction, window } from '@kit.ArkUI'
import { TYCard } from '../common/TYCard'
import { abilityAccessCtrl, common, PermissionRequestResult } from '@kit.AbilityKit';
import { advertising, identifier } from '@kit.AdsKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { RewardAdStatusHandler } from '../model/RewardAdStatusHandler';

@ComponentV2
export struct LookAD {
  @Local list: SignInClass[] = [
    new SignInClass(100),
    new SignInClass(100),
    new SignInClass(100)]
  @Event onLookSuccess: (balance: number) => void
  @Provider('leftCount') claimedCount: number = 0
  @Param adId: string = 'testx9dtjwj8hp'
  @Param adType: number = 7
  @Param award: string = '领看点'
  @Param isLogin: boolean = true
  @Event loginFunc: () => void = () => {
  }
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  windowStage: window.WindowStage = AppStorage.get('windowStage') as window.WindowStage;
  mainWin: window.Window = this.windowStage.getMainWindowSync();
  // 广告请求参数
  private adRequestParams: advertising.AdRequestParams = {
    // 'testx9dtjwj8hp'为测试专用的广告位ID，App正式发布时需要改为正式的广告位ID
    adId: this.adId,
    // 激励广告类型
    adType: this.adType
  };
  // 广告配置参数
  private adOptions: advertising.AdOptions = {
    // 设置是否请求非个性化广告
    nonPersonalizedAd: 0,
    // 是否允许流量下载 0：不允许，1：允许，不设置以广告主设置为准
    allowMobileTraffic: 0,
    // 是否希望根据 COPPA 的规定将您的内容视为面向儿童的内容: -1: 默认值，不确定 0: 不希望 1: 希望
    tagForChildProtection: -1,
    // 是否希望按适合未达到法定承诺年龄的欧洲经济区 (EEA) 用户的方式处理该广告请求 -1: 默认值，不确定 0: 不希望 1: 希望
    tagForUnderAgeOfPromise: -1,
    // 设置广告内容分级上限 W: 3+,所有受众 PI: 7+,家长指导 J: 12+,青少年 A: 16+/18+,成人受众
    adContentClassification: 'A'
  };

  async aboutToAppear() {
    // 开放匿名设备标识符
    this.adRequestParams.oaid = await requestOAID(this.context);
  }

  build() {
    TYCard({
      award: this.award
    }) {
      Row() {
        ForEach(this.list, (item: SignInClass, index: number) => {
          Column() {
            Stack({ alignContent: Alignment.Start }) {
              Image(item.isClaim ? $r('app.media.award_gift_d') : $r('app.media.award_gift_l'))
                .width(48)
                .aspectRatio(1)
              if (!item.isClaim) {
                Image($r('app.media.award_coin100'))
                  .width(45)
                  .height(16)
                  .offset({ x: 32, y: -16 })
              }
            }
            .margin({ bottom: 12 })

            Button(item.isClaim ? $r('app.string.completed') : this.award)
              .enabled(!item.isClaim && item.isFirstClick)
              .fontWeight(FontWeight.Medium)
              .fontColor(item.isClaim ? $r('sys.color.font_tertiary') : '#EC6E45')
              .width(72)
              .height(28)
              .backgroundColor(item.isClaim ? $r('sys.color.comp_background_tertiary') : 'rgba(236,110,69,0.1)')
              .onClick(() => {
                if (this.isLogin) {
                  item.isFirstClick = false
                  this.handleButtonClick(item, index)
                  let sysBarProps: window.SystemBarProperties = {
                    statusBarColor: '#00000000',
                    statusBarContentColor: '#ffffff'
                  };
                  try {
                    this.mainWin.setWindowSystemBarProperties(sysBarProps)
                  } catch (e) {
                    console.error(`setWindowSystemBarProperties failed: ${e}`);
                  }
                } else {
                  this.loginFunc()
                }
              })
          }
        }, (item: SignInClass) => item.coinNumber.toString())

      }
      .width('100%')
      .margin({ top: 17 })
      .justifyContent(FlexAlign.SpaceAround)
    }
  }

  /**
   * 按钮点击事件
   */
  handleButtonClick(item: SignInClass, index: number) {
    if (!item.isLookAD) {
      this.toAD(item, index)
    } else {
      this.updateBalanceAndClaimStatus(item)
    }
  }

  /**
   * 去看广告
   */
  toAD(item: SignInClass, index: number) {
    this.getUIContext().getPromptAction().showToast({ message: `去看广告${index + 1}` })
    this.loadAd(item)
  }

  /**
   * 更新数据
   */
  updateBalanceAndClaimStatus(item: SignInClass) {
    this.onLookSuccess(item.coinNumber)
    item.isClaim = true
    this.claimedCount += 1
  }

  public loadAd(item: SignInClass): void {
    // 广告请求回调监听
    const adLoadListener: advertising.AdLoadListener = {
      // 广告请求失败回调
      onAdLoadFailure: (errorCode: number, errorMsg: string) => {
        hilog.error(0x0000, 'testTag', `Failed to load ad. Code is ${errorCode}, message is ${errorMsg}`);
      },
      // 广告请求成功回调
      onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
        hilog.info(0x0000, 'testTag', 'Succeeded in loading ad');
        // 注册激励广告状态监听器
        new RewardAdStatusHandler().registerPPSReceiver(item);
        const adDisplayOptions: advertising.AdDisplayOptions = {
          // 是否静音，默认不静音
          mute: true,
          // ...
        };
        // 此处ads[0]表示请求到的第一个广告，用户根据实际情况选择
        advertising.showAd(ads[0], adDisplayOptions, this.context);
      }
    };
    // 创建AdLoader广告对象
    const adLoader: advertising.AdLoader = new advertising.AdLoader(this.context);
    // 调用广告请求接口
    adLoader.loadAd(this.adRequestParams, this.adOptions, adLoadListener);
  }
}

async function requestOAID(context: Context): Promise<string | undefined> {
  // 向用户请求授权广告跨应用关联访问权限
  let isPermissionGranted: boolean = false;
  try {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    const result: PermissionRequestResult =
      await atManager.requestPermissionsFromUser(context, ['ohos.permission.APP_TRACKING_CONSENT']);
    isPermissionGranted = result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  } catch (err) {
    hilog.error(0x0000, 'testTag', `Failed to request permission. Code is ${err.code}, message is ${err.message}`);
  }
  if (isPermissionGranted) {
    hilog.info(0x0000, 'testTag', 'Succeeded in requesting permission');
    try {
      const oaid = await identifier.getOAID();
      hilog.info(0x0000, 'testTag', 'Succeeded in getting OAID');
      return oaid;
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to get OAID. Code is ${err.code}, message is ${err.message}`);
    }
  } else {
    hilog.error(0x0000, 'testTag', 'Failed to request permission. User rejected');
  }
  return undefined;
}