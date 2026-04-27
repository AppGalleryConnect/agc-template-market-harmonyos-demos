import { AggregatedLogin } from '../components/AggregatedLogin';
import { LoginInfoOptions } from '../utils/LoginSheetUtils';

export const AGGREGATED_LOGIN_PAGE_NAME = 'AggregatedLoginPage'

/**
 * @usage: 通用登录页面，作为登录功能的主入口页面。包含完整的登录流程，支持华为账号一键登录、微信登录、手机号登录等多种方式。
 * 可配置为全屏页面或半模态展示，支持路由参数传递和登录状态回调。
 * @layout: 导航页面布局，包含NavDestination容器，内部为滚动的垂直布局，主要内容为AggregatedLogin组件。支持页面返回处理和路由栈管理。
 * @constraints: 不允许修改页面路由逻辑、登录组件参数传递逻辑、页面生命周期处理逻辑。路由参数必须符合LoginInfoOptions接口规范。
 * @isGen: true
 * @fileType: page
 * @zhName: 通用登录页面
 * @subPage: OtherLoginPage,ProtocolWebView
 * @component: AggregatedLogin
 */
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