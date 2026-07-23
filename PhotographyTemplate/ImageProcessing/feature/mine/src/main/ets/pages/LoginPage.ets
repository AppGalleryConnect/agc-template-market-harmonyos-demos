
import { AppStorageV2 } from '@kit.ArkUI';
import { RouterModule, WindowSize } from 'commonlib';
import {
  AggregatedLogin,
  Channel,
  ApiController,
  LoginType,
} from 'aggregated_login';
import { ProtocolData, LoginUtil } from '../viewmodels/LoginPageVM';


@Builder
export function LoginPageBuilder() {
  LoginPage();
}

@ComponentV2
export struct LoginPage {
  @Local windowSize: WindowSize = AppStorageV2.connect(WindowSize, () => new WindowSize())!;

  aboutToAppear(): void {
    LoginUtil.loginSuccessCallback = () => {
      const param = { 'isLogin': true } as Record<string, boolean>;
      RouterModule.pop(param);
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 登录使用
        AggregatedLogin({
          routerModule: RouterModule.stack,
          icon: $r('app.media.app_icon'),
          themeColor: $r('sys.color.brand'),
          isSheet: false,
          autoSheet: false,
          isPersistence: false,
          loginTypes: [new Channel(LoginType.WECHAT, '微信', {
            appId: 'xxx',
            scope: 'snsapi_userinfo,snsapi_friend,snsapi_message,snsapi_contact',
            transaction: 'test123',
            state: 'none',
          }, $r('app.media.wx_count'))],
          privacyContent: [{
            privacyLabel: '《用户协议》',
            privacyUrl: ProtocolData.termOfServiceProtocol,
            privacyTag: '用户协议',
          }, {
            privacyLabel: '《xxxx隐私政策》',
            privacyUrl: ProtocolData.privacyProtocol,
            privacyTag: '隐私政策',
          }, {
            privacyLabel: '《华为账号用户认证协议》',
            privacyUrl: ProtocolData.huaweiUserProtocol,
            privacyTag: '华为账号用户认证协议',
          }],
          apiController: new ApiController(
            LoginUtil.huaweiLogin,
            LoginUtil.wxLogin,
            LoginUtil.verifyCodeLogin
          ),
          handleLoginFail: LoginUtil.handleLoginFail,
          obtainVerifyCode: LoginUtil.obtainVerifyCode,
          loginController: LoginUtil.controller,
        });
      }
      .padding({
        top: this.windowSize.statusHeight,
        bottom: this.windowSize.bottomHeight
      })
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

  }
}