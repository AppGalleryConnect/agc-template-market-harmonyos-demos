import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { storageStatistics } from '@kit.CoreFileKit';
import { Logger } from './Logger';
import { GlobalContext } from './GlobalContext';

const TAG = '[FileUtils]';

/**
 * 文件处理类
 */
export class FileUtils {
  /**
   * 写入沙箱
   * @param uri
   * @returns
   */
  static handleUri(uri: string) {
    if (!uri) {
      return '';
    }
    let file: fs.File | null = null;
    try {
      file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      const newPath: string = GlobalContext.getContext().filesDir + `/${util.generateRandomUUID(false)}.png`;
      fs.copyFileSync(file.fd, newPath);
      return 'file://' + newPath;
    } catch (error) {
      Logger.error(TAG, 'fs.copyFileSync error: ' + JSON.stringify(error));
      return '';
    } finally {
      if (file) {
        fs.closeSync(file);
      }
    }
  }

  /**
   * 沙箱图片转换成base64
   * @param imgUri
   * @returns
   */
  static sandboxToBase64(imgUri: string): string {
    let file: fs.File | null = null;
    try {
      file = fs.openSync(imgUri);
      let buffer: ArrayBuffer = new ArrayBuffer(fs.statSync(file.fd).size);
      fs.readSync(file.fd, buffer);
      let unit = new Uint8Array(buffer);
      let base64 = new util.Base64Helper();
      let base64string = base64.encodeToStringSync(unit, util.Type.MIME);
      return `data:image/jpeg;base64,${base64string}`;
    } finally {
      if (file) {
        fs.closeSync(file);
      }
    }
  }

  /**
   * 读取缓存大小，单位Byte
   */
  static getCache() {
    try {
      return storageStatistics.getCurrentBundleStats().then((bundleStats: storageStatistics.BundleStats) => {
        Logger.info(TAG, 'getCurrentBundleStats successfully:' + JSON.stringify(bundleStats));
        Logger.info(TAG, 'appSize :' + bundleStats.appSize);
        Logger.info(TAG, 'cacheSize :' + bundleStats.cacheSize);
        Logger.info(TAG, 'dataSize :' + bundleStats.dataSize);
        return bundleStats.cacheSize;
      });
    } catch (error) {
      Logger.error(TAG, 'getCache error: ' + JSON.stringify(error));
      return Promise.resolve(0);
    }
  }

  /**
   * 清除缓存
   * @param cacheDir
   */
  static clearCache() {
    const cacheDir = GlobalContext.getContext().cacheDir;
    Logger.info(TAG, 'clear cache dir:' + cacheDir);
    fs.listFile(cacheDir).then((filenames) => {
      for (let i = 0; i < filenames.length; i++) {
        let dirPath = cacheDir + '/' + filenames[i];
        Logger.info(TAG, 'dir path:' + dirPath);
        let isDirectory: boolean = false;
        try {
          isDirectory = fs.statSync(dirPath).isDirectory();
        } catch (e) {
          Logger.error(TAG, 'statSync error:' + JSON.stringify(e));
        }

        if (isDirectory) {
          fs.rmdirSync(dirPath);
        } else {
          fs.unlink(dirPath).then(() => {
            Logger.info(TAG, 'remove file succeed');
          }).catch((err: Error) => {
            Logger.error(TAG, 'remove file failed with error message: ' + err.message);
          });
        }
      }
    })
  }
}