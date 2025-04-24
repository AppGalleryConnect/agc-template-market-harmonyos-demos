import { AppStorageV2 } from '@kit.ArkUI';
import { AppStorageMap } from '../constants/CommonEnums';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { Logger } from './Logger';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = '[AccountUtil]';

@ObservedV2
export class HuaweiAccountModel {
  @Trace public openID: string = '';

  @Trace public unionID: string = '';

  @Trace public authCode?: string = '';

  @Trace public idToken?: string = '';
}

@ObservedV2
export class UserInfoModel {
  @Trace public avatar?: string;

  @Trace public nickname: string = '';

  @Trace public phone: string = '';
}

@ObservedV2
export class AccountUtil {
  private static _accountInfo: HuaweiAccountModel = AppStorageV2.connect(
    HuaweiAccountModel,
    AppStorageMap.HUAWEI_ACCOUNT,
    () => new HuaweiAccountModel(),
  )!;

  private static _userInfo: UserInfoModel = AppStorageV2.connect(
    UserInfoModel,
    AppStorageMap.USER_INFO,
    () => new UserInfoModel(),
  )!;

  public static async silentLogin() {
    if (AccountUtil._accountInfo.unionID) {
      return;
    }
    try {
      const loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
      loginRequest.forceLogin = false;
      loginRequest.state = util.generateRandomUUID();
      const controller = new authentication.AuthenticationController();
      controller
        .executeRequest(loginRequest)
        .then((response: authentication.LoginWithHuaweiIDResponse) => {
          const state = response.state;
          if (state !== undefined && loginRequest.state !== state) {
            Logger.error(TAG, `Failed to login. The state is different, response state: ${state}`);
            return;
          }
          const loginWithHuaweiIDCredential = response.data!;
          AccountUtil._accountInfo.idToken = loginWithHuaweiIDCredential.idToken;
          AccountUtil._accountInfo.openID = loginWithHuaweiIDCredential.openID;
          AccountUtil._accountInfo.unionID = loginWithHuaweiIDCredential.unionID;
          AccountUtil._accountInfo.authCode = loginWithHuaweiIDCredential.authorizationCode;
        })
        .catch((error: BusinessError) => {
          AccountUtil._dealAllError(error);
        });
    } catch (error) {
      AccountUtil._dealAllError(error);
    }
  }

  // 绑定华为账号
  public static async connectHuaweiAccount(context: Context): Promise<string | undefined> {
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
    try {
      const controller = new authentication.AuthenticationController(context);
      const data = await controller.executeRequest(authRequest);
      const authorizationWithHuaweiIDResponse = data as authentication.AuthorizationWithHuaweiIDResponse;
      const state = authorizationWithHuaweiIDResponse.state;
      if (state !== undefined && authRequest.state !== state) {
        hilog.error(0x0000, 'testTag', `Failed to authorize. The state is different, response state: ${state}`);
        return undefined;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in authentication.');
      const authorizationWithHuaweiIDCredential = authorizationWithHuaweiIDResponse.data!;
      const code = authorizationWithHuaweiIDCredential.authorizationCode;
      return code;
    } catch (error) {
      AccountUtil._dealAllError(error);
      return undefined;
    }
  }

  public static async cancelAuthorization(): Promise<void> {
    // Create an authorization revoking request and set parameters.
    const cancelRequest: authentication.CancelAuthorizationRequest =
      new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
    // Used to prevent cross-site request forgery. You are advised to assign a value to state as follows:
    cancelRequest.state = util.generateRandomUUID();
    // Execute the request.
    try {
      const controller: authentication.AuthenticationController = new authentication.AuthenticationController();
      const data: authentication.AuthenticationResponse = await controller.executeRequest(cancelRequest);
      const cancelAuthorizationResponse = data as authentication.CancelAuthorizationResponse;
      const state: string = cancelAuthorizationResponse.state!;
      if (cancelRequest.state !== state) {
        Logger.error(TAG, 'Failed to cancel. The state is different');
        return;
      }
      AccountUtil._resetAccountInfo();
    } catch (err) {
      Logger.error(TAG, `Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
    }
    return;
  }

  private static _resetAccountInfo() {
    AccountUtil._accountInfo.idToken = '';
    AccountUtil._accountInfo.openID = '';
    AccountUtil._accountInfo.unionID = '';
    AccountUtil._accountInfo.authCode = '';
    AccountUtil._userInfo.avatar = '';
    AccountUtil._userInfo.nickname = '';
    AccountUtil._userInfo.phone = '';
  }

  public static getAccountInfo() {
    return AccountUtil._accountInfo;
  }

  public static setUserInfo(info: UserInfoModel) {
    AccountUtil._userInfo.avatar = info.avatar;
    AccountUtil._userInfo.nickname = info.nickname;
    AccountUtil._userInfo.phone = info.phone;
  }

  public static getUserInfo() {
    return AccountUtil._userInfo;
  }

  private static _dealAllError(error: BusinessError): void {
    Logger.error(TAG, `Failed to login, errorCode: ${error.code}, errorMsg: ${error.message}`);
  }
}
