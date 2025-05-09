import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from './Logger';
import { UserInfo } from '../types/Types';
import { AppStorageMap } from '../constants/CommonEnum';

const TAG = '[AccountUtil]';

@ObservedV2
export class UserInfoModel implements UserInfo {
  @Trace id: number = 0;
  @Trace avatar: string = '';
  @Trace name: string = '';
  @Trace nickname: string = '';
  @Trace sex: string = '';
  @Trace cellphone: string = '';
  @Trace birthday: string = '';
}

@ObservedV2
export class HUAWEIAccountModel {
  @Trace idToken?: string = '';
  @Trace openID?: string = '';
  @Trace unionID?: string = '';
  @Trace signOpenID?: string = '';
  @Trace authCode?: string = '';
  @Trace loginToken?: string = '';
}

@ObservedV2
export class AccountUtil {
  private static _userInfo: UserInfoModel = AppStorageV2.connect(
    UserInfoModel,
    AppStorageMap.USER_INFO,
    () => new UserInfoModel(),
  )!;
  private static _accountInfo: HUAWEIAccountModel = PersistenceV2.connect(
    HUAWEIAccountModel,
    'accountInfo',
    () => new HUAWEIAccountModel(),
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
          const loginWithHuaweiIDResponse = response as authentication.LoginWithHuaweiIDResponse;
          const state = loginWithHuaweiIDResponse.state;
          if (state !== undefined && loginRequest.state !== state) {
            Logger.error(TAG, `Failed to login. The state is different, response state: ${state}`);
            return;
          }
          const loginWithHuaweiIDCredential = loginWithHuaweiIDResponse.data!;
          AccountUtil._accountInfo.idToken = loginWithHuaweiIDCredential.idToken;
          AccountUtil._accountInfo.openID = loginWithHuaweiIDCredential.openID;
          const unionID = loginWithHuaweiIDCredential.unionID;
          AccountUtil._accountInfo.unionID = unionID;
          AccountUtil._accountInfo.authCode = loginWithHuaweiIDCredential.authorizationCode;
          Logger.debug(TAG, 'unionID:::' + AccountUtil._accountInfo.unionID);
          Logger.debug(TAG, 'openID:::' + AccountUtil._accountInfo.openID);
          Logger.debug(TAG, 'authCode:::' + AccountUtil._accountInfo.authCode ?? '');
        })
        .catch((error: BusinessError) => {
          AccountUtil._dealAllError(error);
        });
    } catch (error) {
      AccountUtil._dealAllError(error);
    }
  }

  public static getAccountInfo() {
    return AccountUtil._accountInfo;
  }

  public static getUserInfo(): UserInfoModel {
    return AccountUtil._userInfo;
  }

  public static getAuthorization() {
    if (!AccountUtil._accountInfo.loginToken) {
      return AccountUtil._accountInfo.authCode;
    }
    // 鉴权token，从login接口获取，有效期60天
    return AccountUtil._accountInfo.loginToken;
  }

  public static updateUserInfo(data: UserInfo) {
    AccountUtil._userInfo.name = data.name;
    AccountUtil._userInfo.nickname = data.nickname;
    AccountUtil._userInfo.sex = data.sex;
    AccountUtil._userInfo.cellphone = data.cellphone;
    AccountUtil._userInfo.birthday = data.birthday;
    AccountUtil._userInfo.id = data.id;
    AccountUtil._userInfo.avatar = data.avatar;
  }

  private static _dealAllError(error: BusinessError): void {
    Logger.error(TAG, `Failed to login, errorCode: ${error.code}, errorMsg: ${error.message}`);
  }
}
