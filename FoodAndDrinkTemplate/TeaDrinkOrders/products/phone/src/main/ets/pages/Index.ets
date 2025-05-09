import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {
  BaseResponse,
  Constants,
  HmSystem,
  HttpCode,
  HttpRequestApi,
  RouterMap,
  StoreInfoModel,
  UserInfo,
  UserInfoModel,
} from 'common/Index';
import { HuaweiIDResp } from 'common/src/main/ets/models/TabBarModel';
import { AppStorageV2 } from '@kit.ArkUI';
import { AppInfoModel } from 'common/src/main/ets/models/StorageModel';

@Entry
@ComponentV2
struct Index {
  @Provider('pageStack') pageStack: NavPathStack = new NavPathStack();
  @Local appInfo: AppInfoModel = AppStorageV2.connect(AppInfoModel)!;
  @Local storeInfo: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local openId: string = '';
  @Local unionId: string = '';
  @Local authCode: string = '';

  aboutToAppear() {
    Promise.all([this.getHmSystem(), this.loginWithHuaweiID()]).then(res => {
      this.storeInfo.tel = res[0].tel;
      this.openId = res[1].openId;
      this.unionId = res[1].unionId;
      this.authCode = res[1].authCode;
      this.initQuery();
    });
  }

  initQuery() {
    // 查询用户信息
    this.getUserInfo(this.openId, this.unionId).then((resp) => {
      this.userInfo.userInfo = resp;
      this.userInfo.isRelative = !!resp.userTel
    });
    this.pageStack.replacePathByName(RouterMap.INDEX_PAGE, null);
  }

  build() {
    Column() {
      Navigation(this.pageStack) {
      }
      .hideTitleBar(true)
      .hideNavBar(true)
      .mode(NavigationMode.Stack)
      .height(Constants.FULL_SIZE)
      .width(Constants.FULL_SIZE);
    }
    .height(Constants.FULL_SIZE)
    .width(Constants.FULL_SIZE);

  }

  /**
   * Sample code for using HUAWEI ID to log in to atomic service.
   * According to the Atomic Service Review Guide, when a atomic service has an account system,
   * the option to log in with a HUAWEI ID must be provided.
   * The following presets the atomic service to use the HUAWEI ID silent login function.
   * To enable the atomic service to log in successfully using the HUAWEI ID, please refer
   * to the HarmonyOS HUAWEI ID Access Guide to configure the client ID and fingerprint certificate.
   */
  private loginWithHuaweiID(): Promise<HuaweiIDResp> {
    return new Promise((resolve, reject) => {
      // Create a login request and set parameters
      let loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
      // Whether to forcibly launch the HUAWEI ID login page when the user is not logged in with the HUAWEI ID
      loginRequest.forceLogin = false;
      // Execute login request
      let controller = new authentication.AuthenticationController();
      controller.executeRequest(loginRequest).then((data) => {
        let loginWithHuaweiIDResponse = data as authentication.LoginWithHuaweiIDResponse;
        let authCode = loginWithHuaweiIDResponse.data?.authorizationCode;
        let openId = loginWithHuaweiIDResponse.data?.openID;
        let unionId = loginWithHuaweiIDResponse.data?.unionID;
        resolve({ openId, unionId, authCode } as HuaweiIDResp);
        // Send authCode to the backend in exchange for unionID, session

      }).catch((error: BusinessError) => {
        hilog.error(0x0000, 'testTag', 'error: %{public}s', JSON.stringify(error));
        if (error.code === authentication.AuthenticationErrorCode.ACCOUNT_NOT_LOGGED_IN) {
          // HUAWEI ID is not logged in, it is recommended to jump to the login guide page
        }
        // 屏蔽云测试调试reject(error);
        resolve({} as HuaweiIDResp);
      });
    });

  }

  private getHmSystem(): Promise<HmSystem> {
    return new Promise((resolve, reject) => {
      HttpRequestApi.getHmSystem()
        .then((resp: BaseResponse<HmSystem>) => {
          if (resp.code === HttpCode.SUCCESS) {
            console.info(`getHmSystem resp:${JSON.stringify(resp.data)}.`);
            resolve(resp.data)
          } else {
            console.error(`getHmSystem error: ${JSON.stringify(resp)}.`);
            reject(resp.msg)
          }
        })
        .catch((e: BusinessError) => {
          console.error(`getHmSystem error: ${JSON.stringify(e)}.`);
          reject(e)
        })
    })
  }

  private getUserInfo(openid: string, unionId: string): Promise<UserInfo> {
    return new Promise((resolve, reject) => {
      HttpRequestApi.getUserInfo(this.appInfo.packageName, openid, unionId)
        .then((resp: BaseResponse<UserInfo>) => {
          if (resp.code === HttpCode.SUCCESS) {
            console.info(`getUserInfo resp:${JSON.stringify(resp)}.`);
            resolve(resp.data);
          } else {
            console.error(`getUserInfo error: ${JSON.stringify(resp)}.`);
            reject(resp.msg);
          }
        })
        .catch((e: BusinessError) => {
          console.error(`getUserInfo error: ${JSON.stringify(e)}.`);
          reject(e);
        });
    });
  }
}
