import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { AboutModel,
  AgreementModel,
  SettingGroup, SettingItem, SettingType, SettingView, SupportedSetting } from 'app_setting';
import {
  RouterModule,
  RouterMap,
  UserInfoModel,
  CommonDialogUtil,
  HttpApi,
  CommonTitle,
  WindowUtil,
  WindowInfo,
} from 'lib_foundation';


@Builder
export function SettingPageBuilder() {
  SettingPage();
}

@ComponentV2
export struct SettingPage {
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local windowModel: WindowInfo = AppStorageV2.connect(WindowInfo, () => new WindowInfo())!;
  @Local group1: SettingGroup = new SettingGroup();
  @Local group2: SettingGroup = new SettingGroup();
  @Local group3: SettingGroup = new SettingGroup();
  @Local showMask: boolean = true;

  aboutToAppear(): void {
    this.group1.setList([
      new SettingItem()
        .setType(SettingType.ROUTER)
        .setLabel('个人信息')
        .setRouterParam({ routerName: RouterMap.PERSONAL_INFO_PAGE }),
      new SettingItem()
        .setType(SettingType.ROUTER)
        .setLabel('隐私设置')
        .setSupportedType(SupportedSetting.PRIVACY)
        .setExtraParams({
          userAgreement: 'resource://rawfile/static/html/user-agreement.html',
          privacyPolicy: 'resource://rawfile/static/html/privacy-policy.html',
          thirtyItem: 'resource://rawfile/static/html/third-party-info.html',
          personalCollection: 'resource://rawfile/static/html/personal-info-collection.html',
        } as AgreementModel)
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
          copyrightText: '华为xx 版权所有 © 2019-2025',
          hotline: '00000000',
        } as AboutModel),
    ])
  }

  // 退出登录
  openLogoutDialog() {
    CommonDialogUtil.open({ content: '是否确认退出登录？' }, () => {
      HttpApi.userLogout(this.userInfoModel.phone).then(() => {
        this.userInfoModel.isLogin = false;
        this.userInfoModel.isRealName = 0;
        RouterModule.pop();
      })
    })
  }

  build() {
    NavDestination() {
      CommonTitle({
        title: '设置',
      })
      Column() {
        Scroll() {
          Column() {
            SettingView({
              pathStack: RouterModule.stack,
              settingList: [this.group1, this.group2, this.group3],
              isNeedTopPadding: false,
              pagePadding: {
                top: this.windowModel.windowTopPadding,
                bottom: this.windowModel.windowBottomPadding
              }
            })
              .layoutWeight(1)
            if (this.userInfoModel.isLogin) {
              Row() {
                Button('退出登录')
                  .width('100%')
                  .constraintSize({ maxWidth: 360 })
                  .fontColor($r('sys.color.font_primary'))
                  .backgroundColor($r('sys.color.comp_background_tertiary'))
                  .onClick(() => {
                    this.openLogoutDialog();
                  })
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .padding({ left: 28, right: 28 })
            }
          }
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        .padding({
          bottom: this.windowModel.windowBottomPadding + 12
        })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}