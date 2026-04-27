import { AggregatedLogin } from '../components/AggregatedLogin';
import { LoginInfoOptions } from '../utils/LoginSheetUtils';

@Entry
@ComponentV2
struct AggregatedLoginPage {
  @Local routerModule: NavPathStack = new NavPathStack();
  params: LoginInfoOptions = new LoginInfoOptions();

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          // 登录使用
          AggregatedLogin({
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
            loginController: this.params.loginController,
          })
            .layoutWeight(1);
        }
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

@Builder
export function AggregatedLoginPageBuilder() {
  AggregatedLoginPage()
}