import { PersistenceV2, promptAction } from '@kit.ArkUI';
import { functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { Logger } from 'util';


const TAG = 'ACCOUNT';

@ObservedV2
export class UserInfo {
  @Trace avatar?: string;
  @Trace phone?: string;
  @Trace address?: functionalButtonComponentManager.ChooseAddressResult;
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
  private static userInfo: UserInfo = PersistenceV2.connect(UserInfo, 'userInfo', () => new UserInfo())!;
  public static functionalController: functionalButtonComponentManager.FunctionalButtonController =
    new functionalButtonComponentManager.FunctionalButtonController();

  public static initLogin() {
    if (!AppStorage.get('currentUser')) {
      AccountUtil.silentLogin();
    }
  }

  private static silentLogin() {
    try {
      const loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
      loginRequest.forceLogin = false;
      loginRequest.state = util.generateRandomUUID();
      const controller = new authentication.AuthenticationController();
      controller.executeRequest(loginRequest).then((response: authentication.LoginWithHuaweiIDResponse) => {
        const loginWithHuaweiIDResponse = response as authentication.LoginWithHuaweiIDResponse;
        const state = loginWithHuaweiIDResponse.state;
        if (state !== undefined && loginRequest.state !== state) {
          return;
        }
        const loginWithHuaweiIDCredential = loginWithHuaweiIDResponse.data!;
        const openID = loginWithHuaweiIDCredential.openID;
        const unionID = loginWithHuaweiIDCredential.unionID;
        AppStorage.setOrCreate('currentUser', unionID);
        AppStorage.setOrCreate('openID', openID);
      }).catch((error: BusinessError) => {
        if (error.code === 1001502001) {
          promptAction.showToast({ message: '请先登录华为帐号' });
        }
        AccountUtil.dealAllError(error);
      });
    } catch (error) {
      AccountUtil.dealAllError(error);
    }
  }

  private static dealAllError(error: BusinessError): void {
    Logger.error(TAG, `Failed to login, errorCode: ${error.code}, errorMsg: ${error.message}`);
  }

  public static getCurrentUser(): string | undefined {
    return AppStorage.get('currentUser');
  }

  public static getOpenId(): string | undefined {
    const openId: string | undefined = AppStorage.get('openID');
    if (!openId) {
      Logger.error(TAG, 'openId id is not existed');
      return '';
    }
    return openId;
  }
}