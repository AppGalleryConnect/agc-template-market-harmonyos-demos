/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { serviceNotification } from '@kit.PushKit';
import { abilityAccessCtrl, PermissionRequestResult, Permissions, bundleManager, common, Want } from '@kit.AbilityKit';
import { calendarManager } from '@kit.CalendarKit';
import { map, mapCommon } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import { AppStorageMap, ErrorCode, CurAppInfo, BASE_URL } from './Constant';
import { Logger } from './Logger';
import { PopViewUtils } from './PopViewUtils';
import { NoticeDialog, NoticeDialogParams } from '../uicomponent/NoticeDialog';

/**
 * 通用Utils
 */
export class CommonUtils {
  /**
   * 时间戳转换成xxxx-xx-xx
   * @param datetime
   */
  static formatDate(datetime?: number) {
    if (!datetime) {
      return '';
    }
    const date = new Date(datetime);
    return `${date.getFullYear()}-${CommonUtils.padZero(date.getMonth() + 1)}-${CommonUtils.padZero(date.getDate())}`;
  }

  /**
   * 时间戳转换成xxxx-xx-xx xx:xx:xx
   * @param datetime
   */
  static formatDateTime(datetime?: number) {
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
  static padZero(input: number) {
    return input.toString().padStart(2, '0');
  }

  /**
   * 金钱取整策略
   * @param cash
   */
  static handleCash(cash: number) {
    // 整数直接返回
    if (cash % 1 === 0) {
      return cash;
    }

    // 小数保留2位小数
    return cash.toFixed(2);
  }

  /**
   * 处理图片url
   * @param url
   * @returns
   */
  static handleImgUrl(url: string) {
    if (!url) {
      return '';
    }
    if (url.startsWith('https')) {
      return url;
    }

    // 处理mock图片资源
    if (url.startsWith('mockImage://')) {
      const resourceName = url.split('//')[1];
      try {
        const resource = getContext().resourceManager.getMediaBase64ByNameSync(resourceName);
        return resource;
      } catch (err) {
        console.error(`get image resource failed, ${err}, ${resourceName}`);
        return '';
      }
    }

    return `${BASE_URL}${url}`;
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
      // A network exception occurred in the API for obtaining the shipping address.
      ErrorCode.AUTHENTICATION_NETWORK_ERROR, // A network exception occurs in the authorization API.
      ErrorCode.INVOICE_ASSISTANT_NETWORK_ERROR,
      // A network exception occurred in the API for obtaining the invoice title.
      ErrorCode.EXTEND_SERVICE_NETWORK_ERROR,// A network exception occurred in the API for obtaining the avatar.
    ];
    Logger.error(`Failed to obtain data. BusinessError errCode: ${error.code}, Message: ${error.message}`);

    // Network exception.
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
      // Other exceptions not caused by user cancellations.
      promptAction.showToast({ message: error.message, duration: 2000 });
    }
  }

  /**
   * 打开普通提示弹窗
   * @param title
   * @param btnLabel
   * @param confirm
   */
  static openNoticeDialog(title: ResourceStr, btnLabel?: ResourceStr, confirm?: () => void) {
    PopViewUtils.showPopView<NoticeDialogParams>(wrapBuilder(NoticeDialog),
      new NoticeDialogParams(title, btnLabel, confirm),
      { alignment: DialogAlignment.Center });
  };
}


/**
 * 系统Utils
 */
export class SystemSceneUtils {
  /**
   * 跳转到华为地图
   * @param address
   * @param coords
   */
  static jumpPetalMap(context: common.UIAbilityContext, address: string, coords: string[]) {
    if (coords.length < 2) {
      return;
    }
    let petalMapWant: Want = {
      bundleName: 'com.huawei.hmos.maps.app',
      uri: 'maps://routes',
      parameters: {
        // 接入方业务名或包名，Link请求来源
        linkSource: CurAppInfo.BUNDLE_NAME,
        // 终点纬度
        destinationLatitude: coords[1],
        // 终点经度
        destinationLongitude: coords[0],
        // 终点名称
        destinationName: address,
      },
    }

    context?.startAbility(petalMapWant);
  }

