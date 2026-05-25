import { serviceNotification } from '@kit.PushKit';
import { abilityAccessCtrl, PermissionRequestResult, Permissions, bundleManager } from '@kit.AbilityKit';
import { calendarManager } from '@kit.CalendarKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from 'external_interactions';

const TAG = '[SystemSceneUtils]';

/**
 * 系统Utils
 */
export class SystemSceneUtils {
  private static uiContext: UIContext;
  private static context: Context | undefined;
  /**
   * 初始化context
   */
  public static init(uiContext: UIContext) {
    if (SystemSceneUtils.uiContext) {
      return;
    }
    SystemSceneUtils.uiContext = uiContext;
    SystemSceneUtils.context = SystemSceneUtils.uiContext.getHostContext();
  }

  /**
   * 检查用户是否授权
   * @param permission
   * @returns
   */
  public static async checkPermissionGrant(permission: Permissions): Promise<boolean> {
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
      Logger.error(TAG, `Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`)
    }

    // 校验应用是否被授予权限
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to check access token. Code is ${err.code}, message is ${err.message}`)
    }

    return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }

  /**
   * 根据上下文获取日程管理器对象calendarMgr，用于对日历账户进行相关管理操作
   * @returns
   */
  public static async getCalendarMgr() {
    const permissions: Permissions[] = [
      'ohos.permission.READ_CALENDAR',
      'ohos.permission.WRITE_CALENDAR',
    ];
    const mContext = SystemSceneUtils.context;

    const isGrantedRead = await SystemSceneUtils.checkPermissionGrant(permissions[0]);
    const isGrantedWrite = await SystemSceneUtils.checkPermissionGrant(permissions[1]);

    if (isGrantedRead && isGrantedWrite) {
      Logger.info(TAG, 'already granted calendar permission')
      return calendarManager.getCalendarManager(mContext);
    }

    const atManager = abilityAccessCtrl.createAtManager();

    try {
      return atManager.requestPermissionsFromUser(mContext, permissions).then(
        async (result: PermissionRequestResult) => {
          Logger.info(TAG, `get Permission success, result: ${JSON.stringify(result)}`)
          if (result.authResults.every(v => v === 0)) {
            return calendarManager.getCalendarManager(mContext);
          }
          // 首次拒绝后，二次弹窗申请
          if (result.dialogShownResults?.some(v => !v)) {
            const arr: Array<abilityAccessCtrl.GrantStatus> =
              await atManager.requestPermissionOnSetting(mContext, permissions);
            if (arr.every(v => v === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)) {
              return calendarManager.getCalendarManager(mContext);
            }
            return null;
          }
          return null;
        })
    } catch (e) {
      Logger.error(TAG, `get Calendar Permission failed, error: ${JSON.stringify(e)}`)
      return null;
    }
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
      const res = await serviceNotification.requestSubscribeNotification(SystemSceneUtils.context, entityIds, type);
      Logger.info(TAG, `Succeeded in requesting serviceNotification: ${JSON.stringify(res)}`);
      return res!;
    } catch (err) {
      Logger.error(TAG, `Failed to request serviceNotification: ${JSON.stringify(err as BusinessError)}`);
      return null;
    }
  }
}