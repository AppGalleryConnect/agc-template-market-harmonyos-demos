import { AppStorageV2 } from '@kit.ArkUI';
import { AppStorageMap } from '../constants/CommonEnums';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { Logger } from './Logger';
import { BusinessError } from '@kit.BasicServicesKit';

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
  @Trace public isLogin: boolean = false;
  @Trace public avatar: string = '';
  @Trace public nickname: string = '';
  @Trace public phone: string = '';
}

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

  public static getAccountInfo() {
    return AccountUtil._accountInfo;
  }

  public static setUserInfo(info: UserInfoModel) {
    AccountUtil._userInfo.phone = info.phone;
    AccountUtil._userInfo.nickname = info.nickname;
    AccountUtil._userInfo.avatar = info.avatar;
  }

  public static getUserInfo() {
    return AccountUtil._userInfo;
  }

  // Revoke authorization.
  public static cancelAuthorization() {
    // Create an authorization revoking request and set parameters.
    const cancelRequest: authentication.CancelAuthorizationRequest =
      new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
    // Used to prevent cross-site request forgery. You are advised to assign a value to state as follows:
    cancelRequest.state = util.generateRandomUUID();
    // Execute the request.
    try {
      const controller: authentication.AuthenticationController = new authentication.AuthenticationController();
      controller.executeRequest(cancelRequest).then((data: authentication.AuthenticationResponse) => {
        const cancelAuthorizationResponse = data as authentication.CancelAuthorizationResponse;
        const state: string = cancelAuthorizationResponse.state!;
        if (cancelRequest.state !== state) {
          Logger.error(TAG, 'Failed to cancel. The state is different');
          return;
        }
      }).catch((err: BusinessError) => {
        Logger.error(TAG,
          `Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
      });
    } catch (err) {
      Logger.error(TAG, `Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
    }
  }

  private static _dealAllError(error: BusinessError): void {
    Logger.error(TAG, `Failed to login, errorCode: ${error.code}, errorMsg: ${error.message}`);
  }
}
