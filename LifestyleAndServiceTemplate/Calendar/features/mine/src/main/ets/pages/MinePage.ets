import {
  UserInfo,
  commonToast,
  UserState,
  getQuickLoginAnonymousPhone,
  SettingItem,
  DividerTmp,
  cancelRelative,
  TextStyleModifier,
  getDataFromJSON,
  AvatarFunctionButton,
  ServiceTitle,
  ThemeModel,
} from 'common';
import { PersistenceV2 } from '@kit.ArkUI';

@ComponentV2
export struct MinePage {
  settingItems: SettingItem[] = [];
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  @Local egDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0')
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @Local userState: UserState = PersistenceV2.connect(UserState, () => new UserState())!;
  @Local modelShow: boolean = false

  initDataSource() {
    this.settingItems = getDataFromJSON<SettingItem>('MinePage-SettingItems.json', this);
    PersistenceV2.save(UserState);
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Scroll() {
        Column() {
          this.buildLogInSettingView()
          this.buildSettingsView()
        }
        .width('100%')
        .constraintSize({ minHeight: '100%' })
        .alignItems(HorizontalAlign.Start)
      }
      .padding({
        top: Number(AppStorage.get('topRectHeight')) + 10,
        left: 16,
        right: 16,
      })
      .width('100%')
      .height('100%')
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.None)
      .backgroundColor($r('sys.color.background_secondary'))

      ServiceTitle({
        title: '我的',
        titleColor: this.theme.themeState.titleColor,
      })
    }
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
  }

  @Builder
  buildLogInSettingView() {
    Row() {
      Row() {
        if (!this.userState.isLogin) {
          Image(
            $r('app.media.avatar_grey'))
            .width(48)
            .height(48)
            .borderRadius($r('sys.float.corner_radius_level10'))
            .margin({ right: 12 })
        } else {
          Column() {
            // 声明FunctionalButton
            AvatarFunctionButton({
              avatarSize: 60,
            })
          }
        }
        if (this.userState.isLogin) {
          Column({ space: 10 }) {
            Text(this.userState.userInfo.userName || $r('app.string.certification_nickname'))
              .attributeModifier(new TextStyleModifier('font_primary/Subtitle_L/Medium'))
            Row({ space: 5 }) {
              Image($r('app.media.mobile_phone'))
                .width(16)
                .height(16)
              Text(this.userState.userInfo.phoneNumber.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2'))
                .attributeModifier(new TextStyleModifier('font_secondary/Body_M/Regular'))
            }
          }.width('30%').alignItems(HorizontalAlign.Start)
        }
        if (!this.userState.isLogin) {
          Text($r('app.string.not_associated'))
            .attributeModifier(new TextStyleModifier('font_secondary/Subtitle_L/Medium'))
        }
      };

      Row({ space: 5 }) {
        Text(this.userState.isLogin ? $r('app.string.disassociate') : $r('app.string.associated_account'))
          .attributeModifier(new TextStyleModifier(`${this.userState.isLogin ? $r('sys.color.font_on_primary') :
          $r('sys.color.font_emphasize')}/Caption_M/Regular`))
      }
      .backgroundColor(this.userState.isLogin ? $r('sys.color.comp_background_tertiary') :
      $r('sys.color.comp_background_tertiary'))
      .borderRadius(16)
      .padding(8)
      .onClick(() => {
        if (this.userState.isLogin) {
          commonToast.show({
            type: 'dialog',
            hasTitle: '取消登录',
            message: $r('app.string.sure_release'),
            confirmAction: () => {
              this.userState.userInfo = new UserInfo()
              this.userState.isLogin = false
              commonToast.hide()
            },
          })
          return
        }
        this.pageInfos.pushPathByName('Login', null)
      })
    }
    .width('100%')
    .margin({ top: 18 })
    .padding({ left: 8, right: 10 })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding(12)
  }

  @Builder
  buildSettingsView() {
    List() {
      ForEach(this.settingItems, (settingItem: SettingItem, idx: number) => {
        ListItem() {
          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
            Row({ space: 16 }) {
              Image($r(settingItem.icon)).width(24).height(24)
              Text(settingItem.name)
                .attributeModifier(new TextStyleModifier('font_primary/Subtitle_M/Medium'))
            }

            Image($r('app.media.chevron_right')).width(7).height(17)
          }
          .padding({
            top: 16,
            bottom: 16,
            left: 12,
            right: 12,
          })
          .onClick(() => {
            switch (settingItem.id) {
              case 'setting':
                this.pageInfos.pushPathByName('SettingLevel', null)
                break;
              case 'information':
                this.pageInfos.pushPathByName('PersonInformation', null)
            }
          })
        }
      }, (settingItem: SettingItem) => settingItem.name)
    }
    .divider(this.egDivider)
    .borderRadius(16)
    .backgroundColor($r('sys.color.background_primary'))
    .margin({ top: 20 })
  }

  aboutToAppear() {
    this.initDataSource()
  }
}
