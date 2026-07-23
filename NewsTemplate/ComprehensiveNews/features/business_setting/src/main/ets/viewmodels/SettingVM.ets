import { ConfigurationConstant } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BaseViewModel, Logger, RouterMap, RouterUtils, SettingModel } from 'lib_common';
import { AccountApi } from 'lib_account';
import { AboutModel, SettingItem, SettingGroup, SettingType, SupportedSetting } from 'module_app_setting';

const TAG = '[SettingViewModel]';

@ObservedV2
export class SettingViewModel extends BaseViewModel {
  private accountInstance: AccountApi = new AccountApi();
  public uiContext: UIContext | null = null;
  @Trace isFocusOnPage: boolean = true;
  @Trace isLoading: boolean = false;
  @Trace list1: SettingItem[] = [
    new SettingItem()
      .setType(SettingType.ROUTER)
      .setLabel('个人信息')
      .setRouterParam({ routerName: RouterMap.SETTING_PERSONAL })
      .setClickEvent(() => {
        if (this.userInfoModel.isLogin) {
          RouterUtils.pushPathByName(RouterMap.SETTING_PERSONAL);
        } else {
          this.contextModel.showToast({ message: '请先登录' });
        }
      }),
    new SettingItem()
      .setType(SettingType.ROUTER)
      .setLabel('隐私设置')
      .setRouterParam({ routerName: RouterMap.SETTING_PRIVACY }),
  ];
  @Trace list2: SettingItem[] = [
    new SettingItem()
      .setSupportedType(SupportedSetting.PUSH_SWITCH)
      .setOnChange((isOn) => {
        this.settingInfo.pushSwitch = isOn as boolean;
      }),
    new SettingItem()
      .setType(SettingType.ROUTER)
      .setLabel('播放与网络设置')
      .setRouterParam({ routerName: RouterMap.SETTING_NETWORK }),
    new SettingItem()
      .setSupportedType(SupportedSetting.CLEAR_CACHE),
  ];
  @Trace list3: SettingItem[] = [
    new SettingItem()
      .setSupportedType(SupportedSetting.LIGHT_DARK_MODE)
      .setSelectIndex(this.getColorIndex())
      .setOnChange((colorMode) => {
        const selectedColorMode = colorMode as ConfigurationConstant.ColorMode;
        this.settingInfo.colorMode = selectedColorMode;
        this.settingInfo.colorModeName = this.settingInfo.getNameByColorMode(selectedColorMode);
      }),
    new SettingItem()
      .setType(SettingType.ROUTER)
      .setLabel('字体大小')
      .setRouterParam({ routerName: RouterMap.SETTING_FONT }),
  ];
  @Trace list4: SettingItem[] = [
    new SettingItem()
      .setSupportedType(SupportedSetting.CHECK_VERSION),
    new SettingItem()
      .setSupportedType(SupportedSetting.ABOUT)
      .setExtraParams({
        icpText: '苏ICP备17040376号-135A',
        copyrightText: '华为xx 版权所有 © 2019-2025',
        hotline: '00000000',
      } as AboutModel),
  ];
  @Trace group1: SettingGroup = new SettingGroup().setList(this.list1);
  @Trace group2: SettingGroup = new SettingGroup().setList(this.list2);
  @Trace group3: SettingGroup = new SettingGroup().setList(this.list3);
  @Trace group4: SettingGroup = new SettingGroup().setList(this.list4);

  requestPushPermission() {
    notificationManager.openNotificationSettings(this.contextModel.globalUIAbilityContext)
      .then(() => {
        this.isFocusOnPage = false;
      })
      .catch((error: BusinessError) => {
        Logger.error(TAG, 'openNotificationSettings fail, error: ' + JSON.stringify(error));
      })
  }

  getColorIndex() {
    if (this.settingInfo.colorMode === 0) {
      return 2;
    }
    if (this.settingInfo.colorMode === 1) {
      return 1;
    }
    return 0;
  }

  signOutApi(): Promise<void> {
    return this.accountInstance.signOut();
  }

  signOutSuccessCb(): void {
    RouterUtils.pop();
  }
}