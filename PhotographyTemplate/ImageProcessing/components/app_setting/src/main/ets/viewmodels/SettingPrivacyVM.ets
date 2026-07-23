import { SettingPageEnum, SettingType } from '../types/SettingType';
import { BaseViewModel } from '../models/BaseViewModel';
import { SettingItem } from '../types/SettingItem';

@ObservedV2
export class SettingPrivacyVM extends BaseViewModel {
  @Trace userAgreeItem = new SettingItem()
    .setType(SettingType.ROUTER)
    .setLabel('用户协议')
    .setRouterParam({
      routerName: SettingPageEnum.SETTING_AGREEMENT,
      routerParams: this.configInfo.agreementModel.userAgreement,
    })
  @Trace privacyItem = new SettingItem()
    .setType(SettingType.ROUTER)
    .setLabel('隐私政策')
    .setRouterParam({
      routerName: SettingPageEnum.SETTING_AGREEMENT,
      routerParams: this.configInfo.agreementModel.privacyPolicy,
    })
  @Trace thirtyItem = new SettingItem()
    .setType(SettingType.ROUTER)
    .setLabel('第三方信息共享清单')
    .setRouterParam({
      routerName: SettingPageEnum.SETTING_AGREEMENT,
      routerParams: this.configInfo.agreementModel.thirtyItem,
    })
  @Trace personInfoItem = new SettingItem()
    .setType(SettingType.ROUTER)
    .setLabel('个人信息收集清单')
    .setRouterParam({
      routerName: SettingPageEnum.SETTING_AGREEMENT,
      routerParams: this.configInfo.agreementModel.personalCollection,
    })
  @Trace list1: SettingItem[] = [
    this.userAgreeItem,
    this.privacyItem,
  ];
  @Trace list2: SettingItem[] = [
    this.thirtyItem,
    this.personInfoItem,
  ];
}