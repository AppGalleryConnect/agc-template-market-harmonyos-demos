import { SignInClass } from '../model/SignInModel'
import { promptAction } from '@kit.ArkUI'
import { TYCard } from '../common/TYCard'
import { abilityAccessCtrl, common, PermissionRequestResult } from '@kit.AbilityKit';
import { advertising, identifier } from '@kit.AdsKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { RewardAdStatusHandler } from '../model/RewardAdStatusHandler';
import { BannerModel } from '../model/BannerModel';
import { LookADViowModel } from '../viewmodel/LookADViowModel';

/**
 * @usage: 用于激励广告展示和奖励领取场景。提供看广告领奖励功能，支持广告加载、展示、奖励发放。
 * 关键数据结构：SignInClass（签到类，包含coinNumber奖励金额、isClaim是否已领取、isLookAD是否已看广告）、
 * advertising.AdRequestParams（广告请求参数，包含adId广告位ID、adType广告类型）、
 * advertising.AdOptions（广告配置参数）、onLookSuccess（领取成功回调函数，参数为奖励金额）、
 * claimedCount（已领取数量）、adId（广告位ID字符串）、adType（广告类型数字，7为激励广告）、
 * award（奖励按钮文字）。包含if逻辑：根据isClaim判断是否已领取（已领取显示"已完成"，未领取显示奖励按钮），
 * 根据isLookAD判断是否已看广告（未看跳转广告，已看直接领取）。
 * @layout: 使用TYCard卡片布局。内部为横向布局，包含3个奖励项（礼物图标、金币标识、领取按钮垂直排列），
 * 均分宽度，居中对齐。已领取的礼物显示灰色，未领取显示彩色并带金币标识。
 * @constraints: adId广告位ID不能为空（测试用'testx9dtjwj8hp'，正式发布需更换），
 * adType广告类型必须为7（激励广告），onLookSuccess回调函数必须正确处理奖励发放，
 * 需要申请ohos.permission.APP_TRACKING_CONSENT权限获取OAID
 * @isGen: true
 * @fileType: component
 * @zhName: 看广告领奖励组件
 */
@ComponentV2
export struct LookAD {
  @Local list: SignInClass[] = [
    new SignInClass(100),
    new SignInClass(100),
    new SignInClass(100)]
  @Event onLookSuccess: (balance:number) => void
  @Provider('leftCount') claimedCount: number = 0
  @Param adId:string = 'testx9dtjwj8hp'
  @Param adType:number = 7
  @Param award:string = '领看点'
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Local bannerData : BannerModel[] = [
    {bannerimage : $r('app.media.ic_vip_tow')},
  ]
  swiperController: SwiperController = new SwiperController()
  @Param @Require lookADViowModel :LookADViowModel
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
    Column(){
      this.BannerView()
    }
    .width('100%')
    .height(100)
    .borderRadius(16)
  }

  /**
   * 按钮点击事件
   */
  handleButtonClick(item: SignInClass) {
    if (!item.isLookAD) {
      this.toAD(item)
    } else {
      this.updateBalanceAndClaimStatus(item)
    }
  }

  /**
   * 去看广告
   */
  toAD(item: SignInClass) {
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
  //广告轮播图
  @Builder
  BannerView(){
    Swiper(this.swiperController) {
      ForEach(this.bannerData, (item: BannerModel, index: number) => {
        Image(item.bannerimage)
          .width('100%')
          .height(100)
          .objectFit(ImageFit.Contain)
          .borderRadius(16)
          .onClick(() => {
           this.lookADViowModel.BannerOnClick(index)
          })
      }, (item: BannerModel) => JSON.stringify(item))
    }
    .loop(true)
    .autoPlay(true)
    .interval(3000)
    .indicator(false)
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