import { clearCache, commonToast, ExtendSettingItem, getCache, UserInfo } from 'common';
import { getDataFromJSON } from 'h5';
import { promptAction } from '@kit.ArkUI';

@Component
export struct Settings {
  @StorageLink('isLogin') isLogin: boolean = false;
  @State extendSettingItems: Array<ExtendSettingItem> = [];
  @Consume('pageInfos') pageInfos: NavPathStack
  @StorageLink('userInfo') userInfo: UserInfo = AppStorage.get('userInfo') ?? new UserInfo();
  @State cache: string = ''

  initDataSource() {
    this.extendSettingItems = getDataFromJSON<ExtendSettingItem>('SettingPage-MoreSettings.json', this);
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          this.buildMessagePushView();
          this.buildMoreSettingsView();
        }
        .width('100%')
        .backgroundColor('#F5F5F5')

        Button('退出登录')
          .backgroundColor($r('sys.color.background_tertiary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.warning'))
          .width('80%')
          .onClick(() => {
            commonToast.show({
              type: 'dialog',
              hasTitle: $r('app.string.log_out'),
              message: $r('app.string.log_out_confirm'),
              confirmAction: () => {
                this.isLogin = false
                AppStorage.setOrCreate('isLogin', false)
                AppStorage.setOrCreate('userInfo', '')
                commonToast.hide()
                this.pageInfos.pop();
              },
            })
          })
          .margin({ bottom: Number(AppStorage.get('bottomRectHeight')) + 20 })
      }.height('100%').justifyContent(FlexAlign.SpaceBetween)
    }
    .title('系统设置')
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
  }

  @Builder
  buildMessagePushView() {
    Row() {
      Text($r('app.string.push_notification'))
        .fontColor(Color.Black)
        .fontSize($r('sys.float.Body_M'));
      Toggle({ type: ToggleType.Switch, isOn: AppStorage.get('isAllowPush') ?? true })
        .width(36)
        .height(20)
        .onChange((value) => {
          AppStorage.setOrCreate('isAllowPush', value)
        })
        .selectedColor($r('sys.color.comp_background_emphasize'))
        .switchPointColor($r('sys.color.comp_background_list_card'));
    }
    .width('90%')
    .height(44)
    .borderRadius($r('sys.float.corner_radius_level4'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .margin({ top: 11 })
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  buildMoreSettingsView() {
    ForEach(this.extendSettingItems, (extendSettingItem: ExtendSettingItem) => {
      Row() {
        Text(extendSettingItem.settingItem.name)
          .fontColor(Color.Black)
          .fontSize($r('sys.float.Body_M'));
        Row({ space: 10 }) {
          Text() {
            Span(this.cache)
            Span('M')
          }
          .fontSize(14)
          .visibility(extendSettingItem.settingItem.name === '清空缓存' ? Visibility.Visible : Visibility.None)

          Image($r(extendSettingItem.settingItem.moreIcon))
            .width(20)
            .height(20)
            .objectFit(ImageFit.Fill);
        }
      }
      .width('90%')
      .height(44)
      .margin(extendSettingItem.isFirst ? { top: 11 } : {})
      .borderWidth({ bottom: 1 })
      .borderColor({ bottom: '#EDEDED' })
      .borderRadius($r('sys.float.corner_radius_level4'))
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        if (extendSettingItem.settingItem.name === '意见反馈') {
          this.pageInfos.pushPathByName('Suggestion', null)
        } else if (extendSettingItem.settingItem.name === '反馈列表') {
          this.pageInfos.pushPathByName('Feedback', null)
        }else if (extendSettingItem.settingItem.name === '隐私声明') {
          this.pageInfos.pushPathByName('PrivacyPolicyPage', null)
        } else {
          commonToast.show({
            type: 'dialog',
            hasTitle: $r('app.string.clear_cache'),
            message: $r('app.string.clear_cache_confirm'),
            confirmAction: () => {
              clearCache(getContext(this)).then(res => {
                if (res === 'success') {
                  promptAction.showToast({ message: $r('app.string.clear_cache_success') })
                  this.getAppCache()
                }
              }).catch(() => {
                promptAction.showToast({ message: $r('app.string.clear_cache_failed') })
              })
              commonToast.hide()
            },
          })
        }
      })
    }, (extendSettingItem: ExtendSettingItem) => JSON.stringify(extendSettingItem))
  }

  @Builder
  buildLogOutView() {
    if (this.isLogin) {
      Button($r('app.string.log_out'))
        .width('90%')
        .height(44)
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .fontColor($r('sys.color.font_emphasize'))
        .margin({ top: 20 })
        .onClick(() => {
          commonToast.show({
            type: 'dialog',
            hasTitle: $r('app.string.log_out'),
            message: $r('app.string.log_out_confirm'),
            confirmAction: () => {
              this.isLogin = false
              AppStorage.setOrCreate('isLogin', '')
              AppStorage.setOrCreate('userInfo', '')
              commonToast.hide()
              this.pageInfos.pop();
            },
          })
        });
    }
  }

  aboutToAppear() {
    this.initDataSource();
    this.getAppCache()
  }

  getAppCache() {
    getCache().then(res => {
      this.cache = (res / (1024 * 1024)).toFixed(0);
    })
  }
}
