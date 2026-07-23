import { CommonHeader } from 'component';
import { NavPathName } from 'constant';
import {
  AboutModel,
  SettingGroup,
  SettingItem,
  SettingType,
  SettingView,
  SupportedSetting,
} from 'app_setting';
import { PersonalPopInfo, TenantInfo } from '../model/Index';
import { PersonalInfoVM } from '../viewmodel/PersonalInfoVM';
import { AccountUtil } from 'util';

@Builder
export function AboutBuilder() {
  About();
}

@ComponentV2
export struct About {
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local tenantInfo: TenantInfo | undefined = AppStorage.get('tenantInfo');
  vm: PersonalInfoVM = PersonalInfoVM.instance;

  @Local group1: SettingGroup = new SettingGroup()
    .setList([
      new SettingItem()
        .setType(SettingType.ROUTER)
        .setLabel('个人信息')
        .setRouterParam({ routerName: NavPathName.PERSONAL_INFO }),
      new SettingItem()
        .setSupportedType(SupportedSetting.PRIVACY)
        .setLabel('隐私设置'),
    ])
  @Local group2: SettingGroup = new SettingGroup()
    .setList([
      new SettingItem()
        .setSupportedType(SupportedSetting.CLEAR_CACHE),
    ])
  @Local group3: SettingGroup = new SettingGroup()
    .setList([
      new SettingItem()
        .setSupportedType(SupportedSetting.CHECK_VERSION)
        .setLabel('版本检测'),
      new SettingItem()
        .setSupportedType(SupportedSetting.ABOUT)
        .setLabel('关于我们')
        .setExtraParams({
          hotline: this.tenantInfo?.phone ?? '',
          icpText: '苏ICP备xxxx号-xxx',
          copyrightText: '华为xx 版权所有 © 2019-2026',
        } as AboutModel),
    ])

  @Local userId: string = AccountUtil.getUserId();

  build() {
    NavDestination() {
      Column() {
        CommonHeader({ title: '设置', showBackButton: true, backButtonClick: () => {
          this.mainPathStack.pop();
        }});

        SettingView({
          pathStack: this.mainPathStack,
          settingList: [this.group1, this.group2, this.group3],
          isLogin: this.userId !== '',
          signOutApi: async () => {
            AppStorage.setOrCreate('currentUser', '');
            AppStorage.setOrCreate('openID', '');
            AccountUtil.setUserId('');
            AccountUtil.setAvatar('');
            AccountUtil.setNickName('');
            await this.vm.updatePersonInfo();
            this.mainPathStack.pop({
              type: 1,
              avatar: '',
              nickname: '',
            } as PersonalPopInfo);
          },
        }).layoutWeight(1)
      }.width('100%').height('100%').backgroundColor($r('sys.color.background_secondary'));
    }.hideTitleBar(true);
  }
}
