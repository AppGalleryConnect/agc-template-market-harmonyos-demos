import { AboutModel, SettingGroup, SettingItem, SettingType, SupportedSetting } from 'app_setting';
import { BaseViewModel, RouterMap } from 'commonlib';

@ObservedV2
export class SettingPageVM extends BaseViewModel {

  @Trace group1: SettingGroup = new SettingGroup();
  @Trace group2: SettingGroup = new SettingGroup();
  @Trace group3: SettingGroup = new SettingGroup();

  init() {
    this.group1.setList([
      new SettingItem()
        .setType(SettingType.ROUTER)
        .setLabel('个人信息')
        .setRouterParam({ routerName: RouterMap.PERSONAL_INFO_PAGE }),
      new SettingItem()
        .setType(SettingType.ROUTER)
        .setLabel('隐私设置')
        .setSupportedType(SupportedSetting.PRIVACY),
    ]);

    this.group2.setList([
      new SettingItem()
        .setSupportedType(SupportedSetting.CLEAR_CACHE),
    ]);

    this.group3.setList([
      new SettingItem()
        .setSupportedType(SupportedSetting.ABOUT)
        .setExtraParams({
          icpText: '苏ICP备xxxx号-xxx',
          copyrightText: '华为xx 版权所有 © 2019-2026',
          hotline: '00000000',
        } as AboutModel),
    ])
  }
}