import fs from '@ohos.file.fs';
import { storageStatistics } from '@kit.CoreFileKit';
import { TCLogger } from '../basic/TCLogger';

const TAG = '[CacheUtil]';

export class CacheUtil {
  //获取app缓存大小
  static getCache(): Promise<number> {
    try {
      return storageStatistics.getCurrentBundleStats().then((bundleStats: storageStatistics.BundleStats) => {
        TCLogger.info(TAG, 'getCurrentBundleStats successfully:' + JSON.stringify(bundleStats));
        TCLogger.info(TAG, 'appSize :' + bundleStats.appSize);
        TCLogger.info(TAG, 'cacheSize :' + bundleStats.cacheSize);
        TCLogger.info(TAG, 'dataSize :' + bundleStats.dataSize);
        return bundleStats.cacheSize;
      });
    } catch (err) {
      return new Promise((resolve) => {
        resolve(0)
      });
    }
  }

  /**
   * 清除缓存
   * @param cacheDir
   */
  static clearCache() {
    const cacheDir = getContext().cacheDir;
    TCLogger.info(TAG, 'clear cache dir:' + cacheDir);
    fs.listFile(cacheDir).then((filenames) => {
      for (let i = 0; i < filenames.length; i++) {
        let dirPath = cacheDir + '/' + filenames[i];
        TCLogger.info(TAG, 'dir path:' + dirPath);
        let isDirectory: boolean = false;
        try {
          isDirectory = fs.statSync(dirPath).isDirectory();
        } catch (e) {
          TCLogger.error(TAG, 'statSync error:' + JSON.stringify(e));
        }

        if (isDirectory) {
          fs.rmdirSync(dirPath);
        } else {
          fs.unlink(dirPath).then(() => {
            TCLogger.info(TAG, 'remove file succeed');
          }).catch((err: Error) => {
            TCLogger.error(TAG, 'remove file failed with error message: ' + err.message);
          });
        }
      }
    })
  }
}