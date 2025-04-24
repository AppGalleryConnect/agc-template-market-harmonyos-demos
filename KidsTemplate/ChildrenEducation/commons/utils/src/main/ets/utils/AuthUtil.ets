import { userAuth } from '@kit.UserAuthenticationKit';
import { BusinessError, Callback } from '@kit.BasicServicesKit';
import { LogUtil } from './LogUtil';
import { promptAction } from '@kit.ArkUI';
import { AuthOptions, StatusResult } from './entity/AuthOptions';
import { StringUtil } from './StringUtil';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';


export class AuthUtil {
  /**
   * 认证对象
   */
  private static userAuthInstance: userAuth.UserAuthInstance;

  /**
   * 查询指定类型和等级的认证能力是否支持。
   * @param authType
   * @param authTrustLevel
   * @returns
   */
  static getAvailableStatus(authType: userAuth.UserAuthType, authTrustLevel: userAuth.AuthTrustLevel): StatusResult {
    try {
      userAuth.getAvailableStatus(authType, authTrustLevel);
      return { status: true };
    } catch (err) {
      let error = err as BusinessError;
      LogUtil.error(`AuthUtil-getAvailableStatus-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      return { status: false, errorCode: error.code, errorMsg: AuthUtil.getErrorMsg(error.code) };
    }
  }


  /**
   * 开始认证,使用指纹和密码认证
   * @param showTip 是否显示提示语
   * @param callBack
   */
  static onStartEasy(showTip: boolean = false, callBack: Callback<userAuth.UserAuthResult>) {
    const options: AuthOptions = new AuthOptions();
    LogUtil.error(JSON.stringify(options, null, 2));
    options.showTip = showTip;
    AuthUtil.onStart(options, callBack);
  }


  /**
   * 开始认证，用户指定类型认证
   * @param options
   * @param callBack
   */
  static onStart(options: AuthOptions, callBack: Callback<userAuth.UserAuthResult>) {
    try {
      if (options.challenge === undefined) {
        // 挑战值，用来防重放攻击。最大长度为32字节，可传Uint8Array([])
        options.challenge = AuthUtil.getChallenge();
      }
      if (options.authType === undefined || options.authType.length <= 0) {
        //认证类型列表，用来指定用户认证界面提供的认证方法。
        options.authType = [userAuth.UserAuthType.FINGERPRINT, userAuth.UserAuthType.FACE, userAuth.UserAuthType.PIN];
      }
      if (options.authTrustLevel === undefined) {
        //认证信任等级。
        options.authTrustLevel = userAuth.AuthTrustLevel.ATL3;
      }
      if (options.title === undefined) {
        //用户认证界面的标题，最大长度为500字符。
        options.title = '请验证身份';
      }
      if (options.showTip === undefined) {
        //默认不显示提示语
        options.showTip = false;
      }
      const authParam: userAuth.AuthParam = {
        challenge: options.challenge,
        authType: options.authType,
        authTrustLevel: options.authTrustLevel,
      };
      if (options.navigationButtonText) {
        AuthUtil.userAuthInstance = userAuth.getUserAuthInstance(authParam, {
          title: options.title, navigationButtonText: options.navigationButtonText,
        });
      } else {
        AuthUtil.userAuthInstance = userAuth.getUserAuthInstance(authParam, { title: options.title });
      }
      AuthUtil.userAuthInstance.on('result', {
        onResult(result) {
          callBack?.(result);
          if (userAuth.UserAuthResultCode.SUCCESS === result.result && options.showTip) {
            const errorTip = AuthUtil.getErrorMsg(result.result, '');
            if (StringUtil.isNotEmpty(errorTip)) {
              promptAction.showToast({
                message: errorTip,
                alignment: Alignment.Center,
              });
            }
          }
        },
      });
      AuthUtil.userAuthInstance.start();
    } catch (err) {
      let error = err as BusinessError;
      LogUtil.error(`AuthUtil-onStart-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      if (options.showTip) {
        promptAction.showToast({
          message: AuthUtil.getErrorMsg(error.code, '认证失败：' + error.message),
          alignment: Alignment.Center,
        });
      }
    }
  }


  /**
   * 取消认证
   */
  static cancel() {
    try {
      if (AuthUtil.userAuthInstance) {
        AuthUtil.userAuthInstance.cancel(); //取消认证
      }
    } catch (err) {
      let error = err as BusinessError;
      LogUtil.error(`AuthUtil-cancel-异常 ~ code: ${error.code} -·- message: ${error.message}`);
    }
  }


  /**
   * 获取错误msg
   * @param code
   * @param defaultMsg
   */
  static getErrorMsg(code: number, defaultMsg: string = ''): string {
    if (201 === code) {
      return 'Permission verification failed. The application does not have the permission required to call the API.';
    } else if (202 === code) {
      return 'Permission verification failed. A non-system application calls a system API.';
    } else if (401 === code) {
      return 'Incorrect parameters.';
    } else if (801 === code) {
      return 'Capability not supported. Failed to call the API due to limited device capabilities.';
    } else if (12500001 === code) {
      return 'Authentication failed.';
    } else if (12500002 === code) {
      return 'General operation error.';
    } else if (12500003 === code) {
      return 'The operation is canceled.';
    } else if (12500004 === code) {
      return 'The operation is time-out.';
    } else if (12500005 === code) {
      return 'The authentication type is not supported.';
    } else if (12500006 === code) {
      return 'The authentication trust level is not supported.';
    } else if (12500007 === code) {
      return 'The authentication task is busy.';
    } else if (12500009 === code) {
      return 'The authenticator is locked.';
    } else if (12500010 === code) {
      return 'The type of credential has not been enrolled.';
    } else if (12500011 === code) {
      return 'Switched to the custom authentication process.';
    } else if (12700013 === code) {
      return 'Operation failed because of PIN expired.';
    } else {
      return defaultMsg;
    }
  }


  /**
   * 生成挑战值
   */
  private static getChallenge() {
    let rand = cryptoFramework.createRandom();
    let randData: Uint8Array = rand?.generateRandomSync(16)?.data;
    return randData;
  }
}