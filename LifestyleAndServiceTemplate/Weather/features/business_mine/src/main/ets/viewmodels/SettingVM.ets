import { AccountUtil, RouterMap, RouterModule, UserInfoModel } from 'lib_foundation';
import { SettingGroup, SettingItem, SettingType, SupportedSetting, AboutModel } from 'app_setting';

@ObservedV2
export class SettingVM {
  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();
  @Trace group1: SettingGroup = new SettingGroup()
    .setList([
      new SettingItem()
        .setType(SettingType.ROUTER)
        .setLabel('字号设置')
        .setRouterParam({
          routerName: RouterMap.SETTING_FONT,
        }),
      new SettingItem()
        .setType(SettingType.ROUTER)
        .setLabel('隐私协议')
        .setRouterParam({ routerName: RouterMap.PRIVACY_POLICY }),
    ]);
  @Trace group2: SettingGroup = new SettingGroup()
    .setList([
      new SettingItem()
        .setSupportedType(SupportedSetting.CHECK_VERSION),
      new SettingItem()
        .setSupportedType(SupportedSetting.ABOUT)
        .setExtraParams({
          icpText: '苏ICP备17040376号-135A',
          copyrightText: '天气模板 版权所有 © 2019-2026',
          hotline: '000-000-0000',
        } as AboutModel),
    ]);

  signOutApi(): Promise<void> {
    return new Promise((resolve) => {
      setTimeout(() => {
        AccountUtil.resetInfo();
        resolve();
      }, 500);
    });
  }

  signOutSuccessCb(): void {
    RouterModule.pop();
  }
}