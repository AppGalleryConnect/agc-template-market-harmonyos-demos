import {
  AggregatedLogin,
  Channel,
  LoginController,
  LoginChannelType,
  ApiController,
  LoginParams,
  LoginType,
  LoginFailError
} from 'aggregated_login';
import { BusinessError } from '@kit.BasicServicesKit';
import { AccountUtil, buildTitleBar, Logger, RouterMap, RouterModule, UserInfo } from 'commonlib';
import { PromptAction } from '@kit.ArkUI';
import { ERROR_MSG_MAP, ProtocolData } from '../model/Index';

@Builder
export function QuickLoginPageBuilder() {
  QuickLoginPage();
}

@ComponentV2
export struct QuickLoginPage {
  promptAction: PromptAction = this.getUIContext().getPromptAction();
  controller: LoginController = new LoginController()
  @Local nextRouter: string = '';

  aboutToAppear(): void {
    this.getRouterParams()
  }

  getRouterParams() {
    const params: Record<string, string> | undefined = RouterModule.getNavParam(RouterMap.QUICK_LOGIN_PAGE)
    if (params?.url) {
      this.nextRouter = params.url
    }
  }

  huaweiLogin = async (loginParams: LoginParams): Promise<void> => {
    this.getUIContext().getPromptAction().showToast({ message: '华为一键登录成功' })
    this.loginSuccess(loginParams.unionID ?? '')
  }
  wxLogin = async (): Promise<void> => {
    this.getUIContext().getPromptAction().showToast({ message: '微信登录成功' })
  }
  verifyCodeLogin = async (loginParams: LoginParams): Promise<void> => {
    try {
      const data = await this.promptAction.showDialog({
        title: '温馨提示',
        message: '模拟验证码登录成功？',
        buttons: [
          { text: '取消', color: $r('sys.color.font_secondary') },
          { text: '确认', color: $r('sys.color.font_secondary') },
        ]
      })
      if (data.index === 1) {
        this.getUIContext().getPromptAction().showToast({ message: '验证码登录成功' })
        this.controller.clearLoginInfo();
        RouterModule.clear();
      }
    } catch (err) {
      Logger.error('弹窗操作异常:', (err as BusinessError).message);
    }
  }
  obtainVerifyCode = async () => {
    this.getUIContext().getPromptAction().showToast({ message: '获取验证码为模拟场景，真实获取验证码以业务实现为准' })
  }
  handleLoginFail = (loginChannelType: LoginChannelType, error: LoginFailError) => {
    if (loginChannelType === LoginChannelType.HUAWEI) {
      const businessError = error as BusinessError
      const errorMsg = ERROR_MSG_MAP[businessError.code] ?? '未知错误。';
      try {
        this.promptAction.showDialog({
          title: '温馨提示',
          message: errorMsg + '是否先模拟登录成功？',
          buttons: [
            { text: '取消', color: $r('sys.color.brand') },
            { text: '确认', color: $r('sys.color.brand') },
          ]
        }, (err: BusinessError, data) => { // 按钮动作回调
          // 根据按钮索引处理动作
          if (data.index === 1) {
            this.getUIContext().getPromptAction().showToast({ message: '华为一键登录成功' })
            this.loginSuccess('')
            this.controller.clearLoginInfo();
          }
        })
      } catch (err) {
        Logger.error('showDialog failed:', err.message);
      }
      return;
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        AggregatedLogin({
          icon: $r('app.media.startIcon'),
          privacyContent: [{
            privacyLabel: '《用户协议》',
            privacyUrl: ProtocolData.termOfServiceProtocol,
            privacyTag: '用户协议'
          }, {
            privacyLabel: '《xxxx隐私政策》',
            privacyUrl: ProtocolData.privacyProtocol,
            privacyTag: '隐私政策'
          }, {
            privacyLabel: '《华为账号用户认证协议》',
            privacyUrl: ProtocolData.huaweiUserProtocol,
            privacyTag: '华为账号用户认证协议'
          }],
          themeColor: '#FF0000',
          loginTypes: [new Channel(LoginType.WECHAT, '微信登录', {
            appId: 'wxd5a474c635b8fd17',
            scope: 'snsapi_userinfo,snsapi_friend,snsapi_message,snsapi_contact',
            transaction: 'test123',
            state: 'none',
          }, $r('app.media.wechat'))],
          routerModule: RouterModule.getStack(),
          apiController: new ApiController(this.huaweiLogin, this.wxLogin, this.verifyCodeLogin),
          handleLoginFail: this.handleLoginFail,
          obtainVerifyCode: this.obtainVerifyCode,
          loginController: this.controller,
        });
      }
      .edgeEffect(EdgeEffect.Spring);
    }
    .hideTitleBar(true)
    .title(buildTitleBar(''))
    .width('100%')
    .height('100%')
  }

  loginSuccess(unionID: string) {
    // 模拟登录
    let data: UserInfo = {
      id: 0,
      avatar: 'default_avatar',
      name: 'xx',
      nickname: '华为用户',
      sex: '男',
      cellphone: '10000001111',
      birthday: '1990-10-01',
      introDesc: '在自己的小世界里，做一个快乐的普通人，把节奏放慢，享受生活！十六岁的青春张扬 十八岁的未来可期，携零零碎碎的美好奔赴未知的将来！',
      code: unionID,
      isLogin: true,
      isMembership: false,
    }
    AccountUtil.updateUserInfo(data);
    if (this.nextRouter) {
      RouterModule.replace(this.nextRouter)
    } else {
      RouterModule.pop();
    }
  }
}
