import { NavHeaderBar } from 'lib_widget';
import { AggregatedLogin } from '../components/AggregatedLogin';
import { LoginInfoOptions } from '../utils/LoginSheetUtils';
import { LoginController } from '../utils/Utils';

@Entry
@ComponentV2
struct AggregatedLoginPage {
  @Local routerModule: NavPathStack = new NavPathStack();
  params: LoginInfoOptions = new LoginInfoOptions();

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          if (!this.params.isSheet) {
            NavHeaderBar()
          }
          AggregatedLogin({
            wxApi: this.params.wxApi,
            routerModule: this.routerModule,
            icon: this.params.icon,
            themeColor: this.params.themeColor,
            isSheet: this.params.isSheet,
            autoSheet: this.params.autoSheet,
            isPersistence: this.params.isPersistence,
            loginTypes: this.params.loginTypes,
            privacyContent: this.params.privacyContent,
            apiController: this.params.apiController,
            handleLoginFail: this.params.handleLoginFail,
            obtainVerifyCode: this.params.obtainVerifyCode,
            loginController: this.params.loginController ?? new LoginController(),
          })
            .layoutWeight(1);
        }
        .padding({ bottom: 28 })
        .layoutWeight(1)
      }
    }
    .hideTitleBar(true)
    .onReady((context) => {
      // 获取参数
      this.routerModule = context.pathStack;
      this.params = context.pathInfo.param as LoginInfoOptions
    })
  }
}

export const ERROR_MSG_MAP: Record<number, string> = {
  1001502001: '用户未登录华为账号，请前往设置-登录华为账号。',
  1001500001: '应用指纹证书校验失败，请检查client_id、应用指纹证书配置。',
  1001502014: '应用未申请scopes或permissions权限。',
  // ...
};

@Builder
export function AggregatedLoginPageBuilder() {
  AggregatedLoginPage()
}