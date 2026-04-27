import fs from '@ohos.file.fs';
import { storageStatistics } from '@kit.CoreFileKit';
import { TCLogger } from '../basic/TCLogger';

const TAG = '[CacheUtil]';

/**
 * @fileType: common
 * @zhName: 缓存工具类
 */
export class CacheUtil {
  //获取app缓存大小
  static getCache(): Promise<number> {
    return new Promise((resolve, reject) => {
      try {
        storageStatistics.getCurrentBundleStats().then((bundleStats: storageStatistics.BundleStats) => {
          TCLogger.info(TAG, 'getCurrentBundleStats successfully:' + JSON.stringify(bundleStats));
          TCLogger.info(TAG, 'appSize :' + bundleStats.appSize);
          TCLogger.info(TAG, 'cacheSize :' + bundleStats.cacheSize);
          TCLogger.info(TAG, 'dataSize :' + bundleStats.dataSize);
          resolve(bundleStats.cacheSize)
        });
      } catch (err) {
        reject(err)
      }
    })
  }

  /**
   * 计算文件大小
   */
  public static formatCacheFileSize(fileS: number): string {
    const wrongSize = '0B';
    if (fileS === 0) {
      return wrongSize;
    } else if (fileS < 1024) {
      return `${fileS.toFixed(1)}B`;
    } else if (fileS < 1048576) {
      const sizeInMB = fileS / 1024;
      return `${sizeInMB.toFixed(1)}KB`;
    } else if (fileS < 1073741824) {
      const sizeInMB = fileS / 1048576;
      return `${sizeInMB.toFixed(1)}MB`;
    } else {
      const sizeInGB = fileS / 1073741824;
      return `${sizeInGB.toFixed(1)}GB`;
    }
  }

  /**
   * 计算文件传输速度
   */
  public static formatCacheFileSpeed(fileS: number, second: number): string {
    const speed: number = fileS / second;
    const wrongSize = '0B/s';
    if (speed === 0) {
      return wrongSize;
    } else if (speed < 1024) {
      return `${speed.toFixed(1)}B/s`;
    } else if (speed < 1048576) {
      const sizeInMB = speed / 1024;
      return `${sizeInMB.toFixed(1)}KB/s`;
    } else if (speed < 1073741824) {
      const sizeInMB = speed / 1048576;
      return `${sizeInMB.toFixed(1)}MB/s`;
    } else {
      const sizeInGB = speed / 1073741824;
      return `${sizeInGB.toFixed(1)}GB/s`;
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
