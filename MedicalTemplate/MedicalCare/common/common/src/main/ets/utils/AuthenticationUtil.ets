import { authentication } from '@kit.AccountKit'
import { util } from '@kit.ArkTS'
import { BaseError } from '../exception/BaseError'
import { LogUtil } from './LogUtil'
import { BusinessError } from '@ohos.base'

/**
 * 静默登录工具类
 */
export class AuthenticationUtil {
  public static readonly AUTHENTICATION_INFO_KEY: string = 'authenticationInfo'
  public static loginWithHuaweiIDCredential: authentication.LoginWithHuaweiIDCredential | undefined = undefined

  public static async silentLogin(): Promise<authentication.LoginWithHuaweiIDCredential> {
    return new Promise((resolve, reject) => {
      // Create a sign-in request and set parameters.
      const loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest()
      // false: If the user has not signed in to the HUAWEI ID,
      // the HUAWEI ID sign-in screen will not be displayed. Instead, error code 1001502001 will be returned.
      loginRequest.forceLogin = true
      // Used to prevent cross-site request forgery.
      loginRequest.state = util.generateRandomUUID()

      // Execute the sign-in request.
      const controller = new authentication.AuthenticationController()
      controller.executeRequest(loginRequest).then((response: authentication.LoginWithHuaweiIDResponse) => {
        const loginWithHuaweiIDResponse = response as authentication.LoginWithHuaweiIDResponse
        const state = loginWithHuaweiIDResponse.state
        if (state !== undefined && loginRequest.state !== state) {
          LogUtil.error(`Failed to login. The state is different, response state: ${state}`)
          reject(new BaseError('State mismatch'))
          return
        }
        AuthenticationUtil.loginWithHuaweiIDCredential = loginWithHuaweiIDResponse.data!
        resolve(AuthenticationUtil.loginWithHuaweiIDCredential)
      }).catch((error: BusinessError) => {
        LogUtil.error(`Failed to login. errCode is ${error.code}, errMessage is ${error.message}`)
        reject(error)
      })
    });
  }

  /**
   * 获取认证信息。如果已经登录，直接返回；否则尝试静默登录。
   *
   * @returns {Promise<authentication.LoginWithHuaweiIDCredential>} 登录凭据，如果登录失败则 reject BusinessError。
   */
  public static async getAuthenticationInfoAsync(): Promise<authentication.LoginWithHuaweiIDCredential> {
    if (AuthenticationUtil.loginWithHuaweiIDCredential) {
      return AuthenticationUtil.loginWithHuaweiIDCredential;
    } else {
      return AuthenticationUtil.silentLogin(); // Directly return the promise from silentLogin
    }
  }
}