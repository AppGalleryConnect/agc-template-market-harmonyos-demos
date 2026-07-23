import { common } from '@kit.AbilityKit';
import { SettingPageEnum, SettingType, SupportedSetting } from '../types/SettingType';
import { BaseViewModel } from '../models/BaseViewModel';
import { SettingItem } from '../types/SettingItem';
import { PreferencesUtils, PREF_KEY_LAST_COMMENT_TIME } from '../utils/PreferencesUtils';
import { notificationManager } from '@kit.NotificationKit';

const PREF_KEY_RECOMMEND_SWITCH = 'recommend_switch';
const PREF_KEY_PUSH_SWITCH = 'push_switch';

@ObservedV2
export class SettingPrivacyVM extends BaseViewModel {
  @Trace recommendItem = new SettingItem()
    .setType(SettingType.SWITCH)
    .setLabel('个性化推荐')
    .setSubLabel('向我推荐审核我的个性化内容')
    .setSwitchValue(false)
    .setClickEvent((param?: Object) => {
      const newValue = !this.recommendItem.switchV;
      this.recommendItem.setSwitchValue(newValue);
      this.saveRecommendSwitch(newValue);
    })
  @Trace pushItem = new SettingItem()
    .setType(SettingType.SWITCH)
    .setSupportedType(SupportedSetting.PUSH_SWITCH)
    .setLabel('通知开关')
    .setSwitchValue(false)
    .setClickEvent((param?: Object) => {
      const newValue = !this.pushItem.switchV;
      this.pushItem.setSwitchValue(newValue);
      this.savePushSwitch(newValue);
    })
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
    this.recommendItem,
  ];
  @Trace list2: SettingItem[] = [
    this.pushItem,
  ];
  @Trace list3: SettingItem[] = [
    this.userAgreeItem,
    this.privacyItem,
  ];
  @Trace list4: SettingItem[] = [
    this.thirtyItem,
    this.personInfoItem,
  ];

  async initSwitchStatus(context: common.UIAbilityContext) {
    const prefUtils = PreferencesUtils.getInstance();
    await prefUtils.init(context);
    const recommendValue = await prefUtils.get(PREF_KEY_RECOMMEND_SWITCH, false) as boolean;
    this.recommendItem.setSwitchValue(recommendValue);

    const pushValue = await prefUtils.get(PREF_KEY_PUSH_SWITCH, false) as boolean;
    this.pushItem.setSwitchValue(pushValue);
  }

  async saveRecommendSwitch(value: boolean) {
    const prefUtils = PreferencesUtils.getInstance();
    await prefUtils.put(PREF_KEY_RECOMMEND_SWITCH, value);
  }

  async savePushSwitch(value: boolean) {
    const prefUtils = PreferencesUtils.getInstance();
    await prefUtils.put(PREF_KEY_PUSH_SWITCH, value);
  }
}
