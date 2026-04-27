import { PersistenceV2 } from '@kit.ArkUI';
import { TextStyleModifier, ThemeItem, ThemeModel, UserState } from 'common';
import { ThemeState } from 'common';
import { baseActionSheet, baseToast } from 'base_apis';
import { RouterModule } from 'router_module';

@ComponentV2
export struct ThemeToggleBuilder {
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  @Local userState: UserState = PersistenceV2.connect(UserState, () => new UserState())!;
  @Local themeChoose: ThemeState = new ThemeState()
  @Event confirm: (themeChoose: ThemeState) => void = () => {
  }
  @Local currentIndex: number = 0
  private themeList: ThemeState[] = [
    {
      id: 'standard',
      name: '标准',
      current: '#f1f3f5',
      outColor: '#ffffff',
      color: '#f1f3f5',
      calendarColor: '#c4272b',
      titleColor: '#000000',
      barColor: '#c4272b',
      buttonColor: '#c4272b',
      tabColor: '#c4272b',
      textColor: '#ffffff',
      tabColorInActive: '#606162',
    },
    {
      id: 'red',
      name: '赤色',
      outColor: '#c4272b',
      current: '#c4272b',
      color: '#c4272b',
      calendarColor: '#c4272b',
      titleColor: '#ffffff',
      barColor: '#ffffff',
      buttonColor: '#c4272b',
      tabColor: '#ffffff',
      textColor: '#ffffff',
      tabColorInActive: '#ffffff',
    },
    {
      id: 'blue',
      name: '墨色',
      outColor: '#4f616d',
      current: '#4f616d',
      color: '#4f616d',
      calendarColor: '#4f616d',
      titleColor: '#ffffff',
      barColor: '#ffffff',
      buttonColor: '#4f616d',
      tabColor: '#ffffff',
      textColor: '#ffffff',
      tabColorInActive: '#ffffff',
    },
  ]

  aboutToAppear(): void {
    this.themeChoose = this.theme.themeState
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceEvenly, alignItems: ItemAlign.Center }) {
        ForEach(this.themeList, (item: ThemeState) => {
          Column({ space: 5 }) {
            Stack() {
              Column()
                .width(48)
                .height(48)
                .backgroundColor(item.color)
                .borderRadius('50%')
              Image($r('app.media.theme_selected')).width(20).height(20)
                .position({ right: 0, bottom: -5 })
                .visibility(this.themeChoose.current === item.color ? Visibility.Visible : Visibility.None)
              Image($r('app.media.vip_icon')).width(24).height(16)
                .position({ right: 0, top: 0 })
                .visibility(item.id === 'blue' ? Visibility.Visible : Visibility.None)
            }

            Text(item.name)
              .attributeModifier(new TextStyleModifier('font_primary/font_primary'))
          }
          .onClick(() => {
            this.themeChoose = item
          })
        }, (item: ThemeItem) => item.id)
      }

      Button('应用')
        .width('100%')
        .fontColor(this.theme.themeState.titleColor)
        .backgroundColor(this.theme.themeState.current)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .padding({ top: 10, bottom: 10 })
        .onClick(() => {
          if (!this.userState.isLogin) {
            baseToast.show(this.getUIContext(), {
              type: 'dialog',
              hasTitle: $r('app.string.associated_account'),
              message: $r('app.string.associated_account_tips'),
              confirmAction: () => {
                baseActionSheet.close(this.getUIContext(), 'ThemeToggle')
                RouterModule.pushPathByName({ url: 'LoginWithHuaweiID' })
                baseToast.hide()
              },
            })
            return
          }
          if (this.themeChoose.id === 'blue' && !this.userState.userInfo.vipInfo.isVip) {
            this.getUIContext().getPromptAction().showToast({ message: '暂未开通会员' })
            return
          }
          this.theme.themeState = this.themeChoose
          PersistenceV2.save(ThemeModel)
          this.confirm(this.themeChoose)
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: 26 })
    .height('100%')
    .padding({ left: 16, right: 16, bottom: Number(AppStorage.get('bottomRectHeight')) + 40 })
  }
}