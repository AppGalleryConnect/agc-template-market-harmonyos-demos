import { BaseViewModel } from 'lib_common';
import { AccountApi } from 'lib_account';
import { SettingGroup, SettingItem, SettingType, SupportedSetting, WebModel } from 'module_app_setting';

@ObservedV2
export class SettingPrivacyVM extends BaseViewModel {
  private accountInstance: AccountApi = new AccountApi();
  @Trace personalizedPushItem: SettingItem = new SettingItem()
    .setType(SettingType.SWITCH)
    .setLabel('个性化推荐')
    .setSubLabel('推荐符合我的个性化内容')
    .setSwitchValue(this.settingInfo.personalizedPush)
    .setClickEvent((isOn) => {
      this.personalizedPushItem.setSwitchValue(isOn as boolean);
      this.settingInfo.personalizedPush = isOn as boolean;
    })
  @Trace list1: SettingItem[] = [
    this.personalizedPushItem,
  ];
  @Trace list2: SettingItem[] = [
    new SettingItem()
      .setSupportedType(SupportedSetting.WEB)
      .setLabel('用户协议')
      .setExtraParams({ src: this.accountInstance.getUserAgreeInfo() } as WebModel),
    new SettingItem()
      .setSupportedType(SupportedSetting.WEB)
      .setLabel('隐私政策')
      .setExtraParams({ src: this.accountInstance.getPrivacyInfo() } as WebModel),
  ];
  @Trace list3: SettingItem[] = [
    new SettingItem()
      .setSupportedType(SupportedSetting.WEB)
      .setLabel('第三方信息共享清单')
      .setExtraParams({ src: this.accountInstance.getThirdPartyInfo() } as WebModel),
    new SettingItem()
      .setSupportedType(SupportedSetting.WEB)
      .setLabel('个人信息收集清单')
      .setExtraParams({ src: this.accountInstance.getPersonalInfoCollection() } as WebModel),
  ];
  @Trace group1: SettingGroup = new SettingGroup().setList(this.list1);
  @Trace group2: SettingGroup = new SettingGroup().setList(this.list2);
  @Trace group3: SettingGroup = new SettingGroup().setList(this.list3);
}