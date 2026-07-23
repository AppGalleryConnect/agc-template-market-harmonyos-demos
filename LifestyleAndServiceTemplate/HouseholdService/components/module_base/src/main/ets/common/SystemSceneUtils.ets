import { abilityAccessCtrl, bundleManager, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { calendarManager } from '@kit.CalendarKit';
import { geoLocationManager } from '@kit.LocationKit';
import { site } from '@kit.MapKit';
import { paymentService } from '@kit.PaymentKit';
import { serviceNotification } from '@kit.PushKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { WindowUtil } from '../common/WindowUtils';

const TAG = '[SystemSceneUtils]';

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
      Logger.error(TAG, `Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    // 校验应用是否被授予权限
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to check access token. Code is ${err.code}, message is ${err.message}`);
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

    const isGrantedAppLo = await SystemSceneUtils.checkPermissionGrant(permissions[0]);

    if (isGrantedAppLo) {
      Logger.info(TAG, 'already granted location and approximate location permissions')
      return true;
    }
    // 向用户申请
    const atManager = abilityAccessCtrl.createAtManager();
    return atManager.requestPermissionsFromUser(WindowUtil.context, permissions)
      .then(async (result: PermissionRequestResult) => {
        Logger.info(TAG, 'apply location permission, result=' + JSON.stringify(result));
        if (result.authResults.every(v => v === 0)) {
          return true;
        }
        // 二次向用户申请
        if (SystemSceneUtils.isApplyLocPermAgain) {
          Logger.info(TAG, 'apply location permission again');
          const resp = await atManager.requestPermissionOnSetting(WindowUtil.context, permissions);
          return resp.every(v => v === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
        }
        SystemSceneUtils.isApplyLocPermAgain = true;
        return false;
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
        return false;
      });
  }

  /**
   * 获取当前所在城市位置
   * @returns
   */
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
      Logger.info(TAG, 'reverseGeocodeResult=' + JSON.stringify(reverseGeocodeResult));
      return reverseGeocodeResult.addressComponent.city?.cityName ?? '';
    } catch (e) {
      Logger.error(TAG, 'getCurrentCityInfo fail, error: ' + JSON.stringify(e));
      return '';
    }
  }

  /**
   * 调用华为支付
   * @returns
   */
  static requestPaymentPromise(ignoreRequestPayment: boolean): Promise<void> {
    if (ignoreRequestPayment) {
      return new Promise((resolve) => resolve());
    }
    // todo 补充订购信息
    const orderStr = '{}';
    return paymentService.requestPayment(WindowUtil.context, orderStr)
      .then(() => {
        Logger.info(TAG, 'succeeded in paying');
      })
      .catch((error: BusinessError) => {
        Logger.error(TAG, `failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
        promptAction.showToast({ message: '拉起支付失败' });
      });
  }

  /**
   * 发起订阅请求
   * @returns
   */
  public static async requestSubscribeNotification(entityIdStr: string):
    Promise<serviceNotification.RequestResult | null> {
    try {
      const entityIds: string[] = entityIdStr.split(',');
      const type: serviceNotification.SubscribeNotificationType =
        serviceNotification.SubscribeNotificationType.SUBSCRIBE_WITH_HUAWEI_ID;
      const res = await serviceNotification.requestSubscribeNotification(WindowUtil.context, entityIds, type);
      Logger.info(TAG, 'Succeeded in requesting serviceNotification: %{public}s' + JSON.stringify(res));
      return res!;
    } catch (err) {
      Logger.error(TAG, 'Failed to request serviceNotification: ' + JSON.stringify(err as BusinessError));
      return null;
    }
  }

  /**
   * 根据上下文获取日程管理器对象calendarMgr，用于对日历账户进行相关管理操作
   * @returns
   */
  public static async getCalendarMgr(isRequest: boolean = true) {
    const permissions: Permissions[] = [
      'ohos.permission.READ_CALENDAR',
      'ohos.permission.WRITE_CALENDAR',
    ];
    const mContext = WindowUtil.context;

    const isGrantedRead = await SystemSceneUtils.checkPermissionGrant(permissions[0]);
    const isGrantedWrite = await SystemSceneUtils.checkPermissionGrant(permissions[1]);

    if (isGrantedRead && isGrantedWrite) {
      Logger.info(TAG, 'already granted calendar permission')
      return calendarManager.getCalendarManager(mContext);
    }

    if (isRequest) {
      const atManager = abilityAccessCtrl.createAtManager();

      return atManager.requestPermissionsFromUser(mContext, permissions)
        .then(async (result: PermissionRequestResult) => {
          Logger.info(TAG, `get Permission success, result: ${JSON.stringify(result)}`);
          if (result.authResults.every(v => v === 0)) {
            return calendarManager.getCalendarManager(mContext);
          }
          // 首次拒绝后，二次弹窗申请
          if (result.dialogShownResults?.some(v => !v)) {
            try {
              const arr: Array<abilityAccessCtrl.GrantStatus> =
                await atManager.requestPermissionOnSetting(mContext, permissions);
              if (arr.every(v => v === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)) {
                return calendarManager.getCalendarManager(mContext);
              }
            } catch (error) {
              Logger.error(TAG, `request Permission failed, result: ${JSON.stringify(result)}`);
            }
            return null;
          }
          return null;
        })
        .catch((error: BusinessError) => {
          Logger.error(TAG, `request Permission from user failed, result: ${JSON.stringify(error)}`);
          return null;
        })
    }
    return null;
  }
}