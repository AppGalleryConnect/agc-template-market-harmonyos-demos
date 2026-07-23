import bundleManager from '@ohos.bundle.bundleManager';
import { SafeJson } from '../json/SafeJson';

/**
 * @description 获取应用包信息
 */
export class BundleInfoUtil {
  public static async getBundleInfo(): Promise<bundleManager.BundleInfo> {
    try {
      return bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
    } catch (e) {
      if (e instanceof Error) {
        throw e;
      } else {
        throw new Error(`GetBundleInfo failed: ${String(e)}`);
      }
    }
  }

  public static getBundleInfoSync(): bundleManager.BundleInfo {
    return bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
  }
}