import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { GlobalContext, Logger } from 'lib_common';

const TAG = '[HuaweiAuthUtils]';

/**
 * 华为登录认证工具类
 */
export class HuaweiAuthUtils {
  /**
   * 获取匿名手机号
   */
  static async quickLoginAnonymousPhone() {
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    authRequest.scopes = ['quickLoginAnonymousPhone'];
    authRequest.forceAuthorization = false;
    const controller = new authentication.AuthenticationController();
    let quickLoginAnonymousPhone: string = '';
    let unionID: string = '';
    try {
      const response: authentication.AuthorizationWithHuaweiIDResponse = await controller.executeRequest(authRequest);
      unionID = response.data?.unionID as string;
      quickLoginAnonymousPhone = response.data?.extraInfo?.quickLoginAnonymousPhone as string ?? '';
      Logger.info(TAG,
        `Succeeded in authorizing. unionID is ${unionID}, quickLoginAnonymousPhone is ${quickLoginAnonymousPhone}`);
      return quickLoginAnonymousPhone;
    } catch (error) {
      Logger.error(TAG,
        `Failed to authorize. errCode is ${error.code}, message is ${error.message}`);
      return quickLoginAnonymousPhone;
    }
  }

  /**
   * 登录华为账号
   * @returns
   */
  static loginHuaweiID(): Promise<void> {
    const loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
    // 默认值为true，若账号未登录则强制拉起账号登录页
    loginRequest.forceLogin = true;
    loginRequest.state = util.generateRandomUUID();
    const controller = new authentication.AuthenticationController(GlobalContext.getContext());
    return new Promise((resolve, reject) => {
      controller.executeRequest(loginRequest).then((resp: authentication.AuthorizationWithHuaweiIDResponse) => {
        Logger.info(TAG, 'login huawei success, response: ' + JSON.stringify(resp));
        resolve();
      }).catch((err: BusinessError) => {
        Logger.error(TAG, 'login huawei failed, error: ' + JSON.stringify(err));
        reject();
      });
    })
  }
}