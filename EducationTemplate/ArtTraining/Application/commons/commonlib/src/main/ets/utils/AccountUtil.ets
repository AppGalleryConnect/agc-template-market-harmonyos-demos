import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { AppStorageMap } from '../constants/CommonEnums';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { Logger } from './Logger';
import { BusinessError } from '@kit.BasicServicesKit';
import { UserInfo } from '../types/Index';

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
  @Trace public avatar: string = '';
  @Trace public nickname: string = '';
  @Trace public phone: string = '';
  @Trace public studentID: string = '';
  @Trace public wechat: string = '';
  @Trace public birthday: string = '';
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
      await controller
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
          Logger.debug(TAG, 'unionID:::' + AccountUtil._accountInfo.unionID);
          Logger.debug(TAG, 'openID:::' + AccountUtil._accountInfo.openID);
          Logger.debug(TAG, 'idToken:::' + AccountUtil._accountInfo.idToken);
          Logger.debug(TAG, 'authCode:::' + AccountUtil._accountInfo.authCode);
        })
        .catch((error: BusinessError) => {
          AccountUtil._dealAllError(error);
        });
    } catch (error) {
      AccountUtil._dealAllError(error);
    }
  }

  public static async cancelAuthorization() {
    const cancelRequest: authentication.CancelAuthorizationRequest =
      new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
    cancelRequest.state = util.generateRandomUUID();
    try {
      const controller: authentication.AuthenticationController = new authentication.AuthenticationController();
      controller.executeRequest(cancelRequest).then((data: authentication.AuthenticationResponse) => {
        const cancelAuthorizationResponse = data as authentication.CancelAuthorizationResponse;
        const state: string = cancelAuthorizationResponse.state!;
        if (cancelRequest.state !== state) {
          Logger.error('Failed to cancel. The state is different');
          return;
        }
        AccountUtil.clearUserInfo();
        promptAction.showToast({ message: '解除账号关联成功！' });
        Logger.debug(TAG, 'cancel authorization success');
      }).catch((err: BusinessError) => {
        Logger.error(`Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
      });
    } catch (err) {
      Logger.error(`Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
    }
  }

  public static getAccountInfo() {
    return AccountUtil._accountInfo;
  }

  public static clearUserInfo() {
    AccountUtil._userInfo.avatar = '';
    AccountUtil._userInfo.nickname = '';
    AccountUtil._userInfo.phone = '';
    AccountUtil._userInfo.studentID = '';
    AccountUtil._userInfo.wechat = '';
    AccountUtil._userInfo.birthday = '';
  }

  public static setUserInfo(info: UserInfo) {
    AccountUtil._userInfo.avatar = info.avatar;
    if (info.studentID) {
      AccountUtil._userInfo.studentID = info.studentID;
    }
    AccountUtil._userInfo.nickname = info.nickname;
    AccountUtil._userInfo.wechat = info.wechat;
    AccountUtil._userInfo.birthday = info.birthday;
    AccountUtil._userInfo.phone = info.phone;
  }

  public static getUserInfo() {
    return AccountUtil._userInfo;
  }

  private static _dealAllError(error: BusinessError): void {
    Logger.error(TAG, `Failed to login, errorCode: ${error.code}, errorMsg: ${error.message}`);
  }
}
