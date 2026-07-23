import { PersistenceV2 } from '@kit.ArkUI';
import { baseActionSheet, baseToast, getDataFromJSON } from 'base_apis';
import { RouterModule } from 'router_module';
import {
  DividerTmp,
  NavigationTitle,
  SettingItem as BaseSettingItem,
  SettingLevelItem,
  TextStyleModifier,
  ThemeModel,
  CalendarVM,
  WeekStart,
  UserInfo,
  UserState,
  TABLET_GRID,
  TABLE_COL,
  TABLE_COL_OFFSET,
  SettingState,
} from 'common'
import { ThemeToggleBuilder } from './ThemeToggleBuilder';
import { WeekdayPicker } from './WeekdayPicker';
import { SettingGroup, SettingView, SettingItem, SupportedSetting, AboutModel, WebModel } from 'app_setting';

@Builder
export function SettingLevelBuilder() {
  SettingLevel()
}


@ComponentV2
export struct SettingLevel {
  vm: CalendarVM = CalendarVM.instance
  @Local settingLevelItems: SettingLevelItem[] = [];
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  @Local egDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0')
  @Local dayList: string[] = ['周日', '周一']
  @Local weekStart: WeekStart = PersistenceV2.connect(WeekStart, () => new WeekStart())!;
  @Local userState: UserState = PersistenceV2.connect(UserState, () => new UserState())!;
  @Local settingState: SettingState = PersistenceV2.connect(SettingState, () => new SettingState())!;
  private context: UIContext = this.getUIContext();

  aboutToAppear(): void {
    getDataFromJSON<SettingLevelItem>(this.getUIContext().getHostContext()!,
      'MinePage-Setting-Level-Items.json').forEach(item => {
      this.settingLevelItems.push(new SettingLevelItem(item))
    });
    this.setTheme('theme', this.theme.themeState.name)
    this.setTheme('weekday', this.dayList[this.weekStart.startWeek])
  }

  @Local group1: SettingGroup = new SettingGroup()
    .setTitle('更多')
    .setList([
      new SettingItem()
        .setSupportedType(SupportedSetting.ABOUT)
        .setExtraParams({
          icpText: '苏ICP备17040376号-135A',
          copyrightText: '华为xx 版权所有 © 2019-2026',
          support: '技术支持：xxxxxxxx',
          hotline: '00000000',
        } as AboutModel),
    ])
  @Local group2: SettingGroup = new SettingGroup()
    .setList([
      new SettingItem()
        .setSupportedType(SupportedSetting.PUSH_SWITCH)
        .setSwitchValue(true)
        .setOnChange((isOn) => {
        }),
      new SettingItem()
        .setSwitchValue(this.settingState.updateSwitch)
        .setSupportedType(SupportedSetting.UPDATE_NOTICE)
        .setOnChange((isOn) => {
          // 回调当前推送开关情况
          this.settingState.updateSwitch = isOn as boolean
        }),
    ])

  setTheme(projectName: string, projectValue: string) {
    this.settingLevelItems.forEach((item) => {
      item.classifieds.forEach(value => {
        if (value.id === projectName) {
          value.currentValue = projectValue
        }
      })
    })
  }

  @Builder
  itemHead(text: string) {
    Column() {
      Text(text)
        .attributeModifier(new TextStyleModifier('font_secondary/Body_M/Regular'))
    }
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  themePickerBuilder(item: BaseSettingItem) {
    ThemeToggleBuilder({
      confirm: () => {
        baseActionSheet.close(this.context, 'ThemeToggle')
        item.currentValue = this.theme.themeState.name
      },
    })
  }

  @Builder
  weekdayPickerBuilder(item: BaseSettingItem) {
    WeekdayPicker({
      dayList: this.dayList,
      weekdayConfirm: () => {
        item.currentValue = this.dayList[this.weekStart.startWeek]
        baseActionSheet.close(this.context, 'WeekdayToggle')
      },
    })
  }

  build() {
    NavDestination() {
      NavigationTitle({
        title: '设置',
      })
      GridRow(TABLET_GRID) {
        GridCol({
          span: TABLE_COL,
          offset: TABLE_COL_OFFSET,
        }) {
          Column() {
            List() {
              ForEach(this.settingLevelItems, (value: SettingLevelItem) => {
                ListItem() {
                  Text(value.title)
                    .attributeModifier(new TextStyleModifier('font_secondary/Body_M/Regular'))
                }
                .margin({ bottom: 8 })

                ListItem() {
                  List() {
                    ForEach(value.classifieds, (item: BaseSettingItem) => {
                      ListItem() {
                        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                          Row({ space: 16 }) {
                            Text(item.name)
                              .attributeModifier(new TextStyleModifier('font_primary/Subtitle_M/Medium'))
                          }

                          Row({ space: 5 }) {
                            Text(item.currentValue)
                              .attributeModifier(new TextStyleModifier('font_primary/Body_M/Regular'))
                            Image($r('app.media.chevron_right')).width(12).height(24)
                          }
                        }
                        .padding({
                          top: 16,
                          bottom: 16,
                          left: 12,
                          right: 12,
                        })
                        .onClick(() => {
                          switch (item.id) {
                            case 'theme':
                              baseActionSheet.show(this.context, {
                                id: 'ThemeToggle',
                                height: 260,
                                title: {
                                  title: '主题切换',
                                },
                                customContent: () => {
                                  this.themePickerBuilder(item)
                                },
                              })
                              break;
                            case 'weekday':
                              baseActionSheet.show(this.context, {
                                id: 'WeekdayToggle',
                                height: 300,
                                title: {
                                  title: '周首日',
                                },
                                customContent: () => {
                                  this.weekdayPickerBuilder(item)
                                },
                              })
                              break;
                            case 'privacy':
                              RouterModule.pushPathByName({ url: 'PrivacyPolicyPage' })
                              break;
                            case 'terms':
                              RouterModule.pushPathByName({ url: 'TermsOfServicePage' })
                              break;
                          }
                        })
                      }
                    }, (item: BaseSettingItem) => item.id)
                  }
                  .divider(this.egDivider)
                }
                .backgroundColor($r('sys.color.background_primary'))
                .borderRadius(16)
                .margin({ bottom: 21 })
              }, (value: SettingLevelItem) => value.title)
              ListItem() {
                Column() {
                  SettingView({
                    pathStack: RouterModule.getStack(),
                    themeColor: this.theme.themeState.calendarColor,
                    settingList: [this.group2, this.group1],
                  })
                }
                .width('100%')
              }
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)
            .margin({ left: 16, right: 16, top: 21 })
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

            Button('退出登录')
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor(this.theme.themeState.titleColor)
              .backgroundColor(this.theme.themeState.outColor)
              .width('80%')
              .onClick(() => {
                baseToast.show(this.getUIContext(), {
                  type: 'dialog',
                  hasTitle: '退出登录',
                  message: $r('app.string.sure_release'),
                  confirmAction: () => {
                    this.userState.isLogin = false
                    this.userState.userInfo = new UserInfo()
                    baseToast.hide()
                    RouterModule.pop()
                  },
                })
              })
              .margin({ bottom: 32 })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.SpaceBetween)
        }
      }
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}