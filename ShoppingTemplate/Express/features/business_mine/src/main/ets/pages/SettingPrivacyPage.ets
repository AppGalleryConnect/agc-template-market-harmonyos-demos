import {
  SettingGroup,
  SettingItem,
  SettingType,
  SupportedSetting,
  SettingView,
  WebModel,
} from 'app_setting'
import { RouterModule } from 'lib_foundation';


@Builder
export function settingPrivacyPageBuilder() {
  SettingPrivacyPage()
}

@ComponentV2
export struct SettingPrivacyPage {
  @Local recommendItem: SettingItem = new SettingItem();
  @Local noticeItem: SettingItem = new SettingItem()
  @Local group1: SettingGroup = new SettingGroup();
  @Local group2: SettingGroup = new SettingGroup();
  @Local group3: SettingGroup = new SettingGroup();
  @Local group4: SettingGroup = new SettingGroup();

  aboutToAppear(): void {
    // 个性化推荐
    this.recommendItem
      .setType(SettingType.SWITCH)
      .setLabel('个性化推荐')
      .setSwitchValue(true)
      .setClickEvent((isOn) => {
        this.recommendItem.setSwitchValue(isOn as boolean);
      });

    // 通知开关
    this.noticeItem
      .setType(SettingType.SWITCH)
      .setLabel('通知开关')
      .setSwitchValue(true)
      .setClickEvent((isOn) => {
        this.noticeItem.setSwitchValue(isOn as boolean);
      });

    this.group1.setList([this.recommendItem]);

    this.group2.setList([this.noticeItem])

    this.group3.setList([
      new SettingItem()
        .setLabel('用户协议')
        .setSupportedType(SupportedSetting.WEB)
        .setExtraParams({ src: 'resource://rawfile/static/html/user-agreement.html' } as WebModel),
      new SettingItem()
        .setLabel('隐私政策')
        .setSupportedType(SupportedSetting.WEB)
        .setExtraParams({ src: 'resource://rawfile/static/html/privacy-policy.html' } as WebModel),
    ])

    this.group4.setList([
      new SettingItem()
        .setLabel('第三方信息共享清单')
        .setSupportedType(SupportedSetting.WEB)
        .setExtraParams({ src: 'resource://rawfile/static/html/third-party-info.html' } as WebModel),
      new SettingItem()
        .setLabel('个人信息收集清单')
        .setSupportedType(SupportedSetting.WEB)
        .setExtraParams({ src: 'resource://rawfile/static/html/personal-info-collection.html' } as WebModel),
    ])
  }

  build() {
    NavDestination() {
      Column() {
        SettingView({
          pathStack: RouterModule.stack,
          settingList: [this.group1, this.group2, this.group3, this.group4],
        })
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
    }
    .title('设置')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
