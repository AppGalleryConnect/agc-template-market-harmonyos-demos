import { SignInClass } from '../model/SignInModel';
import { abilityAccessCtrl, common, PermissionRequestResult } from '@kit.AbilityKit';
import { advertising, identifier } from '@kit.AdsKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BreakpointModel } from 'common';
import { GridRowColSetting } from 'common/src/main/ets/constant/GridRowColSetting';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct LookAD {
  @Local adClick: boolean = true
  @Local list: SignInClass[] = [
    new SignInClass(100),
    new SignInClass(100),
    new SignInClass(100)]
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  // 是否折叠屏展开状态
  @Local collapseExpandState: boolean = GridRowColSetting.checkColumnCountModel();

  @Monitor('breakPointModel.currentBreakpoint')
  breakPointChange() {
    this.collapseExpandState = GridRowColSetting.checkColumnCountModel()
  }

  @Event onLookSuccess: (balance: number) => void
  @Provider('leftCount') claimedCount: number = 0
  @Param adId: string = 'testx9dtjwj8hp'
  @Param adType: number = 7
  @Param award: string = '领看点'
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
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
    Row() {
      if (this.collapseExpandState) {
        Image($r('app.media.ic_banner'))
          .width('49%')
          .objectFit(ImageFit.Contain)
          .borderRadius(12)
          .onClick(() => {
            this.handleButtonClick()
          })
        Image($r('app.media.ic_banner_expand'))
          .width('49%')
          .objectFit(ImageFit.Contain)
          .borderRadius(12)
          .onClick(() => {
            this.handleButtonClick()
          })
      } else {
        Image($r('app.media.ic_banner'))
          .width('100%')
          .objectFit(ImageFit.Contain)
          .borderRadius(12)
          .onClick(() => {
            this.handleButtonClick()
          })
      }
    }.width('100%').justifyContent(FlexAlign.SpaceBetween)
  }

  /**
   * 按钮点击事件
   */
  handleButtonClick() {
    this.toAD()
  }

  /**
   * 去看广告
   */
  toAD() {
    if(this.adClick) {
      this.loadAd()
    } else {
      return
    }
  }

  /**
   * 更新数据
   */
  updateBalanceAndClaimStatus(item: SignInClass) {
    this.onLookSuccess(item.coinNumber)
    item.isClaim = true
    this.claimedCount += 1
  }

  public loadAd(): void {
    this.adClick = false
    // 广告请求回调监听
    const adLoadListener: advertising.AdLoadListener = {
      // 广告请求失败回调
      onAdLoadFailure: (errorCode: number, errorMsg: string) => {
        hilog.error(0x0000, 'testTag', `Failed to load ad. Code is ${errorCode}, message is ${errorMsg}`);
      },
      // 广告请求成功回调
      onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
        this.adClick = true
        hilog.info(0x0000, 'testTag', 'Succeeded in loading ad');
        // 注册激励广告状态监听器
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