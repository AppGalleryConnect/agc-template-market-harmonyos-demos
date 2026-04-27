import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { HuaweiAccountInfo, UserInfo } from 'types';
import { Logger } from './Logger';

@ObservedV2
export class AccountUtil {
  private static userInfo: UserInfo = AppStorageV2.connect(UserInfo, 'userInfo', () => new UserInfo())!;
  private static accountInfo: HuaweiAccountInfo =
    PersistenceV2.connect(HuaweiAccountInfo, 'accountInfo', () => new HuaweiAccountInfo())!;
  public static functionalController: functionalButtonComponentManager.FunctionalButtonController =
    new functionalButtonComponentManager.FunctionalButtonController();

  public static async initLogin(uiContext: UIContext) {
    if (AccountUtil.accountInfo.unionID?.length === 0) {
      AccountUtil.silentLogin(uiContext);
    } else {
      // 存在union设置nickname
      AccountUtil.setNickName();
    }
  }

  private static silentLogin(uiContext: UIContext) {
    try {
      const loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
      loginRequest.forceLogin = false;
      loginRequest.state = util.generateRandomUUID();
      const controller = new authentication.AuthenticationController();
      controller.executeRequest(loginRequest).then((response: authentication.LoginWithHuaweiIDResponse) => {
        const loginWithHuaweiIDResponse = response as authentication.LoginWithHuaweiIDResponse;
        const state = loginWithHuaweiIDResponse.state;
        if (state && loginRequest.state !== state) {
          return;
        }
        const loginWithHuaweiIDCredential = loginWithHuaweiIDResponse.data!;
        const unionID = loginWithHuaweiIDCredential.unionID;
        AccountUtil.setNickName();
        AccountUtil.accountInfo.unionID = unionID;
        AppStorageV2.connect(HuaweiAccountInfo, 'accountInfo', () => new HuaweiAccountInfo())!;
      }).catch((error: BusinessError) => {
        if (error.code === 1001502001) {
          uiContext.getPromptAction().showToast({ message: '请先登录华为账号' });
        }
        AccountUtil.dealAllError(error);
      });
    } catch (error) {
      AccountUtil.dealAllError(error);
    }
  }

  public static setNickName() {
    AccountUtil.userInfo.nickname = '华为用户';
    AppStorageV2.connect(UserInfo, 'userInfo', () => new UserInfo())!;
  }

  public static getUserInfo(): UserInfo {
    return AccountUtil.userInfo;
  }

  public static mockLinkUser() {
    AccountUtil.userInfo.isLink = true
    AccountUtil.userInfo.phone = '120****4456'
    AccountUtil.userInfo.nickname = '华为用户'
    AccountUtil.userInfo.avatar = $r('app.media.default_avatar')
  }

  public static mockUnlinkUser() {
    AccountUtil.userInfo.isLink = false
    AccountUtil.userInfo.phone = ''
    AccountUtil.userInfo.nickname = ''
    AccountUtil.userInfo.avatar = ''
  }

  public static getAccountInfo(): HuaweiAccountInfo {
    return AccountUtil.accountInfo;
  }

  private static dealAllError(error: BusinessError): void {
    Logger.error(`Failed to login, errorCode: ${error.code}, errorMsg: ${error.message}`);
  }
}