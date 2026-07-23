import { AdComponent, advertising, identifier } from '@kit.AdsKit';
import { abilityAccessCtrl, common, PermissionRequestResult } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonModel } from '@ohos_agcit/driver_license_exam_commonlib';
import { GuideService } from '@ohos_agcit/driver_license_exam_guide';
import { AdServicePage, AdType, ChannelType } from 'aggregated_ads';

@Builder
export function SplashPageBuilder() {
  SplashPage()
}

@ComponentV2
struct SplashPage {
  vm: CommonModel = CommonModel.instance;
  guideService: GuideService = GuideService.instance;

  build() {
    NavDestination() {
      // 华为广告使用
      AdServicePage({
        channelType: ChannelType.HUAWEI_AD,
        adId: 'testq6zq98hecj',
        adType: AdType.SPLASH_AD,
        closeCallBack: () => {
          // 广告结束跳转页面
          if (!this.guideService.isCompleteGuidance()) {
            this.vm.navStack.replacePathByName('guidePage', true)
          } else {
            this.vm.navStack.replacePathByName('MainEntry', true)
          }
        },
      });
    }
    .height('100%')
    .width('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
  }
}