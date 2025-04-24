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
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { abilityAccessCtrl, PermissionRequestResult, Permissions, bundleManager, common } from '@kit.AbilityKit';
import { geoLocationManager } from '@kit.LocationKit';
import { site } from '@kit.MapKit';
import { paymentService } from '@kit.PaymentKit';
import { AppStorageMap, ErrorCode, CurAppInfo } from './Constant';
import { Logger } from './Logger';
import { PopViewUtils } from './PopViewUtils';
import {
  NoticeDialogBuilder,
  CommonDialogParams,
  ICommonDialogParams,
  ConfirmDialogBuilder,
} from '../uicomponent/NoticeDialog';
import { fullLoading, FullLoadingParam } from '../uicomponent/UILoading';

/**
 * 通用Utils
 */
export class CommonUtils {
  /**
   * 对象赋值
   * @param target
   * @param source
   * @returns
   */
  static assign(target: Object, ...source: Object[]) {
    for (let s of source) {
      for (let key of Object.keys(s)) {
        const value = Reflect.get(s, key) as Object;
        Reflect.set(target, key, value)
      }
    }
  }

  /**
   * 时间戳转换年月日xxxx-xx-xx
   * @param datetime
   */
  static formatDate(datetime?: number): string {
    if (!datetime) {
      return '';
    }
    const date = new Date(datetime);
    return `${date.getFullYear()}-${CommonUtils.padZero(date.getMonth() + 1)}-${CommonUtils.padZero(date.getDate())}`;
  }

  /**
   * 时间戳转换成年月日时分秒xxxx-xx-xx xx:xx:xx
   * @param datetime
   */
  static formatDateTime(datetime?: number): string {
    if (!datetime) {
      return '';
    }
    const date = new Date(datetime);
    return `${date.getFullYear()}-${CommonUtils.padZero(date.getMonth() +
      1)}-${CommonUtils.padZero(date.getDate())} ${CommonUtils.padZero(date.getHours())}:${CommonUtils.padZero(date.getMinutes())}:${CommonUtils.padZero(date.getSeconds())}`;
  }

  /**
   * 不足的补零
   * @param input
   * @returns
   */
  static padZero(input: number): string {
    return input.toString().padStart(2, '0');
  }

  /**
   * 金钱取整策略
   * @param cash
   */
  static handleCash(cash: number): string {
    try {
      // 整数直接返回
      if (cash % 1 === 0) {
        return cash.toString();
      }

      // 小数保留2位小数
      return cash.toFixed(2);
    } catch (e) {
      Logger.error('handleCash fail, error: ' + JSON.stringify(e));
      return '';
    }
  }

  /**
   * 处理图片url
   * @param url
   * @returns
   */
  static handleImgUrl(url: string): string {
    if (!url) {
      return '';
    }
    if (url.startsWith('https')) {
      return url;
    }

    // 处理mock图片资源
    if (url.startsWith('mockImage://')) {
      const resourceName = url.split('mockImage://')[1];
      const prefixUrl: string = 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/household-kiiye/mockImage%2F';
      return `${prefixUrl}${resourceName}`;
    }
    // resources下的资源通过resourceImage://xxx表达
    if (url.startsWith('resourceImage://')) {
      const resourceName = url.split('//')[1];
      try {
        const resource = getContext().resourceManager.getMediaBase64ByNameSync(resourceName);
        return resource;
      } catch (err) {
        Logger.error(`get image resource failed, ${err}, ${resourceName}`);
        return '';
      }
    }

    return `${CurAppInfo.BASE_URL}${url}`;
  };

  /**
   * 华为账号登录错误码处理
   * @param error
   */
  static showErrorMessage(error: BusinessError) {
    const userCanceled: number[] = [
      ErrorCode.SHIPPING_ADDRESS_USER_CANCELED, // The operation for obtaining the shipping address is canceled.
      ErrorCode.INVOICE_ASSISTANT_USER_CANCELED, // The operation for obtaining the invoice title is canceled.
      ErrorCode.AUTHENTICATION_USER_CANCELED, // Authorization revoking is performed.
      ErrorCode.EXTEND_SERVICE_USER_CANCELED,// The operation for obtaining the avatar is canceled.
    ];

    const networkError: number[] = [
      ErrorCode.SHIPPING_ADDRESS_NETWORK_ERROR,
      ErrorCode.AUTHENTICATION_NETWORK_ERROR, // A network exception occurs in the authorization API.
      ErrorCode.INVOICE_ASSISTANT_NETWORK_ERROR,
      ErrorCode.EXTEND_SERVICE_NETWORK_ERROR,// A network exception occurred in the API for obtaining the avatar.
    ];
    Logger.error(`Failed to obtain data. BusinessError errCode: ${error.code}, Message: ${error.message}`);

    if (networkError.includes(error.code)) {
      if (error.code === ErrorCode.INVOICE_ASSISTANT_NETWORK_ERROR) {
        return;
      }
      AlertDialog.show({
        message: $r('app.string.hwid_no_internet_connect'),
        offset: { dx: 0, dy: -12 },
        alignment: DialogAlignment.Center,
        autoCancel: false,
        confirm: {
          value: $r('app.string.hwid_text_button_known'),
          action: () => {
          },
        },
      });
    } else if (!userCanceled.includes(error.code)) {
      promptAction.showToast({ message: error.message, duration: 2000 });
    }
  }

