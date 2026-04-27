import { LengthMetrics } from '@kit.ArkUI';
import { ApiController, AtomicserviceLogin, UserInfo } from 'atomicservice_login';
import {
  iData,
  routerStack,
  RouterMap,
  BreakpointSystem,
  BreakpointTypeEnum,
  GlobalStateMgr,
  WindowUtil,
} from 'lib_foundation';
import { ContainerColumn, NavTitleBar } from 'lib_widget';
import { MemberStatusUtil } from 'membership';
import { BindPhoneUtil } from 'module_global_feature';
import { MainMenuItem, SubMenuItem } from '../commons/Types';
import { ProfileUtil } from '../utils/ProfileUtil';
import { common } from '@kit.AbilityKit';

@Builder
export function buildProfilePage() {
  ProfilePage();
}

@ComponentV2
export struct ProfilePage {
  @Local controller: ApiController = new ApiController()
  @Local userInfo: UserInfo = new UserInfo()
  @Local globalState: GlobalStateMgr = iData.global

  aboutToAppear(): void {
    this.refresh();
  }

  @Monitor('globalState.isLogin')
  refresh() {
    if (iData.global.isLogin) {
      const globalUser = iData.global.userInfo;
      this.userInfo.avatar = globalUser.avatar;
      this.userInfo.phoneNumber = globalUser.anonymousPhone;
      this.userInfo.userName = globalUser.nickname;
    }
  }

  build() {
    Column() {
      NavTitleBar({
        title: '我的',
      })

      Scroll() {
        Column({ space: 12 }) {
          if (BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.LG) {
            Flex({ space: { main: LengthMetrics.vp(16) } }) {
              Column() {
                this.buildUserInfoArea()
              }
              .tabletContainerStyle(iData.global.isLogin)

              Column() {
                buildCheckInArea()
                buildMainMenuArea()
              }
              .height(iData.global.isLogin ? 128 : 78)
              .justifyContent(FlexAlign.SpaceBetween)
            }
          } else {
            this.buildUserInfoArea()
            buildCheckInArea()
            buildMainMenuArea()
          }

          buildOrderInfoArea()
          buildSubMenuArea()
        }
        .margin({ bottom: 80 })
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .padding({ left: $r('app.float.space_l'), right: $r('app.float.space_l') })
    }
    .height('100%')
    .width('100%')
    .linearGradient({
      colors: [['#33e64566', 0], ['#00E64566', 0.4]],
    })
    .backgroundColor($r('app.color.background_color_grey'))
    .alignItems(HorizontalAlign.Start)
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP])
    .transition(TransitionEffect.OPACITY.animation({ duration: 600 }))
  }

  @Builder
  buildUserInfoArea() {
    ContainerColumn({ bottomGap: false }) {
      AtomicserviceLogin({
        userInfo: this.userInfo,
        isLink: iData.global.isLogin,
        controller: this.controller,
        bindPhone: async (code: string | undefined) => {
          await BindPhoneUtil.handleBind({
            code,
            needBack: false,
            callback: () => {
              MemberStatusUtil.queryPurchase(WindowUtil.globalContext as common.UIAbilityContext).then((list) => {
                if (list.nonRenewList.length) {
                  iData.global.userInfo.isMember = true;
                }
              });
            },
          })
          this.userInfo.avatar = iData.global.userInfo.avatar
          this.userInfo.userName = iData.global.userInfo.nickname
          this.userInfo.phoneNumber = iData.global.userInfo.anonymousPhone
        },
        onGetPhoneError: (err) => {
          BindPhoneUtil.handleBindFailed({
            err,
            needBack: false,
            callback: () => {
              MemberStatusUtil.queryPurchase(WindowUtil.globalContext as common.UIAbilityContext).then((list) => {
                if (list.nonRenewList.length) {
                  iData.global.userInfo.isMember = true;
                }
              });
            },
          })
        },
        unBindPhone: async () => {
          BindPhoneUtil.handleUnbind()
        },
        onClickAvatar: () => {
          routerStack.push({ name: RouterMap.USER_PROFILE_EDIT })
        },
      })

      if (iData.global.isLogin) {
        Divider().margin({ top: $r('app.float.space_m'), bottom: $r('app.float.space_m') })
        Row() {
          Text('多项会员福利等你来领').fontSize(14).fontColor($r('app.color.font_color_level1'))
          Button('会员中心')
            .controlSize(ControlSize.SMALL)
            .backgroundColor($r('app.color.theme_color'))
            .onClick(() => {
              routerStack.pushPath({ name: RouterMap.USER_MEMBER_SUBSCRIPTION })
            })
        }
        .width($r('app.string.size_percent_full'))
        .justifyContent(FlexAlign.SpaceBetween)
      }
    }
  }
}


