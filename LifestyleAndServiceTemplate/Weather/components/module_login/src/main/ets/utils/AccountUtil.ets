/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AppStorageV2 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { authentication, shippingAddress } from '@kit.AccountKit';
import { UserInfo } from '../model/UserInfo';
import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = '[AccountUtil]';

@ObservedV2
export class AccountUtil {
  static uiContext: UIContext

  // 华为收货地址
  public static chooseAddress() {
    try {
      shippingAddress.chooseAddress(AccountUtil.uiContext.getHostContext())
        .then((data: shippingAddress.AddressInfo) => {
          const userName: string = data.userName;
          const mobileNumber: string = data.mobileNumber;
          const countryCode: string = data.countryCode;
          const provinceName: string = data.provinceName;
          const cityName: string = data.cityName;
          const districtName: string = data.districtName;
          const streetName: string = data.streetName;
          const detailedAddress: string = data.detailedAddress;
          // 开发者处理获取的收货地址信息
        })
        .catch((error: BusinessError) => {
          AccountUtil._dealAllError(error);
        })
    } catch (error) {
      AccountUtil._dealAllError(error);
    }
  }

  // 获取匿名手机号
  public static getQuickLoginAnonymousPhone(): string {
    // 创建授权请求，并设置参数
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // 获取匿名手机号需传quickLoginAnonymousPhone这个scope，传参之前需要先申请“华为账号一键登录”权限，否则会返回1001502014错误码
    authRequest.scopes = ['quickLoginAnonymousPhone'];
    // 用于防跨站点请求伪造
    authRequest.state = util.generateRandomUUID();
    // 一键登录场景该参数必须设置为false
    authRequest.forceAuthorization = false;
    const controller = new authentication.AuthenticationController();
    try {
      controller.executeRequest(authRequest).then((response: authentication.AuthorizationWithHuaweiIDResponse) => {
        // 获取到UnionID、OpenID、匿名手机号
        const unionID = response.data?.unionID;
        const openID = response.data?.openID;
        const anonymousPhone = response.data?.extraInfo?.quickLoginAnonymousPhone as string;
        if (anonymousPhone) {
          hilog.info(0x0000, 'testTag', 'Succeeded in authentication.');
          const quickLoginAnonymousPhone: string = anonymousPhone;
          return quickLoginAnonymousPhone;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in authentication. AnonymousPhone is empty.');
        return anonymousPhone;
        // 未获取到匿名手机号需要跳转到应用自定义的登录页面
      }).catch((error: BusinessError) => {
        AccountUtil._dealAllError(error);
      })
    } catch (error) {
      AccountUtil._dealAllError(error);
    }
    return '';
  }

  private static _dealAllError(error: BusinessError): string {
    console.error(TAG, `Failed to login, errorCode: ${error.code}, errorMsg: ${error.message}`);
    return error.message;
  }
}

