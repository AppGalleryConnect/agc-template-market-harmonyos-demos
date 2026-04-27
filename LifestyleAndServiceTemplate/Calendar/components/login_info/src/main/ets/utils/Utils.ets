import { LoginParams } from '../model/Model';

export class LoginEventDispatcher {
  static loginCallback?: (loginParams:LoginParams) => void;
  static huaweiLoginCallback?: (loginParams:LoginParams) => void;
  static dispatchToLogin(loginParams:LoginParams) {
    if (LoginEventDispatcher.loginCallback) {
      LoginEventDispatcher.loginCallback(loginParams);
    }
  }
  static dispatchToHuaweiLogin(loginParams:LoginParams) {
    if (LoginEventDispatcher.huaweiLoginCallback) {
      LoginEventDispatcher.huaweiLoginCallback(loginParams);
    }
  }
}