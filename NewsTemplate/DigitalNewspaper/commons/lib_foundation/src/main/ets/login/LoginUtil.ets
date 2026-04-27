/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { getUserInfo, loginWithHuaweiID } from '../http/ApiManage';
import { AppStorageMap, CurAppInfo } from '../common/Constant';

const TAG = '[LoginUtil]';

/**
 * 登录工具类
 */
export class LoginUtil {
  /**
   * 静默登录
   */
  static async silentLogin(): Promise<Boolean> {
    try {
      let loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
      loginRequest.forceLogin = false;
      let controller = new authentication.AuthenticationController();
      return controller.executeRequest(loginRequest).then(async (data) => {
        const loginWithHuaweiIDResponse = data as authentication.LoginWithHuaweiIDResponse;
        const loginWithHuaweiIDCredential = loginWithHuaweiIDResponse.data;
        Logger.info(TAG, `loginResponse=${JSON.stringify(loginWithHuaweiIDCredential)}`);

        const resp = await loginWithHuaweiID({
          clientId: CurAppInfo.CLIENT_ID,
          code: loginWithHuaweiIDCredential?.authorizationCode || '',
          idToken: loginWithHuaweiIDCredential?.idToken || '',
          openId: loginWithHuaweiIDCredential?.openID || '',
          unionId: loginWithHuaweiIDCredential?.unionID || '',
        });
        Logger.info(TAG, 'loginWithHuaweiID success, token:' + resp.token);
        AppStorage.setOrCreate(AppStorageMap.TOKEN, resp.token);
        await LoginUtil.queryUserInfo();
        return true;
      }).catch(async (error: BusinessError) => {
        Logger.error(TAG, 'LoginWithHuaweiID executeRequest error: ' + JSON.stringify(error));
        // 为了不阻塞模板体验，不做失败拦截
        await LoginUtil.queryUserInfo();
        return true;
      });
    } catch (e) {
      promptAction.showToast({ message: '华为账号登录异常，请稍后重试~' });
      return false;
    }
  }

  /**
   * 取消授权，每次申请关联手机号都要拉起面板
   */
  static cancelAuthorization() {
    const cancelRequest: authentication.CancelAuthorizationRequest =
      new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
    cancelRequest.state = util.generateRandomUUID();
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
        Logger.error(TAG, `Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
      })
    } catch (err) {
      Logger.error(TAG, `Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
    }
  }

  /**
   * 获取并设置用户信息
   */
  static async queryUserInfo() {
    try {
      const userInfo = await getUserInfo();
      // todo 获取用户信息
    } catch (e) {
      Logger.error(TAG, 'queryUserInfo error:' + JSON.stringify(e));
    }
  }
}