@Builder
function buildCheckInArea() {
  if (iData.global.isLogin) {
    ContainerColumn({ bottomGap: false }) {
      Row() {
        Image($r('app.media.ic_checkmark_calendar_fill'))
          .margin({ right: $r('app.float.space_xs') })
          .width(16)
          .height(16)
          .fillColor($r('app.color.font_color_level2'))
        Text('签到可领取积分兑换好物')
          .fontSize($r('app.float.font_size_14'))
          .fontColor($r('app.color.font_color_level1'))
          .layoutWeight(1)
        Image($r('app.media.ic_arrow_right')).commonIconStyle()
      }
      .width($r('app.string.size_percent_full'))
      .onClick(() => {
        routerStack.pushPath({ name: RouterMap.POINTS_MALL })
      })
    }
  }
}

@Builder
function buildMainMenuArea() {
  Row() {
    ForEach(ProfileUtil.MAIN_MENU_LIST, (item: MainMenuItem) => {
      Column() {
        Image(item.icon)
          .width(40)
          .height(40)
        Text(item.label).commonLabelStyle()
      }
      .onClick(() => {
        ProfileUtil.handleMainMenuClick(item.type)
      })
    }, (item: MainMenuItem) => item.label)
  }
  .containerStyle()
  .justifyContent(BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.SM ?
    FlexAlign.SpaceBetween :
    FlexAlign.SpaceAround)
}

@Builder
function buildOrderInfoArea() {
  Column() {
    Row() {
      Text('我的订单')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.font_color_level1'));
      Blank();
      Text('全部').commonLabelStyle().margin({ right: 4 }).fontColor($r('app.color.font_color_level2'))
      Image($r('app.media.ic_arrow_right')).commonIconStyle();
    }
    .onClick(() => {
      if (!iData.global.isLogin) {
        ProfileUtil.login()
        return;
      }
      routerStack.pushPathByName(RouterMap.ORDER_LIST, 0);
    })
    .width('100%')
    .margin({ bottom: 16 });

    Row() {
      buildOrderTab($r('app.media.ic_order_pending_payment'), '待付款', 1);
      buildOrderTab($r('app.media.ic_order_pending_shipment'), '待发货', 2);
      buildOrderTab($r('app.media.ic_order_pending_receipt'), '待收货', 3);
      buildOrderTab($r('app.media.ic_order_pending_review'), '待评价', 4);
      buildOrderTab($r('app.media.ic_order_refund_after_sale'), '退款/售后', 5);
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.SM ?
      FlexAlign.SpaceBetween :
      FlexAlign.SpaceAround);
  }
  .containerStyle();
}

@Builder
function buildSubMenuArea() {
  List({ space: 24 }) {
    ForEach(ProfileUtil.SUB_MENU_LIST, (item: SubMenuItem) => {
      ListItem() {
        Row() {
          SymbolGlyph(item.icon)
            .fontSize(24)
            .width(24)
            .height(24)
            .fontColor([$r('app.color.font_color_level1')])
            .margin({ right: 8 });

          Text(item.label).formLabelStyle();
          Blank();
          Image($r('app.media.ic_arrow_right')).commonIconStyle();
        }
        .width('100%')
        .onClick(() => {
          ProfileUtil.handleSubMenuClick(item.type)
        });
      }
    }, (item: SubMenuItem) => item.label)
  }
  .containerStyle()
  .divider({
    strokeWidth: 1,
    startMargin: 32,
  })
  .lanes(BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.LG ? 2 : 1, 16)
  .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
}

@Builder
function buildOrderTab(icon: ResourceStr, label: string, type: number) {
  Column() {
    Image(icon).commonIconStyle()
      .width(24)
      .height(24)
      .margin({ bottom: 4 });
    Text(label)
      .commonLabelStyle()
  }
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Start)
  .onClick(() => {
    if (!iData.global.isLogin) {
      ProfileUtil.login()
    } else {
      routerStack.pushPathByName(RouterMap.ORDER_LIST, type);
    }
  });
}

@Styles
function containerStyle() {
  .width('100%')
  .backgroundColor($r('app.color.background_color_primary'))
  .borderRadius(16)
  .padding(12);
}

@Extend(Text)
function commonLabelStyle() {
  .fontSize(12)
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .fontColor($r('app.color.font_color_level1'));
}

@Extend(Text)
function formLabelStyle() {
  .fontWeight(FontWeight.Medium)
  .fontSize(14)
  .fontColor($r('app.color.font_color_level1'))
}

@Extend(Image)
function commonIconStyle() {
  .draggable(false)
  .height(16)
  .width(16)
  .fillColor($r('app.color.font_color_level2'));
}

@Extend(Column)
function tabletContainerStyle(isLogin: boolean) {
  .backgroundColor($r('app.color.background_color_primary'))
  .borderRadius(16)
  .height(isLogin ? 128 : 78)
  .justifyContent(FlexAlign.Center)
}