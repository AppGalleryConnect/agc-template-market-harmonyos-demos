import fs from '@ohos.file.fs';
import { storageStatistics } from '@kit.CoreFileKit';

const TAG = '[CacheUtil]';

export class CacheUtil {
  //获取app缓存大小
  static getCache(): Promise<number> {
    try {
      return storageStatistics.getCurrentBundleStats().then((bundleStats: storageStatistics.BundleStats) => {
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
    fs.listFile(cacheDir).then((filenames) => {
      for (let i = 0; i < filenames.length; i++) {
        let dirPath = cacheDir + '/' + filenames[i];
        let isDirectory: boolean = false;
        try {
          isDirectory = fs.statSync(dirPath).isDirectory();
        } catch (e) {
        }

        if (isDirectory) {
          fs.rmdirSync(dirPath);
        } else {
          fs.unlink(dirPath).then(() => {
          }).catch((err: Error) => {
          });
        }
      }
    })
  }
}