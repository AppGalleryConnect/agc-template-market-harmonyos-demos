import { AppStorageV2 } from '@kit.ArkUI';
import { AppStorageMap } from '../constants/CommonEnums';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { Logger } from './Logger';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = '[AccountUtil]';

@ObservedV2
export class HuaweiAccountModel {
  @Trace public openID: string | undefined = '';
  @Trace public unionID: string | undefined = '';
  @Trace public authCode?: string = '';
  @Trace public idToken?: string = '';
}

@ObservedV2
export class UserInfoModel {
  @Trace public avatar: string | undefined = '';
  @Trace public nickname: string | undefined = '';
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
      Logger.error(TAG, `Account info exists`);
      return;
    }
    try {
      const loginRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
      loginRequest.forceAuthorization = true;
      loginRequest.scopes = ['profile'];
      loginRequest.state = util.generateRandomUUID();
      const controller = new authentication.AuthenticationController(getContext());
      const response: authentication.AuthorizationWithHuaweiIDResponse = await controller.executeRequest(loginRequest);
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
      AccountUtil._userInfo.avatar = loginWithHuaweiIDCredential.avatarUri;
      AccountUtil._userInfo.nickname = loginWithHuaweiIDCredential.nickName;

      Logger.debug(TAG, 'unionID:::' + AccountUtil._accountInfo.unionID);
      Logger.debug(TAG, 'openID:::' + AccountUtil._accountInfo.openID);
      Logger.debug(TAG, 'idToken:::' + AccountUtil._accountInfo.idToken);
      Logger.debug(TAG, 'authCode:::' + AccountUtil._accountInfo.authCode);
    } catch (error) {
      AccountUtil._dealAllError(error);
    }
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
