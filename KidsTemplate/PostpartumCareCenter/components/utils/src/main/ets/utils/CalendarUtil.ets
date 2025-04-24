import { abilityAccessCtrl, bundleManager, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { calendarManager } from '@kit.CalendarKit';
import { Logger } from './Logger';

const TAG = '[testTag][CalendarUtil]';

enum PermissionStatus {
  GRANTED = 0,
  DENIED = -1,
  UNKNOWN = 2,
}

export class CalendarUtil {
  private static _atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  private static _context: Context;

  public static requestCalendarPermissions(permissions: Permissions[], callback?: Callback<void>) {
    if (!CalendarUtil._context) {
      CalendarUtil._context = getContext() as common.UIAbilityContext;
    }
    // 向用户申请系统日历读写授权
    try {
      CalendarUtil._atManager.requestPermissionsFromUser(CalendarUtil._context, permissions)
        .then((result: PermissionRequestResult) => {
          Logger.info(TAG, `get permission success, result: ${JSON.stringify(result)}`);
          // 存在权限没有被授予
          if (result.authResults[0] === PermissionStatus.DENIED ||
            result.authResults[1] === PermissionStatus.DENIED) {
            // 用户看过对话弹框，并且用户拒绝了权限
            if (result.dialogShownResults && (result.dialogShownResults[0] || result.dialogShownResults[1])) {
              return;
              // 用户没有看到权限对话弹框，则打开权限设置
            } else {
              CalendarUtil._requestPermissionsOnSetting(permissions, callback);
              return;
            }
            // 不存在被拒绝的权限
          } else {
            if (result.authResults[0] === PermissionStatus.GRANTED &&
              result.authResults[1] === PermissionStatus.GRANTED) {
              callback?.();
            } else {
              return;
            }
          }
        });
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `RequestPermissions failed. Code is ${err.code}, message is ${err.message}`);
    }
  }

  // 是否已获取了所有权限
  public static hasAllPermissions(permissions: Permissions[], callbackOfTrue?: Callback<void>,
    callbackOfFalse?: Callback<void>) {
    // 判断是否已经获取了所有权限
    let hasPermission = true;
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      Logger.info(TAG, 'getBundleInfoForSelfSync successfully: %{public}s', JSON.stringify(bundleInfo));
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG,
        `Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    if (!CalendarUtil._context) {
      CalendarUtil._context = getContext() as common.UIAbilityContext;
    }

    try {
      for (let permission of permissions) {
        if (CalendarUtil._atManager.checkAccessTokenSync(tokenId, permission) !==
        abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
          hasPermission = false;
        }
      }
      if (hasPermission) {
        callbackOfTrue?.();
      } else {
        callbackOfFalse?.();
      }
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }
  }

  public static addCalendarEvent(event: calendarManager.Event, callback: AsyncCallback<number>) {
    let calendar: calendarManager.Calendar | undefined = undefined;
    if (!CalendarUtil._context) {
      CalendarUtil._context = getContext() as common.UIAbilityContext;
    }
    // 通过getCalendarManager获取管理日历对象，使用getCalendar获取日历对象，然后使用addEvent创建日程
    calendarManager.getCalendarManager(CalendarUtil._context).getCalendar().then((data: calendarManager.Calendar) => {
      Logger.info(TAG, `Succeeded in getting calendar, data -> ${JSON.stringify(data)}`);
      calendar = data;
      calendar.addEvent(event, (err: BusinessError, data: number): void => {
        if (err) {
          Logger.error(TAG, `Failed to addEvent. Code: ${err.code}, message: ${err.message}`);
        } else {
          Logger.info(TAG, `Succeeded in adding event, id -> ${data}`);
        }
        callback(err, data);
      });
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to get calendar. Code: ${err.code}, message: ${err.message}`);
    });
  }

  // 用户首次拒绝后二次申请授权
  private static _requestPermissionsOnSetting(permissions: Permissions[], callback?: Callback<void>) {
    CalendarUtil._atManager.requestPermissionOnSetting(CalendarUtil._context, permissions)
      .then((data: abilityAccessCtrl.GrantStatus[]) => {
        if (data[0] === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED &&
          data[1] === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
          return;
        } else {
          callback?.();
        }
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG,
          `Failed to request permissions on setting from user. Code is ${err.code}, message is ${err.message}`);
      });
  }
}