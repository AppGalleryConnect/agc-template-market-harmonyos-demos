import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { CancelAuthState } from '../model/UserInfo';

const TAG: string = '[AccountUtils]'
const DOMAIN: number = 0x00FF


export class AccountUtils {
  /**
   * 静默登录
   */
  public static silentLogin =
    async (callback: (data: authentication.LoginWithHuaweiIDCredential | undefined) => void): Promise<Boolean> => {
      try {
        let loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
        loginRequest.forceLogin = false;
        let controller = new authentication.AuthenticationController();
        return controller.executeRequest(loginRequest).then(async (data) => {
          const loginWithHuaweiIDResponse = data as authentication.LoginWithHuaweiIDResponse;
          const loginWithHuaweiIDCredential = loginWithHuaweiIDResponse.data;
          UtilLog.info(DOMAIN, TAG, `loginResponse=${JSON.stringify(loginWithHuaweiIDCredential)}`);
          callback(loginWithHuaweiIDCredential)
          return true;
        }).catch(async (error: BusinessError) => {
          UtilLog.error(DOMAIN, TAG, 'LoginWithHuaweiID executeRequest error: ' + JSON.stringify(error));
          return false;
        });
      } catch (err) {
        const error: BusinessError = err as BusinessError;
        UtilLog.error(DOMAIN, TAG, `Silent login failed: ${error.code}, ${error.message}`);
        return false;
      }
    }

  public static cancelRelative(callback: (state: CancelAuthState) => void = () => {
  }) {
    // 创建取消授权请求，并设置参数
    const cancelRequest = new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
    cancelRequest.state = util.generateRandomUUID(); // 建议使用generateRandomUUID生成state

    // 执行取消授权请求，并处理结果
    try {
      const controller = new authentication.AuthenticationController();
      controller.executeRequest(cancelRequest, (err: BusinessError<Object>, data) => {
        if (err) {
          UtilLog.error(DOMAIN, TAG, `Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
          callback(CancelAuthState.ERROR)
          return;
        }
        const cancelAuthorizationResponse = data as authentication.CancelAuthorizationResponse;
        const state = cancelAuthorizationResponse.state;
        if (state && cancelRequest.state !== state) {
          UtilLog.error(DOMAIN, TAG, `Failed to cancel. The state is different, response state: ${state}`);
          return;
        }
        UtilLog.info(DOMAIN, TAG, 'Succeeded in canceling.');
        callback(CancelAuthState.SUCCESS)
      });
    } catch (err) {
      callback(CancelAuthState.ERROR)
      UtilLog.error(DOMAIN, TAG, `Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
    }
  }
}