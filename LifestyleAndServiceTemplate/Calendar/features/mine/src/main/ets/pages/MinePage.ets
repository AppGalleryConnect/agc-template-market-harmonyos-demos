import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import {
  UserState,
  SettingItem,
  DividerTmp,
  TextStyleModifier,
  ServiceTitle,
  ThemeModel,
  UserInfo,
  PAD_BOTTOM,
  BreakpointNameEnum,
  BreakpointModel,
} from 'common';
import { LoginInfo, LoginParams } from 'login_info';
import { CalendarEventMain, UserEventItem } from 'calendar_events';
import { getDataFromJSON } from 'base_apis';
import { RouterModule } from 'router_module';
import { aesDecName, aesEncName } from '../utils/Utils';
import { MemberStatusUtil } from 'membership';
import { common } from '@kit.AbilityKit';
import { emitter } from '@kit.BasicServicesKit';

const TAG = '[MinePage]'

@ComponentV2
export struct MinePage {
  settingItems: SettingItem[] = [];
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local egDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0')
  @Local userState: UserState = PersistenceV2.connect(UserState, () => new UserState())!;
  @Local modelShow: boolean = false

  // 是否纵向Tab
  @Computed
  get isTabVertical() {
    return [
      BreakpointNameEnum.LG,
      BreakpointNameEnum.XL,
    ].includes(this.breakPointModel.currentBreakpoint);
  }

  queryMemberStatus() {
    MemberStatusUtil.queryPurchase(this.getUIContext().getHostContext() as common.UIAbilityContext).then((res) => {
      let autoRenewPurchasedList = res.renewList;
      let nonAutoRenewPurchasedList = res.nonRenewList;

      if (autoRenewPurchasedList?.length || nonAutoRenewPurchasedList?.length) {
        this.userState.userInfo.vipInfo.isVip = true
      } else {
        this.userState.userInfo.vipInfo.isVip = false
      }
    }).catch((err: BusinessError) => {
      this.userState.userInfo.vipInfo.isVip = false
      UtilLog.error(0xFF00, 'MemberShip',
        `Failed to query purchase record. Code is ${err.code}, message is ${err.message}`);
    });
  }

  initDataSource() {
    this.settingItems =
      getDataFromJSON<SettingItem>(this.getUIContext().getHostContext()!, 'MinePage-SettingItems.json');
    PersistenceV2.save(UserState);
  }

  /*
   * mock使用aes加密算法保证用户信息安全
   * */

  async mockUserLogin() {
    this.userState.isLogin = true;
    let mockUserInfo: UserInfo = new UserInfo({
      'idToken': '',
      'userName': await aesEncName('华为用户'),
      'avatar': '',
      'phoneNumber': '123xxxxx789',
    })
    this.queryMemberStatus()
    mockUserInfo.userName = await aesDecName(mockUserInfo.userName as Uint8Array)
    this.userState.userInfo = mockUserInfo
    RouterModule.pop();
  }

  build() {
    Column() {
      ServiceTitle({
        title: '我的',
        titleColor: this.theme.themeState.titleColor,
      })
      List({ space: 12 }) {
        ListItem() {
          Column() {
            LoginInfo({
              userInfo: this.userState.userInfo,
              isLogin: this.userState.isLogin,
              selectColor: this.theme.themeState.current,
              titleColor: this.theme.themeState.titleColor,
              routerModule: RouterModule.getStack(),
              onLogin: (loginParams: LoginParams) => {
                this.mockUserLogin()
                UtilLog.info(TAG, 'onLogin', JSON.stringify(loginParams))
              },
              onHuaweiLogin: (loginParams: LoginParams) => {
                this.mockUserLogin()
                UtilLog.info(TAG, 'onHuaweiLogin', JSON.stringify(loginParams))
              },
            })
            Divider()
            Row() {
              Text(this.userState.userInfo.vipInfo.isVip ? '请查看您的会员权益' : '开通VIP后享受更多服务')
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Regular)
                .fontColor('#000000')
              Button(this.userState.userInfo.vipInfo.isVip ? '会员中心' : '开通会员')
                .backgroundColor('#F8E6CF')
                .height(28)
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .onClick(() => {
                  RouterModule.getStack().pushPathByName('VipOpenCenter', null)
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding(12)
          }
          .width('100%')
          .margin({ top: 18 })
          .backgroundColor($r('sys.color.background_primary'))
          .borderRadius(16)
        }

        ListItem() {
          CalendarEventMain({
            pathStack: RouterModule.getStack(),
            selectColor: this.theme.themeState.current,
            titleColor: this.theme.themeState.titleColor,
            currentColor:this.theme.themeState.calendarColor,
            onCalendarEventChange: (userEventInfo: UserEventItem) => {
              UtilLog.info(TAG, 'change userEventInfo', JSON.stringify(userEventInfo))
            },
            onCalendarEventDelete: (userEventInfo: UserEventItem) => {
              UtilLog.info(TAG, 'delete userEventInfo', JSON.stringify(userEventInfo))
            },
          })
        }

        ListItem() {
          this.buildSettingsView()
        }
      }
      .padding({
        bottom: 16,
        left: 16,
        right: 16,
      })
      .layoutWeight(1)
      .scrollBar(BarState.Off)

    }
    .backgroundColor($r('sys.color.background_secondary'))
    .border({ width: { left: this.isTabVertical ? 1 : 0 }, color: '#ccc' })
    .padding({ top: Number(AppStorage.get('topRectHeight')), bottom: PAD_BOTTOM })
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
                RouterModule.pushPathByName({ url: 'SettingLevel' })
                break;
            }
          })
        }
      }, (settingItem: SettingItem) => settingItem.name)
    }
    .divider(this.egDivider)
    .borderRadius(16)
    .backgroundColor($r('sys.color.background_primary'))
  }

  aboutToAppear() {
    this.initDataSource()
    this.queryMemberStatus()
    emitter.on('member_subscribe', () => {
      this.queryMemberStatus()
    })
  }
}
