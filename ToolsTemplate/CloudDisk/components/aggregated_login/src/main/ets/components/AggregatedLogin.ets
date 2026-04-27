import * as wxopensdk from '@tencent/wechat_open_sdk';
import { BusinessError } from '@kit.BasicServicesKit';
import { loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { Constants, LoginChannelType } from '../common/Constant';
import { AggregatedLoginVM } from '../viewmodel/AggregatedLoginVM';
import { Channel, PrivacyContent } from '../model/Index';
import { ApiController, LoginController, LoginEventDispatcher } from '../utils/Utils';
import { AgreePrivacyBox } from './AgreePrivacyBox';
import { LoginSheetUtils } from '../utils/LoginSheetUtils';


@Builder
export function AggregatedLoginBuilder() {
  AggregatedLogin()
}
/**
 * @usage: 通用登录组件的核心组件，提供华为账号一键登录、微信登录、手机号登录等多种登录方式。
 * 包含登录状态管理、隐私协议确认、登录失败处理等功能。支持全屏和半模态两种展示方式，可配置登录类型、主题色、图标等参数。
 * @layout: 垂直布局，从上到下依次为：应用图标、华为账号绑定手机号显示、华为账号一键登录按钮、其他登录方式按钮、隐私协议确认框。
 * 支持滚动显示，根据isSheet参数调整布局高度。
 * @constraints: 不允许修改华为账号登录逻辑、登录状态管理逻辑、隐私协议处理逻辑。登录类型配置必须符合LoginType枚举值。
 * 主题色必须为有效的颜色值。
 * @isGen: true
 * @fileType: component
 * @zhName: 通用登录组件
 * @subPage: OtherLoginPage
 * @component: AgreePrivacyBox,LoginWithHuaweiIDButton
 */
@ComponentV2
export struct AggregatedLogin {
  @Local vm: AggregatedLoginVM = AggregatedLoginVM.getInstance(false);
  @Param wxApi: wxopensdk.WXApi = wxopensdk.WXAPIFactory.createWXAPI('xxx')
  @Param routerModule: NavPathStack = new NavPathStack()
  @Param icon: ResourceStr = '';
  @Param themeColor: ResourceColor = '#0A59F7';
  @Param isSheet: boolean = false;
  @Param privacyContent: PrivacyContent[] = []
  @Param loginTypes: Channel[] = [];
  @Param autoSheet: boolean = false;
  @Param isPersistence: boolean = false;
  @Param apiController: ApiController = new ApiController(
    () => new Promise(() => {
    }), () => new Promise(() => {
  }), () => new Promise(() => {
  })
  )
  @Param loginController: LoginController = new LoginController();
  @Event handleLoginFail: (loginChannelType: LoginChannelType, error: BusinessError | wxopensdk.BaseResp) => void =
    () => {
    }
  @Event obtainVerifyCode: () => Promise<void> = () => new Promise(() => {
  });

  aboutToAppear(): void {
    this.vm.innerRouterModule = this.routerModule
    this.vm.getQuickLoginAnonymousPhone();
    LoginEventDispatcher.loginFailCallback =
      (loginChannelType: LoginChannelType, error: BusinessError | wxopensdk.BaseResp) => {
        this.handleLoginFail(loginChannelType, error)
      }
    this.vm.setValue(this.wxApi, this.isSheet, this.autoSheet,
      this.loginTypes, this.isPersistence, this.apiController, this.obtainVerifyCode)
    this.loginController.clearLoginInfo = () => {
      this.vm.resetInstance()
    }
  }

  aboutToDisappear(): void {
    this.vm.resetInstance()
  }

  @Builder
  coreInfo() {
    Column() {
      Scroll() {
        Column() {
          if (this.isSheet) {
            Column().height(Constants.SHEET_TITLE_H)
          } else {
            Column()
              .layoutWeight(1)
              .constraintSize({
                minHeight: Constants.MIN_HEIGHT_8
              })
          }

          Image(this.icon)
            .width(Constants.ICON_WIDTH)
            .height(Constants.ICON_HEIGHT)

          Column() {
            Text(this.vm.anonymousPhone)
              .fontSize($r('sys.float.Title_L'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Bold)
              .height(Constants.BTN_HEIGHT)
              .textAlign(TextAlign.Center)
              .maxLines(Constants.FONT_LINES);

            Text('华为账号绑定号码')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .maxLines(Constants.FONT_LINES)
              .margin({
                top: Constants.PADDING_S,
              });
          }
          .margin({
            top: Constants.CONTENT_MARGIN_TOP,
          });

          Column() {
            LoginWithHuaweiIDButton({
              params: {
                style: loginComponentManager.Style.BUTTON_CUSTOM,
                extraStyle: {
                  buttonStyle: new loginComponentManager.ButtonStyle().loadingStyle({
                    show: true,
                  }),
                },
                loginType: loginComponentManager.LoginType.QUICK_LOGIN,
                supportDarkMode: true,
                customButtonParams: {
                  fontColor: loginComponentManager.FontColor.WHITE,
                  backgroundColor: this.themeColor,
                },
              },
              controller: this.vm.controller,
            });
          }
          .height(Constants.BTN_HEIGHT)
          .width(Constants.FULL_PERCENT)
          .constraintSize({ maxWidth: Constants.MAX_WIDTH })
          .margin({
            top: Constants.SHEET_TITLE_H,
          });

          Button($r('app.string.login_in_other'))
            .width(Constants.FULL_PERCENT)
            .height(Constants.BTN_HEIGHT)
            .constraintSize({ maxWidth: Constants.MAX_WIDTH })
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .margin({
              top: Constants.PADDING_M,
            })
            .onClick(() => {
              this.vm.resetParam()
              this.vm.phoneLogin(this.routerModule, {
                privacyContent: this.privacyContent,
                themeColor: this.themeColor,
                isSheet: this.isSheet,
                icon: this.icon,
                loginTypes: this.loginTypes,
                isPersistence: this.isPersistence,
              });
            })

          Column().layoutWeight(3)
            .constraintSize({ minHeight: Constants.MIN_HEIGHT_12 })
        }
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)

      AgreePrivacyBox({
        themeColor: this.themeColor,
        privacyContent: this.privacyContent,
        routerModule: this.routerModule,
        isSheet: this.isSheet,
        sheetType: LoginSheetUtils.sheetParams.sheetType,
      })
        .padding({
          top: Constants.PADDING_M,
          bottom: Constants.PADDING_M,
        })
        .constraintSize({ maxWidth: Constants.MAX_WIDTH })
        .height(Constants.SHEET_TITLE_H)
        .width(Constants.FULL_PERCENT)
    }
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({
      left: Constants.PADDING_L, right: Constants.PADDING_L,
      bottom: this.isSheet ? Constants.WINDOW_BOTTOM_PADDING : Constants.ZERO
    })
    .layoutWeight(1)
  }

  build() {
    Column() {
      if (!this.isSheet) {
        Row() {
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.chevron_backward'))
              .fontColor([$r('sys.color.icon_primary')])
              .fontSize(Constants.BACK_WIDTH)
          }
          .width(Constants.BACK_BACKGROUND_WIDTH)
          .height(Constants.BACK_BACKGROUND_HEIGHT)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            this.routerModule.pop();
          })
        }
        .padding({ left: Constants.PADDING_L, right: Constants.PADDING_L })
        .width(Constants.FULL_PERCENT)
        .height(Constants.SHEET_TITLE_H)
      }

      this.coreInfo()
    }
    .height(Constants.FULL_PERCENT)
    .width(Constants.FULL_PERCENT)
  }
}
