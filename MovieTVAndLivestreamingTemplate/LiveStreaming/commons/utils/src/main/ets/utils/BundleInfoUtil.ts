import bundleManager from '@ohos.bundle.bundleManager';

/**
 * @description 获取应用包信息
 */
export class BundleInfoUtil {
  public static async getBundleInfo(): Promise<bundleManager.BundleInfo | undefined> {
    try {
      return bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
    } catch (e) {
      return undefined
    }
  }

  public static getBundleInfoSync(): bundleManager.BundleInfo {
    return bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
  }
}