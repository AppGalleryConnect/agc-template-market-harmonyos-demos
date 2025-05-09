import { authentication } from '@kit.AccountKit'
import { util } from '@kit.ArkTS'
import { BusinessError } from '@ohos.base'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { UserApi } from '../apis/UserApi';
import { UserInfoResult } from '../model/ApiResponse';
import { UserInfo } from '../constants/CommonModel';
import { promptAction } from '@kit.ArkUI';

export class AuthenticationUtil {
  public static readonly AUTHENTICATION_INFO_KEY: string = 'authenticationInfo'
  public static loginWithHuaweiIDCredential: authentication.LoginWithHuaweiIDCredential | undefined = undefined

  // 关联授权
  public static async authenticationLogin(): Promise<string> {
    return new Promise((resolve, reject) => {
      // 创建授权请求，并设置参数
      const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
      // 获取手机号需要传如下scope，传参数之前需要先申请对应scope权限,才能返回对应数据
      authRequest.scopes = ['phone'];
      // 获取code需传如下permission
      authRequest.permissions = ['serviceauthcode'];
      // 用户是否需要登录授权，该值为true且用户未登录或未授权时，会拉起用户登录或授权页面
      authRequest.forceAuthorization = true;
      // 用于防跨站点请求伪造
      authRequest.state = util.generateRandomUUID();

      const controller = new authentication.AuthenticationController(getContext())
      controller.executeRequest(authRequest).then((data) => {
        const authorizationWithHuaweiIDResponse = data as authentication.AuthorizationWithHuaweiIDResponse;
        const state = authorizationWithHuaweiIDResponse.state;
        if (state !== undefined && authRequest.state !== state) {
          hilog.error(0x0000, 'testTag', `Failed to authorize. The state is different, response state: ${state}`);
          reject('error state: ' + state)
          return
        }
        const authorizationWithHuaweiIDCredential = authorizationWithHuaweiIDResponse.data!;
        const code = authorizationWithHuaweiIDCredential.authorizationCode;
        if (code) {
          resolve(code)
        } else {
          reject('error authorization')
        }
      }).catch((error: BusinessError) => {
        hilog.error(0x0000, 'testTag', `Failed to login. errCode is ${error.code}, errMessage is ${error.message}`)
        reject(error)
      })
    });
  }
  // 取消授权
  public static async cancelAuthentication(): Promise<string> {
    return new Promise((resolve, reject) => {
      // 创建取消授权请求，并设置参数
      const cancelRequest = new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
      cancelRequest.state = util.generateRandomUUID();
      const controller = new authentication.AuthenticationController(getContext());
      controller.executeRequest(cancelRequest, (error: BusinessError<Object>, data) => {
        if (error) {
          reject('Failed error: ' + JSON.stringify(error))
          return;
        }
        const cancelAuthorizationResponse = data as authentication.CancelAuthorizationResponse;
        const state = cancelAuthorizationResponse.state;
        if (state && cancelRequest.state !== state) {
          hilog.error(0x0000, 'testTag', `Failed to cancel. The state is different, response state: ${state}`);
          reject('Failed state: ' + state)
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in canceling.');
        resolve('success')
      });
    })
  }

  // 静默登录
  public static async silentLogin(callback: (isSuccess: boolean, userInfo: UserInfo) => void) {
    AuthenticationUtil.authenticationLogin().then((code: string) => {
      if (code) {
        UserApi.userLogin(code).then((userInfo) => {
          let result = userInfo.result as UserInfoResult
          if (result.ret.code === 0) {
            let userRes = result.result[0] as UserInfo
            callback(true, new UserInfo(userRes))
          } else {
            promptAction.showToast({message: '账号关联失败，请重试~'})
            AuthenticationUtil.cancelAuthentication()
            callback(false, new UserInfo())
          }
        }).catch(() => {
          promptAction.showToast({message:'账号关联失败'})
          AuthenticationUtil.cancelAuthentication()
          callback(false, new UserInfo())
        })
      }
    }).catch(() => {
      promptAction.showToast({message:'取消关联手机号'})
      AuthenticationUtil.cancelAuthentication()
      callback(false, new UserInfo())
    })
  }
}