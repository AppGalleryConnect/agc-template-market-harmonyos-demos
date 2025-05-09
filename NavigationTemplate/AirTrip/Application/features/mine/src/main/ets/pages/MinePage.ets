import { Constants, callTel, UserInfoStorage, AuthenticationUtil, UserInfo, AppRouter } from 'common';
import { NavItemView } from '../components/NavItemView';
import { UserInfoCard } from '../components/UserInfoCard';
import { MinePageModel, NavItem } from '../model/MinePageModel';
import { PersistenceV2 } from '@kit.ArkUI';
import { CardView } from '../components/CardView';
import { BaseTitle, GlobalDialog } from 'components';

@Builder
export function minePageBuilder() {
  MinePage()
}

@ComponentV2
export struct MinePage {
  @Local userInfoStorage: UserInfoStorage = PersistenceV2.connect(UserInfoStorage, 'UserInfoStorage', () => new UserInfoStorage())!
  @Local isShowMode: boolean = false
  orderList: NavItem[] = MinePageModel.getOrderList()
  functionalList: NavItem[] = MinePageModel.getFunctionalList()

  aboutToAppear(): void {
    PersistenceV2.save(UserInfoStorage)
  }

  linkAccount(cb: () => void) {
    GlobalDialog.showTextDialog({
      title: '关联账号',
      content: '请先关联账号',
      primaryButName: '确定',
      secondaryButName: '取消',
      primaryButAction: async () => {
        // 关闭账号关联弹框
        await GlobalDialog.close()
        // loading弹框
        await GlobalDialog.showLoadingDialog()
        AuthenticationUtil.silentLogin(async (isSuccess: boolean, userInfo: UserInfo) => {
          await GlobalDialog.close()
          // 账号关联登录成功
          if (isSuccess) {
            this.userInfoStorage.isLogin = true;
            this.userInfoStorage.userInfo = userInfo
            setTimeout(() => {
              cb()
            })
          }
        })
      },
      secondaryButAction: () => {
        GlobalDialog.close()
      },
    })
  }

  handleClickEvent(type: ResourceStr) {
    switch (type) {
      case 'passenger':
        if (this.userInfoStorage.isLogin) {
          AppRouter.push({
            url: 'PassengerListPage',
          })
        } else {
          this.linkAccount(() => {
            AppRouter.push({
              url: 'PassengerListPage',
            })
          })
        }
        break
      case 'custom':
        this.isShowMode = !this.isShowMode
        break
      case 'setting':
        AppRouter.push({
          url: 'SettingPage',
        })
        break
      default:
        break
    }
  }

  build() {
    Column() {
      BaseTitle({
        customTitle: () => {
          this.MineTitleBuilder()
        }
      })
      Scroll() {
        Column({ space: 20 }) {
          // 用户信息
          UserInfoCard()
          // 我的订单
          CardView({
            title: '我的订单',
            customContent: () => {
              this.OrderView()
            }
          })
          // 常用服务
          CardView({
            title: '常用服务',
            customContent: () => {
              this.ServiceView()
            }
          })
        }
        .width(Constants.FULL_PERCENT_WIDTH)
        .padding({ left: 16, right: 16 })
      }
      .align(Alignment.TopStart)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .linearGradient(
      {
        angle: 180,
        colors: [['rgba(194,207,255,1)', 0.1], ['rgba(241,243,245,1)', 0.4]]
      })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  MineTitleBuilder() {
    Text('我的')
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Bold)
  }

  @Builder
  OrderView() {
    Row() {
      ForEach(this.orderList, (item: NavItem, index: number) => {
        Column({ space: 4 }) {
          Image(item.icon).width(32).height(32)
          Text(item.label).fontSize(12).fontWeight(FontWeight.Regular)
        }
        .onClick(() => {
          if (this.userInfoStorage.isLogin) {
            AppRouter.push({
              url: 'OrderCenterPage',
              param: item.type
            })
          } else {
            this.linkAccount(() => {
              AppRouter.push({
                url: 'OrderCenterPage',
                param: item.type
              })
            })
          }
        })
      })
    }
    .width('100%')
    .padding({ top: 20, bottom: 20 })
    .backgroundColor($r('sys.color.white'))
    .borderRadius(16)
    .justifyContent(FlexAlign.SpaceAround)
  }

  @Builder
  ServiceView() {
    Column({space: 8}) {
      ForEach(this.functionalList, (item: NavItem, index: number) => {
        NavItemView({
          data: item,
          clickItem: () => {
            this.handleClickEvent(item.type)
          }
        })
      })
    }
    .width('100%')
    .bindSheet($$this.isShowMode, this.SheetBuilder(), {
      height: 300,
      blurStyle: BlurStyle.COMPONENT_THICK,
      preferType: SheetType.BOTTOM,
      title: {
        title: $r('app.string.contact_service')
      },
      onWillDismiss: ((sheetAction: DismissSheetAction) => {
        if (sheetAction.reason === DismissReason.PRESS_BACK) {
        }
        if (sheetAction.reason === DismissReason.CLOSE_BUTTON) {
          sheetAction.dismiss()
        }
      }),
    })
  }

  @Builder
  SheetBuilder() {
    Column() {
      Text('000-00000000')
        .fontSize($r('sys.float.titlebar_title_primary_size'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)

      Row({ space: 10 }) {
        Image($r('app.media.ic_call')).width($r('app.float.call_icon_size')).height($r('app.float.call_icon_size'))
        Text($r('app.string.call_number'))
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Medium)
      }
      .borderRadius($r('app.float.button_border_radius_thirty'))
      .width(Constants.FULL_PERCENT_WIDTH)
      .height($r('app.float.button_height_Forty'))
      .margin({
        top: $r('app.float.common_margin_twelve'),
      })
      .backgroundColor($r('sys.color.background_emphasize'))
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        // 拉起拨号界面并指定号码
        callTel('000-00000000')
      })

      Row() {
        Text($r('app.string.cancel'))
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Medium)
      }
      .borderRadius($r('app.float.button_border_radius_thirty'))
      .width(Constants.FULL_PERCENT_WIDTH)
      .height($r('app.float.button_height_Forty'))
      .margin({
        top: $r('app.float.common_margin_twelve'),
      })
      .onClick(() => {
        this.isShowMode = !this.isShowMode
      })
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
    }
    .padding({
      left: $r('app.float.common_padding_twentyFour'), right: $r('app.float.common_padding_twentyFour'),
    })
    .backgroundColor($r('sys.color.background_primary'))
    .height('calc(100% - 30vp)')
    .width('calc(100% - 32vp)')
    .borderRadius(16)
    .justifyContent(FlexAlign.Center)
  }
}
