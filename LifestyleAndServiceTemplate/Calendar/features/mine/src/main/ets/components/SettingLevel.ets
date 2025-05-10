import {
  commonActionSheet,
  DividerTmp,
  getDataFromJSON,
  NavigationTitle,
  SettingItem,
  SettingLevelItem,
  TextStyleModifier,
  ThemeItem,
  ThemeModel,
  UserState,
} from 'common'
import { PersistenceV2 } from '@kit.ArkUI';
import { ThemeToggleBuilder } from './ThemeToggleBuilder';

@Builder
export function SettingLevelBuilder() {
  SettingLevel()
}


@ComponentV2
export struct SettingLevel {
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @Local settingLevelItems: SettingLevelItem[] = [];
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  @Local egDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0')

  aboutToAppear(): void {
    getDataFromJSON<SettingLevelItem>('MinePage-Setting-Level-Items.json', this).forEach(item => {
      this.settingLevelItems.push(new SettingLevelItem(item))
    });
    this.setTheme()
  }

  setTheme() {
    this.settingLevelItems.forEach((item) => {
      item.classifieds.forEach(value => {
        if(value.id === 'theme') {
          value.currentValue = this.theme.themeState.name
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
  themePickerBuilder(item: SettingItem) {
    ThemeToggleBuilder({
      confirm: () => {
        commonActionSheet.close('ThemeToggle')
        item.currentValue = this.theme.themeState.name
      },
    })
  }

  build() {
    NavDestination() {
      NavigationTitle({
        title: '设置',
      })
      List() {
        ForEach(this.settingLevelItems, (value: SettingLevelItem) => {
          ListItem() {
            Text(value.title)
              .attributeModifier(new TextStyleModifier('font_secondary/Body_M/Regular'))
          }
          .margin({ bottom: 8 })

          ListItem() {
            List() {
              ForEach(value.classifieds, (item: SettingItem) => {
                ListItem() {
                  Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                    Row({ space: 16 }) {
                      Text(item.name)
                        .attributeModifier(new TextStyleModifier('font_primary/Subtitle_M/Medium'))
                    }

                    Row({ space: 5 }) {
                      Text(item.currentValue)
                        .attributeModifier(new TextStyleModifier('font_primary/Body_M/Regular'))
                      Image($r('app.media.chevron_right')).width(7).height(17)
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
                        commonActionSheet.show({
                          id: 'ThemeToggle',
                          height: 300,
                          title: {
                            title: '主题切换',
                          },
                          customContent: () => {
                            this.themePickerBuilder(item)
                          },
                        })
                      break;
                      case 'privacy':
                        this.pageInfos.pushPathByName('PrivacyPolicyPage', null)
                        break;
                      case 'terms':
                        this.pageInfos.pushPathByName('TermsOfServicePage', null)
                        break;
                    }
                  })
                }
              })
            }
            .divider(this.egDivider)
          }
          .backgroundColor($r('sys.color.background_primary'))
          .borderRadius(16)
          .margin({ bottom: 21 })
        })
      }
      .margin({ left: 16, right: 16, top: 21 })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}