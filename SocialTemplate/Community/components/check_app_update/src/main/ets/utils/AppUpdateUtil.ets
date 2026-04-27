import { bundleManager, common } from '@kit.AbilityKit';
import { updateManager } from '@kit.StoreKit';
import { buffer } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 检查是否存在新版本
 * @param context
 * @returns
 */
export function checkUpdate(context: common.UIAbilityContext): Promise<number> {
  return new Promise((resolve) => {
    try {
      updateManager.checkAppUpdate(context)
        .then((checkResult: updateManager.CheckUpdateResult) => {
          resolve(checkResult.updateAvailable);
        });
    } catch (err) {
      resolve(-1);
    }
  });
}

/**
 * 拉起更新应用弹窗
 * @param context
 */
export function showUpdateDialog(context: common.UIAbilityContext) {
  try {
    updateManager.showUpdateDialog(context)
      .then((resultCode: updateManager.ShowUpdateResultCode) => {
        hilog.info(0, 'TAG', 'Succeeded in showing UpdateDialog resultCode:' + resultCode);
      })
      .catch((error: BusinessError) => {
        hilog.error(0, 'TAG', `showUpdateDialog onError.code is ${error.code}, message is ${error.message}`);
      });
  } catch (error) {
    hilog.error(0, 'TAG', `showUpdateDialog onError.code is ${error.code}, message is ${error.message}`);
  }
}


/**
 * 检查更新并拉起更新弹窗
 * @param context
 */
export async function checkUpdateAndShowDialog(context: common.UIAbilityContext) {
  try {
    const checkResult = await updateManager.checkAppUpdate(context);
    if (checkResult.updateAvailable === updateManager.UpdateAvailableCode.LATER_VERSION_EXIST) {
      updateManager.showUpdateDialog(context);
    }
  } catch (error) {
  }
}


/**
 * 拉起应用市场
 * @param context
 */
export function pullUpAppGallery(context: common.UIAbilityContext) {
  try {
    bundleManager.getBundleInfoForSelf(0x00000001).then((data) => {
      // 固定链接 + 应用包名
      let link = getProtocolUrl('app_gallery_url') + data.appInfo.name;
      context.openLink(link);
    });
  } catch (err) {
  }
}

function getProtocolUrl(urlKey: string, fileName: string = 'data.json'): string {
  try {
    // Read files from /AppScope/resources/rawfile.
    const value: Uint8Array = getContext().resourceManager.getRawFileContentSync(fileName);
    // Return the link to the HUAWEI ID User Authentication Agreement.
    return JSON.parse(buffer.from(value.buffer).toString())[urlKey] as string;
  } catch (error) {
    return '';
  }
}


