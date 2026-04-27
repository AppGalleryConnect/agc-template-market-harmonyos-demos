import {
  SettingGroup,
  SettingItem,
  SettingType,
  SupportedSetting,
  SettingView,
  WebModel,
} from 'app_setting'
import { routerStack } from 'lib_foundation'
import { NavTitleBar } from 'lib_widget'

@Builder
export function buildSettingPrivacyPage() {
  SettingPrivacyPage()
}

@ComponentV2
export struct SettingPrivacyPage {
  @Local
  stack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.stack = routerStack.getActiveStack();
  }
  @Local recommendItem: SettingItem = new SettingItem()
    .setType(SettingType.SWITCH)
    .setLabel('个性化推荐')
    .setSwitchValue(true)
    .setClickEvent((isOn) => {
      this.recommendItem.setSwitchValue(isOn as boolean);
    })
  @Local noticeItem: SettingItem = new SettingItem()
    .setType(SettingType.SWITCH)
    .setLabel('通知开关')
    .setSwitchValue(true)
    .setClickEvent((isOn) => {
      this.noticeItem.setSwitchValue(isOn as boolean);
    })
  @Local
  group1: SettingGroup = new SettingGroup()
    .setList([this.recommendItem])
  @Local
  group2: SettingGroup = new SettingGroup()
    .setList([this.noticeItem])
  @Local
  group3: SettingGroup = new SettingGroup()
    .setList([
      new SettingItem()
        .setLabel('用户协议')
        .setSupportedType(SupportedSetting.WEB)
        .setExtraParams({ src: 'resource://rawfile/static/html/user-agreement.html' } as WebModel),
      new SettingItem()
        .setLabel('隐私政策')
        .setSupportedType(SupportedSetting.WEB)
        .setExtraParams({ src: 'resource://rawfile/static/html/privacy-policy.html' } as WebModel),
    ])
  @Local
  group4: SettingGroup = new SettingGroup()
    .setList([
      new SettingItem()
        .setLabel('第三方信息共享清单')
        .setSupportedType(SupportedSetting.WEB)
        .setExtraParams({ src: 'resource://rawfile/static/html/third-party-info.html' } as WebModel),
      new SettingItem()
        .setLabel('个人信息收集清单')
        .setSupportedType(SupportedSetting.WEB)
        .setExtraParams({ src: 'resource://rawfile/static/html/personal-info-collection.html' } as WebModel),
    ])

  public build(): void {
    NavDestination() {
      Column() {
        NavTitleBar({ title: '隐私设置' })

        SettingView({
          pathStack: this.stack,
          settingList: [this.group1, this.group2, this.group3, this.group4],
        })
          .layoutWeight(1)
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
