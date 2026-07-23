import {
  AboutModel,
  SettingItem,
  SettingGroup,
  SettingType,
  SettingView,
  SupportedSetting,
} from 'app_setting'
import { AppStorageV2 } from '@kit.ArkUI';
import { UserInfo } from 'login_info';
import { GlobalContextUtils, PreferenceUtil, RouterMap, RouterModule } from 'commonlib';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { emitter } from '@kit.BasicServicesKit';
import { Header } from '../components/Header';

@Builder
export function SetUpPageBuilder() {
  SetUpPage();
}

@ComponentV2
export struct SetUpPage {
  @Local logoUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  @Local navPathStack: NavPathStack = new NavPathStack();
  @Local group1: SettingGroup = new SettingGroup()
    .setList([
      new SettingItem()
        .setType(SettingType.ROUTER)
        .setLabel('个人信息')
        .setRouterParam({ routerName: RouterMap.PERSONAL_CENTER_PAGE }),
    ])
  @Local group2: SettingGroup = new SettingGroup()
    .setList([
      new SettingItem()
        .setSupportedType(SupportedSetting.LIGHT_DARK_MODE)
        .setSelectIndex(this.getSelectIndex())
        .setOnChange((colorMode) => {
          // 获取当前应用深浅色模式：colorMode as ConfigurationConstant.ColorMode
          PreferenceUtil.getInstance().put('light_dark', colorMode ?? 0)
        }),
    ])
  @Local group3: SettingGroup = new SettingGroup()
    .setTitle('了解我们如何使用您的数据')
    .setList([
      new SettingItem()
        .setSupportedType(SupportedSetting.WEB)
        .setLabel('隐私协议')
        .setRouterParam({ routerName: 'PrivacyStatementPage' })
    ])
  @Local group4: SettingGroup = new SettingGroup()
    .setTitle('更多')
    .setList([
      new SettingItem()
        .setSupportedType(SupportedSetting.ABOUT)
        .setExtraParams({
          icpText: '苏ICP备17040376号-135A',
          copyrightText: '华为xx 版权所有 © 2019-2025',
          hotline: '00000000',
        } as AboutModel),
      new SettingItem()
        .setSupportedType(SupportedSetting.CLEAR_CACHE),
    ])

  aboutToAppear(): void {

  }

  getSelectIndex(): number {
    let colorMode = Number(PreferenceUtil.getInstance().get('light_dark', 1))
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

  logout(): Promise<void> {
    return this.signOut();
  }

  public async signOut(): Promise<void> {
    return new Promise((resolve) => {
      setTimeout(() => {
        // 退出登录并清除登录信息
        this.logoUser.isLogin = false;
        GlobalContextUtils.showToast({ message: '退出成功~！' });
        RouterModule.pop();
        resolve();
      }, 500);
    });
  }


  build() {
    NavDestination() {
      Column() {
        Header({ title: '设置' })
        SettingView({
          pathStack: RouterModule.getStack(),
          isLogin: true,
          settingList: [this.group1, this.group2, this.group3, this.group4],
          signOutApi: () => this.logout(),
        })
      }
      .width('100%')
      .height('93%')
    }
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
