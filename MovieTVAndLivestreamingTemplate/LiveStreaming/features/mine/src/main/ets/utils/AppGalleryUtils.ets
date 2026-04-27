import { updateManager } from '@kit.StoreKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '@agctemplate/utils';

const TAG = '[AppGalleryUtils]';

/**
 * 应用市场utils
 */
export class AppGalleryUtils {
  /**
   * 是否有更新版本
   * @param context
   * @returns
   */
  public static checkAppUpdate(context: common.UIAbilityContext): Promise<boolean> {
    try {
      return updateManager.checkAppUpdate(context)
        .then((checkResult: updateManager.CheckUpdateResult) => {
          Logger.info(TAG, 'Succeeded in checking Result updateAvailable:' + checkResult.updateAvailable);
          return checkResult.updateAvailable === updateManager.UpdateAvailableCode.LATER_VERSION_EXIST;
        }).catch((error: BusinessError) => {
          Logger.error(TAG, `checkAppUpdate onError.code is ${error.code}, message is ${error.message}`);
          return false;
        });
    } catch (error) {
      Logger.error(TAG, `checkAppUpdate onError.code is ${error.code}, message is ${error.message}`);
      return Promise.resolve(false);
    }
  }

  /**
   * 显示升级弹窗
   * @param context
   */
  public static showUpdateDialog(context: common.UIAbilityContext) {
    try {
      updateManager.showUpdateDialog(context)
        .then((resultCode: updateManager.ShowUpdateResultCode) => {
          Logger.info(TAG, 'Succeeded in showing UpdateDialog resultCode:' + resultCode);
        })
        .catch((error: BusinessError) => {
          Logger.error(TAG, `showUpdateDialog onError.code is ${error.code}, message is ${error.message}`);
        });
    } catch (error) {
      Logger.error(TAG, `showUpdateDialog onError.code is ${error.code}, message is ${error.message}`);
    }
  }
}