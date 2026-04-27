import { SettingGroup, SettingItem, SettingType, SupportedSetting } from 'app_setting';
import {
  AccountUtil,
  CommonConstants,
  DialogParams,
  GlobalContextUtils,
  Logger,
  PreferenceUtil,
  RouterMap,
  RouterModule,
  SettingModel,
  UserInfo
} from 'commonlib';
import { ConfirmDialogComponent } from '../components/ConfirmDialogComponent';
import { PersistenceV2 } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';

@ObservedV2
export class SettingsPageVM {
  @Trace wBuilder: WrappedBuilder<[DialogParams]> = wrapBuilder(ConfirmDialogComponent);
  @Trace userInfo: UserInfo = AccountUtil.getUserInfo();
  @Trace settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
  @Trace list1: SettingItem[] = [
    new SettingItem()
      .setType(SettingType.ROUTER)
      .setLabel('个人信息')
      .setClickEvent(() => {
        RouterModule.push(RouterMap.PERSON_INFO_PAGE)
      }),
  ];
  @Trace list2: SettingItem[] = [
    new SettingItem()
      .setType(SettingType.ROUTER)
      .setLabel('隐私政策')
      .setClickEvent(() => {
        RouterModule.push(RouterMap.TERMS_OF_SERVICE_PAGE)
      }),
  ];
  @Trace list3: SettingItem[] = [
    new SettingItem()
      .setType(SettingType.ROUTER)
      .setLabel('用户协议')
      .setClickEvent(() => {
        RouterModule.push(RouterMap.PRIVACY_POLICY_DETAIL_PAGE)
      }),
  ];
  @Trace list6: SettingItem[] = [
    new SettingItem()
      .setSupportedType(SupportedSetting.LIGHT_DARK_MODE)
      .setSelectIndex(this.getSelectIndex())
      .setOnChange((colorMode) => {
        // 获取当前应用深浅色模式：colorMode as ConfigurationConstant.ColorMode
        PreferenceUtil.getInstance().put(CommonConstants.LIGHT_DARK_KEY, colorMode ?? 0)
      }),
  ];
  @Trace list4: SettingItem[] = [
    new SettingItem()
      .setSupportedType(SupportedSetting.PUSH_SWITCH)
      .setOnChange((isOn) => {
        this.settingInfo.pushSwitch = isOn as boolean;
      }),
    new SettingItem()
      .setSupportedType(SupportedSetting.CLEAR_CACHE)
  ];
  @Trace list5: SettingItem[] = [
    new SettingItem()
      .setSupportedType(SupportedSetting.CHECK_VERSION)
  ];
  @Trace group1: SettingGroup = new SettingGroup().setList(this.list1);
  @Trace group2: SettingGroup = new SettingGroup().setList(this.list2);
  @Trace group3: SettingGroup = new SettingGroup().setList(this.list3);
  @Trace group4: SettingGroup = new SettingGroup().setList(this.list4);
  @Trace group5: SettingGroup = new SettingGroup().setList(this.list5);
  @Trace group6: SettingGroup = new SettingGroup().setList(this.list6);

  logout(): Promise<void> {
    return this.signOut();
  }

  getSelectIndex(): number {
    let colorMode = Number(PreferenceUtil.getInstance().get(CommonConstants.LIGHT_DARK_KEY, 1))
    let selectIndex = 0
    switch (colorMode) {
      case ConfigurationConstant.ColorMode.COLOR_MODE_DARK:
        selectIndex = 2
        break;
      case ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT:
        selectIndex = 1
        break;
      case ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET:
        selectIndex = 0
        break;
      default:
        selectIndex = 0
        break;
    }
    return selectIndex
  }

  public async signOut(): Promise<void> {
    return new Promise((resolve) => {
      setTimeout(() => {
        // 退出登录并清除登录信息
        this.userInfo.id = 0;
        this.userInfo.avatar = '';
        this.userInfo.name = '';
        this.userInfo.nickname = '';
        this.userInfo.sex = '';
        this.userInfo.cellphone = '';
        this.userInfo.birthday = '';
        this.userInfo.code = '';
        this.userInfo.isLogin = false;
        this.userInfo.isMembership = false;
        GlobalContextUtils.showToast({ message: '退出成功~！' });
        RouterModule.pop();
        resolve();
      }, 500);
    });
  }
}