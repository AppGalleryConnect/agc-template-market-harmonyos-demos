import { SettingItem } from '../model/SettingItem';
import { getDataFromJSON } from 'common'
import { UserInfo } from 'common';
import { RouteEntryVM } from 'common'
import { FunctionalButton, functionalButtonComponentManager } from '@hms.core.atomicserviceComponent.atomicserviceUi';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { url } from '@kit.ArkTS';
import { call, observer } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CardInfoList } from 'common'

@Builder
export function MinePageBuilder() {
  MinePage()
}

@Component
export struct MinePage {
  settingItems: Array<SettingItem> = [];
  @StorageLink('isLogin') isLogin: boolean = AppStorage.get('isLogin') ?? false;
  @StorageLink('userInfo') userInfo: UserInfo = AppStorage.get('userInfo') ?? new UserInfo();
  @StorageLink('nickNameValue') nickNameValue: string = '华为用户';
  @StorageLink('avatarUri') avatarUri: ResourceStr = $r('app.media.hd_un_login');
  @State url: ResourceStr = $r('app.media.iconface');
  vm: RouteEntryVM = RouteEntryVM.instance;
  @State isShow: Boolean = false;
  @State phoneNumber: number = 12312341234
  @State cardInfo: CardInfoList = new CardInfoList()