  /**
   * 打开通用提示弹窗
   * @param title
   * @param btnLabel
   * @param confirm
   */
  static openNoticeDialog(param: ICommonDialogParams) {
    PopViewUtils.showPopView<CommonDialogParams>(wrapBuilder(NoticeDialogBuilder),
      new CommonDialogParams(param),
      { alignment: DialogAlignment.Center, autoCancel: true });
  };

  /**
   * 打开通用确认弹窗
   * @param param
   */
  static openConfirmDialog(param: ICommonDialogParams) {
    PopViewUtils.showPopView<CommonDialogParams>(wrapBuilder(ConfirmDialogBuilder),
      new CommonDialogParams(param),
      { alignment: DialogAlignment.Center, autoCancel: true });
  };

  /**
   * 打开loading
   * @param param
   */
  static showLoading() {
    PopViewUtils.showPopView<FullLoadingParam>(wrapBuilder(fullLoading),
      new FullLoadingParam(),
      { alignment: DialogAlignment.Center, autoCancel: false });
  };

  /**
   * 关闭loading弹窗
   */
  static hideLoading() {
    PopViewUtils.closePopView();
  }
}

/**
 * 系统Utils
 */
export class SystemSceneUtils {
  static isApplyLocPermAgain: boolean = false;

  /**
   * 检查用户是否授权
   * @param permission
   * @returns
   */
  static async checkPermissionGrant(permission: Permissions): Promise<boolean> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

    // 获取应用程序的accessTokenID
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      tokenId = bundleInfo.appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    // 校验应用是否被授予权限
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }

    return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }

  /**
   * 向用户申请位置权限
   * @returns
   */
  static async applyLocationPermission(): Promise<boolean> {
    const permissions: Permissions[] = [
      'ohos.permission.APPROXIMATELY_LOCATION',
    ];
    const mContext = AppStorage.get<Context>(AppStorageMap.CONTEXT);

    const isGrantedAppLo = await SystemSceneUtils.checkPermissionGrant(permissions[0]);

    if (isGrantedAppLo) {
      Logger.info('already granted location and approximate location permissions')
      return true;
    }

    // 向用户申请
    const atManager = abilityAccessCtrl.createAtManager();
    return atManager.requestPermissionsFromUser(mContext, permissions).then(async (result: PermissionRequestResult) => {
      if (result.authResults.every(v => v === 0)) {
        return true;
      }
      // 二次向用户申请
      if (SystemSceneUtils.isApplyLocPermAgain) {
        const resp = await atManager.requestPermissionOnSetting(mContext, permissions);
        return resp.every(v => v === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
      }
      SystemSceneUtils.isApplyLocPermAgain = true;
      return false;
    });
  }

  static async getCurrentCityInfo(): Promise<string> {
    try {
      const requestInfo: geoLocationManager.CurrentLocationRequest = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        timeoutMs: 1000,
      };
      const currentLocation = await geoLocationManager.getCurrentLocation(requestInfo);

      const reverseGeoCodeReq: site.ReverseGeocodeParams = {
        location: currentLocation,
        language: 'zh_CN',
      };
      const reverseGeocodeResult = await site.reverseGeocode(reverseGeoCodeReq);
      Logger.info('reverseGeocodeResult=' + JSON.stringify(reverseGeocodeResult));
      return reverseGeocodeResult.addressComponent.city?.cityName ?? '';
    } catch (e) {
      Logger.error('getCurrentCityInfo fail, error: ' + JSON.stringify(e));
      return '';
    }
  }

  /**
   * 调用华为支付
   * @returns
   */
  static requestPaymentPromise(ignoreRequestPayment: boolean, context: common.UIAbilityContext): Promise<void> {
    if (ignoreRequestPayment) {
      return new Promise((resolve) => resolve());
    }
    const orderStr = '{}';
    return paymentService.requestPayment(context, orderStr)
      .then(() => {
        Logger.info('succeeded in paying');
      })
      .catch((error: BusinessError) => {
        Logger.error(`failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
        promptAction.showToast({ message: '拉起支付失败' });
      });
  }
}
