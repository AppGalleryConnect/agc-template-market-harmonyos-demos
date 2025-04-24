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
import { promptAction } from '@kit.ArkUI';
import { Logger } from '../common/Logger';
import {
  getUserInfo,
  loginWithHuaweiID,
} from '../http/ApiManage';
import { AppStorageMap } from '../common/Constant';
import { AppStorageBank } from '../model/ObserveModel';

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
        Logger.info(`loginResponse=${JSON.stringify(loginWithHuaweiIDCredential)}`);

        const resp = await loginWithHuaweiID({
          clientId: 'xxx',
          code: loginWithHuaweiIDCredential?.authorizationCode || '',
          idToken: loginWithHuaweiIDCredential?.idToken || '',
          openId: loginWithHuaweiIDCredential?.openID || '',
          unionId: loginWithHuaweiIDCredential?.unionID || '',
        });
        Logger.info('loginWithHuaweiID success, token:' + resp.token);
        AppStorage.setOrCreate(AppStorageMap.TOKEN, resp.token);
        await LoginUtil.queryUserInfo();
        return true;
      }).catch((error: BusinessError) => {
        Logger.error('LoginWithHuaweiID executeRequest error: ' + JSON.stringify(error));
        if (error?.code === authentication.AuthenticationErrorCode.ACCOUNT_NOT_LOGGED_IN) {
          promptAction.showToast({ message: $r('app.string.need_login_in_setting') });
        } else {
          promptAction.showToast({ message: $r('app.string.login_in_error') });
        }
        return false;
      });
    } catch (e) {
      promptAction.showToast({ message: $r('app.string.login_in_error') });
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
          Logger.error('Failed to cancel. The state is different');
          return;
        }
      }).catch((err: BusinessError) => {
        Logger.error(`Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
      })
    } catch (err) {
      Logger.error(`Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
    }
  }

  /**
   * 获取并设置用户信息
   */
  static async queryUserInfo() {
    try {
      const userInfo = await getUserInfo();
      AppStorageBank.updateUserInfo(userInfo);
    } catch (e) {
      Logger.error('queryUserInfo error:' + JSON.stringify(e));
    }
  }
}