  initDataSource() {
    this.settingItems = getDataFromJSON<SettingItem>('MinePage-SettingItems.json', this);
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Stack() {
            Column() {
              this.buildPersonalSetting()
              // 构建登录配置视图
              this.buildLogInSettingView()
            }
          }

          this.buildCard()
          // 构建配置视图
          this.buildSettingsView()

        }
        .width('100%')
        .height('100%')
        .padding({ left: 16, right: 16 })
        .constraintSize({ minHeight: '100%' })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height('100%')
      .align(Alignment.TopStart)
      .backgroundImageSize(ImageSize.Auto)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .scrollBarWidth('0vp')
      .edgeEffect(EdgeEffect.None)
      .backgroundColor('#F5F5F5')
    }
    .hideTitleBar(true)
  }

  @Builder
  buildPersonalSetting() {
    Row() {
      Text('我的')
        .fontSize('24vp')
        .fontColor($r('sys.color.black'))
      Row() {
        Image($r('app.media.ic_public_setting'))
          .height(16)
          .width(16)
      }
      .width(32)
      .height(32)
      .borderRadius(16)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        if (this.isLogin === false) {
          this.vm.toRouteDetail('Login')
        } else {
          this.vm.toRouteDetail('SettingsPage')
        }
      })
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 8 })
  }

  @Builder
  buildLogInSettingView() {
    Row() {
      Row() {
        // 声明FunctionalButton
        if (this.isLogin === false) {
          Image($r('app.media.hd_un_login'))
            .width($r('app.integer.hd_width'))
            .height($r('app.integer.hd_width'))
            .margin({ right: '8vp' })
            .onClick(() => {
              this.vm.toRouteDetail('Login')
            })
        } else {
          FunctionalButton({
            params: {
              // OpenType.CHOOSE_AVATAR表示Button为选择头像类型
              openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
              label: '',
              // 调整Button样式
              styleOption: {
                styleConfig: new functionalButtonComponentManager.ButtonConfig()
                  .type(ButtonType.Normal)
                  .backgroundImage(this.avatarUri)
                  .backgroundImageSize(ImageSize.Cover)
                  .width($r('app.integer.hd_width'))
                  .height($r('app.integer.hd_width'))
                  .borderRadius($r('sys.float.corner_radius_level10'))
                  .backgroundColor($r('sys.color.white'))
              },
            },
            // OpenType为“CHOOSE_AVATAR”时，回调必须选择“onChooseAvatar”
            controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar(
              (err, data) => {
              if (err) {
                // 错误日志处理
                hilog.error(0x0000, 'testTag', 'error： %{public}d %{public}s', err.code, err.message);
                return;
              }
              // 成功日志处理
              hilog.info(0x0000, 'testTag', 'succeeded in choosing avatar');
              this.avatarUri = data.avatarUri!;
            })
          })
            .margin({ right: '8vp' })
        }


        if (this.isLogin) {
          if (this.nickNameValue) {
            Column() {
              Text(this.nickNameValue)
                .fontColor($r('sys.color.black'))
                .fontSize('16vp')
                .fontWeight(FontWeight.Bold);
            }
          } else {
            Column() {
              Text(this.userInfo.nickName)
                .fontColor($r('sys.color.black'))
                .fontSize('16vp')
                .fontWeight(FontWeight.Bold);
            }
          }
        } else {
          Text('点击登录')
            .fontColor($r('sys.color.black'))
            .fontSize('18vp')
            .fontWeight(500)
            .onClick(() => {
              this.vm.toRouteDetail('Login')
            })
        }
      }

      Image($r('app.media.icon_right'))
        .height(24)
        .width(24)
        .margin({left:15})
        .onClick(()=>{
          if (this.isLogin === false) {
            this.vm.toRouteDetail('Login')
          }else{
            this.vm.toRouteDetail('PersonalSetting')
          }
        })
    }
    .width('100%')
    .height(72)
    .padding({ left: 12 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r('sys.color.white'))
    .borderRadius(16)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  buildCard() {
    Column() {
      Row() {
        Row() {
          Column() {
            Text('我的钱包')
              .fontSize('16vp')
              .margin({ bottom: '2vp' })
            if (this.isLogin) {
              Text() {
                Span(this.cardInfo.balance.toString())
                Span('元')
              }
              .fontColor('#ED6F21')
              .fontSize(12)
            } else {
              Text('  ')
                .fontColor('#ED6F21')
                .fontSize('12vp')
            }
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: '12vp' })

          Image($r('app.media.path'))
            .width('25vp')
            .height('25vp')
            .margin({ left: '32vp' })
        }
        .width(156)
        .height(65)
        .borderRadius(12)
        .backgroundColor($r('app.color.background_color_white'))
        .onClick(() => {
          if (this.isLogin === false) {
            this.vm.toRouteDetail('Login')
          } else {
            this.vm.toRouteDetail('MineWallet')
          }
        })

        Row() {
          Column() {
            Text('我的订单')
              .fontSize('16vp')
              .margin({ bottom: '2vp' })
            Text('查看出行记录')
              .fontColor('#ff454545')
              .fontSize('12vp')
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: '12vp' })

          Image($r('app.media.ic_digital_power_lists_box'))
            .width('19vp')
            .height('24vp')
            .margin({ left: '32vp' })

        }
        .width(156)
        .height(65)
        .borderRadius(12)
        .backgroundColor($r('app.color.background_color_white'))
        .onClick(() => {
          if (this.isLogin === false) {
            this.vm.toRouteDetail('Login')
          } else {
            this.vm.toRouteDetail('MyOrder')
          }
        })

      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)

    }
    .margin({ top: 14 })
  }

  @Builder
  buildSettingsView() {
    Text('帮助中心')
      .fontSize('18lpx')
      .fontWeight(500)
      .margin({ top: '24lpx', bottom: '8lpx' })
    Column() {
      Row() {
        Text() {
          ImageSpan($r('app.media.ic_public_setting'))
            .width($r('app.integer.center_icon_width_normal'))
            .height($r('app.integer.center_icon_width_normal'))
            .margin({ right: $r('app.integer.center_item_margin_left') })
          Span('设置')
            .fontColor($r('sys.color.black'))
        }

        Image($r('app.media.moreicon'))
          .width($r('app.integer.center_more_icon_width'))
          .height($r('app.integer.center_more_icon_height'))
      }
      .height($r('app.integer.center_item_height'))
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        if (this.isLogin === false) {
          this.vm.toRouteDetail('Login')
        } else {
          this.vm.toRouteDetail('SettingsPage')
        }
      })

      Divider()
        .width('100%').margin({ left: $r('app.integer.divider_margin') })
        .strokeWidth('1px').color($r('sys.color.ohos_id_color_list_separator'))
      Row() {
        Text() {
          ImageSpan($r('app.media.connect'))
            .width($r('app.integer.center_icon_width_normal'))
            .height($r('app.integer.center_icon_width_normal'))
            .margin({ right: $r('app.integer.center_item_margin_left') })
          Span('联系客服')
            .fontColor($r('sys.color.black'))
        }

        Image($r('app.media.moreicon'))
          .width($r('app.integer.center_more_icon_width'))
          .height($r('app.integer.center_more_icon_height'))
      }
      .width('100%')
      .height($r('app.integer.center_item_height'))
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        this.isShow = true
      })
      .bindSheet($$this.isShow, this.myBuilder(), {
        height: 270,
        blurStyle: BlurStyle.Thick,
        showClose: false,
        preferType: SheetType.CENTER,
      })

      Divider()
        .width('100%').margin({ left: $r('app.integer.divider_margin') })
        .strokeWidth('1px').color($r('sys.color.ohos_id_color_list_separator'))
      Row() {
        Text() {
          ImageSpan($r('app.media.ic_public_security'))
            .width($r('app.integer.center_icon_width_normal'))
            .height($r('app.integer.center_icon_width_normal'))
            .margin({ right: $r('app.integer.center_item_margin_left') })
          Span('隐私管理')
            .fontColor($r('sys.color.black'))
        }

        Image($r('app.media.moreicon'))
          .width($r('app.integer.center_more_icon_width'))
          .height($r('app.integer.center_more_icon_height'))
      }
      .height($r('app.integer.center_item_height'))
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.vm.toRouteDetail('PrivacyPage')
      })

      Divider()
        .width('100%').margin({ left: $r('app.integer.divider_margin') })
        .strokeWidth('1px').color($r('sys.color.ohos_id_color_list_separator'))
      Row() {
        Text() {
          ImageSpan($r('app.media.ic_public_info'))
            .width($r('app.integer.center_icon_width_normal'))
            .height($r('app.integer.center_icon_width_normal'))
            .margin({ right: $r('app.integer.center_item_margin_left') })
          Span('关于')
            .fontColor($r('sys.color.black'))
        }

        Image($r('app.media.moreicon'))
          .width($r('app.integer.center_more_icon_width'))
          .height($r('app.integer.center_more_icon_height'))
      }
      .height($r('app.integer.center_item_height'))
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.vm.toRouteDetail('AboutUs')
      })
    }
    .backgroundColor($r('app.color.background_color_white'))
    .width('100%')
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
    .padding(16)
  }

  @Builder
  myBuilder() {
    Column() {
      Text('联系客服')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 23, bottom: 14 })
        .width('100%')


      Column(){
        Text(this.phoneNumber.toString())
          .fontSize(18)
          .fontWeight(FontWeight.Medium)

        Button() {
          Row() {
            SymbolGlyph($r('sys.symbol.phone_badge_waveform_1'))
              .renderingStrategy(SymbolRenderingStrategy.SINGLE)
              .fontColor([Color.White])
              .margin({right:8})
            Text('一键拨号')
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_on_primary'))
          }
        }
        .height(40)
        .width('100%')
        .margin({ top: 22, bottom: 12 })
        .backgroundColor('#62B42E')
        .onClick(() => { // 跳转到电话页面
          let isSupport = call.hasVoiceCapability();
          if (isSupport) {
            // 如果设备支持呼叫能力，则继续跳转到拨号界面，并显示拨号的号码
            call.makeCall(this.phoneNumber.toString(), (err: BusinessError) => {
              if (!err) {
                console.log('make call success.');
              } else {
                console.log('make call fail, err is:' + JSON.stringify(err));
              }
            });

            // 订阅通话业务状态变化（可选）
            class SlotId {
              slotId: number = 0
            }

            class CallStateCallback {
              state: call.CallState = call.CallState.CALL_STATE_UNKNOWN;
              number: string = '';
            }

            let slotId: SlotId = { slotId: 0 }
            observer.on('callStateChange', slotId, (data: CallStateCallback) => {
              console.log('call state change, data is:' + JSON.stringify(data));
            });
          }
        })

        Button('取消')
          .fontColor($r('sys.color.font_tertiary'))
          .backgroundColor('')
          .backgroundColor('#0d000000')
          .onClick((event: ClickEvent) => {
            this.isShow = false;
        })
          .height(36)
          .width('100%')
      }
      .padding({left:24,right:24,top:24,bottom:19})
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius($r('sys.float.corner_radius_level8'))
    }
    .padding({left:16,right:16,bottom:24})
    .backgroundColor('#F1F3F5')
    .height(270)
  }

  aboutToAppear() {
    this.initDataSource()
  }
}
