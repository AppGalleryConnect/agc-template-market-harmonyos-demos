import { AboutModel, SettingGroup, SettingItem, SettingType, SettingView, SupportedSetting } from 'app_setting';
import { iData, routerStack, RouterMap, WindowUtil } from 'lib_foundation';
import { UserApis } from 'lib_network';
import { CommonConfirmDialog, NavTitleBar } from 'lib_widget';

@ComponentV2
export struct SettingPage {
  @Local
  stack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.stack = routerStack.getActiveStack();
  }
  @Local
  group1: SettingGroup = new SettingGroup()
    .setList([
      new SettingItem()
        .setType(SettingType.ROUTER)
        .setLabel('个人信息')
        .setRouterParam({ routerName: RouterMap.USER_PROFILE_EDIT }),
      new SettingItem()
        .setType(SettingType.ROUTER)
        .setLabel('隐私设置')
        .setRouterParam({ routerName: RouterMap.SETTING_PRIVACY }),
    ])
  @Local
  groupDisplayMode: SettingGroup = new SettingGroup()
    .setList([
      new SettingItem()
        .setSupportedType(SupportedSetting.LIGHT_DARK_MODE),
    ])
  @Local
  group2: SettingGroup = new SettingGroup()
    .setList([
      new SettingItem()
        .setSupportedType(SupportedSetting.CLEAR_CACHE),
    ])
  @Local
  group3: SettingGroup = new SettingGroup()
    .setList([
      new SettingItem()
        .setSupportedType(SupportedSetting.ABOUT)
        .setExtraParams({
          icpText: '苏ICP备xxxx号-xxx',
          copyrightText: '华为xx 版权所有 © 2019-2025',
          hotline: '00000000',
        } as AboutModel),
    ])

  public build(): void {
    NavDestination() {
      Column() {
        NavTitleBar({ title: '设置' })

        SettingView({
          pathStack: this.stack,
          settingList: [this.group1, this.groupDisplayMode, this.group2, this.group3],
        })
          .layoutWeight(1)
        if (iData.global.isLogin) {
          Row() {
            Button('退出登录')
              .width('100%')
              .constraintSize({ maxWidth: 360 })
              .fontColor($r('sys.color.font_primary'))
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .onClick(() => {
                CommonConfirmDialog.show({
                  content: '确认退出账号登录吗？',
                  confirm: async () => {
                    const res = await UserApis.logout()
                    if (res.code === 0) {
                      WindowUtil.toast('已退出登录');
                      routerStack.pop();
                    }
                  },
                })
              },
              )
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ left: 28, right: 28 })
          .margin({ top: 12, bottom: 12 })
        }
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .backgroundColor($r('app.color.background_color_grey'))
    }
    .hideTitleBar(true)
  }
}

@Builder
export function buildSettingPage() {
  SettingPage();
}
