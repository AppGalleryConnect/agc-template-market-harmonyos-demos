import { LoginChannelType } from '../common/Constant';
import { LoginFailError, LoginParams } from '../model/Index';

export class LoginEventDispatcher {

  static loginFailCallback?: (loginChannelType: LoginChannelType, error: LoginFailError) => void; // 登录失败回调


  static dispatchToLoginFail(loginChannelType: LoginChannelType, error: LoginFailError) {
    if (LoginEventDispatcher.loginFailCallback) {
      LoginEventDispatcher.loginFailCallback(loginChannelType, error);
    }
  }
}


export class ApiController {
  constructor(huaweiLogin: (loginParams: LoginParams) => Promise<void>,
    wxLogin: () => Promise<void>,
    verifyCodeLogin: (loginParams: LoginParams) => Promise<void>,) {
    this.huaweiLogin = huaweiLogin;
    this.wxLogin = wxLogin;
    this.verifyCode = verifyCodeLogin;
  }

  huaweiLogin: (loginParams: LoginParams) => Promise<void> = () => new Promise(() => {
  });
  wxLogin: () => Promise<void> = () => new Promise(() => {
  });
  verifyCode: (loginParams: LoginParams) => Promise<void> = () => new Promise(() => {
  });
}

export class LoginController {
  clearLoginInfo: () => void = () => {}
}