  /**
   * 计算距离
   * @param coords 经度.纬度
   * @returns
   */
  static async getDistance(coordsStr: string) {
    let requestInfo: geoLocationManager.CurrentLocationRequest = {
      priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
      timeoutMs: 1000,
    };
    try {
      const fromLocation = await geoLocationManager.getCurrentLocation(requestInfo);
      let fromLatLng: mapCommon.LatLng = {
        latitude: fromLocation.latitude,
        longitude: fromLocation.longitude,
      };
      Logger.info('fromLocation = [' + fromLocation.latitude + ', ' + fromLocation.longitude + ']');

      const coords = coordsStr.split(',');
      let toLatLng: mapCommon.LatLng = {
        longitude: Number(coords[0]),
        latitude: Number(coords[1]),
      };
      Logger.info('toLatLng = [' + toLatLng.latitude + ', ' + toLatLng.longitude + ']');

      const distance = map.calculateDistance(fromLatLng, toLatLng);
      Logger.info('distance=' + distance);

      if (isNaN(distance)) {
        return '0m';
      }
      if (distance < 1000) {
        return `${distance}m`;
      } else {
        return `${(distance / 1000).toFixed(1)}km`;
      }
    } catch (err) {
      Logger.error('getDistance errCode:' + (err as BusinessError).code + ',errMessage:' +
      (err as BusinessError).message);
      return '0m';
    }
  }

  /**
   * 向用户申请位置权限
   * @returns
   */
  static async applyLocationPermission(): Promise<boolean> {
    const permissions: Permissions[] = [
      'ohos.permission.LOCATION',
      'ohos.permission.APPROXIMATELY_LOCATION',
    ];
    const mContext = AppStorage.get<Context>(AppStorageMap.CONTEXT);

    const isGrantedLo = await SystemSceneUtils.checkPermissionGrant(permissions[0]);
    const isGrantedAppLo = await SystemSceneUtils.checkPermissionGrant(permissions[1]);

    if (isGrantedLo && isGrantedAppLo) {
      Logger.info('already granted location and approximate location permissions')
      return true;
    }

    const atManager = abilityAccessCtrl.createAtManager();
    return atManager.requestPermissionsFromUser(mContext, permissions).then((result: PermissionRequestResult) => {
      if (result.authResults.every(v => v === 0)) {
        return true;
      }
      return false;
    });
  }

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
   * 根据上下文获取日程管理器对象calendarMgr，用于对日历账户进行相关管理操作
   * @returns
   */
  static async getCalendarMgr() {
    const permissions: Permissions[] = [
      'ohos.permission.READ_CALENDAR',
      'ohos.permission.WRITE_CALENDAR',
    ];
    const mContext = AppStorage.get<Context>(AppStorageMap.CONTEXT);

    const isGrantedRead = await SystemSceneUtils.checkPermissionGrant(permissions[0]);
    const isGrantedWrite = await SystemSceneUtils.checkPermissionGrant(permissions[1]);

    if (isGrantedRead && isGrantedWrite) {
      Logger.info('already granted calendar permission')
      return calendarManager.getCalendarManager(mContext);
    }

    const atManager = abilityAccessCtrl.createAtManager();

    return atManager.requestPermissionsFromUser(mContext, permissions).then(async (result: PermissionRequestResult) => {
      Logger.info(`get Permission success, result: ${JSON.stringify(result)}`);
      if (result.authResults.every(v => v === 0)) {
        return calendarManager.getCalendarManager(mContext);
      }
      // 首次拒绝后，二次弹窗申请
      if (result.dialogShownResults?.some(v =>!v)) {
        const arr: Array<abilityAccessCtrl.GrantStatus> =
          await atManager.requestPermissionOnSetting(mContext, permissions);
        if (arr.every(v => v === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)) {
          return calendarManager.getCalendarManager(mContext);
        }
        return null;
      }

      return null;
    })
  }

  /**
   * 发起订阅请求
   * @returns
   */
  static async requestSubscribeNotification(): Promise<serviceNotification.RequestResult | null> {
    try {
      const context = AppStorage.get<Context>(AppStorageMap.CONTEXT);
      // entityIds请替换为待订阅的模板ID
      let entityIds: string[] = [CurAppInfo.PUSH_TEMPLATE_ID];
      let type: serviceNotification.SubscribeNotificationType =
        serviceNotification.SubscribeNotificationType.SUBSCRIBE_WITH_HUAWEI_ID;
      const res = await serviceNotification.requestSubscribeNotification(context, entityIds, type);
      Logger.info('Succeeded in requesting serviceNotification: %{public}s' + JSON.stringify(res));
      return res!;
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      Logger.error(0x0000, 'testTag', 'Failed to request serviceNotification: %{public}d %{public}s', e.code,
        e.message);
      return null;
    }
  }
}
