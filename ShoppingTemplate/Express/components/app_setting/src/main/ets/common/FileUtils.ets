import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { storageStatistics } from '@kit.CoreFileKit';
import { application, common, Context, contextConstant } from '@kit.AbilityKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';

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
  static handleUri(context: Context ,uri: string) {
    if (!uri) {
      return '';
    }
    let file: fs.File | null = null;
    try {
      file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      const newPath: string = context.cacheDir + `/${util.generateRandomUUID(false)}.png`;
      fs.copyFileSync(file.fd, newPath);
      return 'file://' + newPath;
    } catch (error) {
      Logger.error(TAG, 'fs.copyFileSync error: ' + JSON.stringify(error));
      return '';
    } finally {
      if (file) {
        try {
          fs.closeSync(file);
        } catch (error) {
          Logger.error(TAG, 'fs.closeSync error: ' + JSON.stringify(error));
        }
      }
    }
  }

  /**
   * 读取缓存大小，单位Byte
   */
  static getCache() {
    return storageStatistics.getCurrentBundleStats().then((bundleStats: storageStatistics.BundleStats) => {
      Logger.info(TAG, 'getCurrentBundleStats successfully:' + JSON.stringify(bundleStats));
      return bundleStats.cacheSize;
    }).catch((err: Error) => {
      Logger.error(TAG, 'get current bundle stats error: ' + JSON.stringify(err));
      return 0;
    });
  }

  /**
   * 获取所有缓存路径
   * @param context
   * @returns
   */
  static async getPaths(context: Context): Promise<string[]> {
    let paths: string[] = [];
    try {
      let moduleContext: common.Context;
      moduleContext = await application.createModuleContext(context, 'entry');
      // 缓存路径 /data/storage/el2/base/cache
      Logger.info(TAG, `moduleContext + el2: ${moduleContext.cacheDir}`);
      // 缓存路径 /data/storage/el2/base/haps/entry/cache
      Logger.info(TAG, `UIAbilityContext + el2: ${context.cacheDir}`);
      paths.push(moduleContext.cacheDir);
      paths.push(context.cacheDir);

      // 缓存路径 /data/storage/el1/base/cache
      moduleContext.area = contextConstant.AreaMode.EL1;
      Logger.info(TAG, `moduleContext + el1: ${moduleContext.cacheDir}`);
      // 缓存路径 /data/storage/el1/base/haps/entry/cache
      context.area = contextConstant.AreaMode.EL1;
      Logger.info(TAG, `UIAbilityContext + el1: ${context.cacheDir}`);
      paths.push(moduleContext.cacheDir);
      paths.push(context.cacheDir);

      // 恢复默认的安全级别
      context.area = contextConstant.AreaMode.EL2;
      return paths;
    } catch (e) {
      Logger.error(TAG, `getPaths fail. Code: ${e.code}, message: ${e.message}`);
      return paths;
    }
  }

  /**
   * 删除某个缓存目录下的文件
   * @param cacheDir
   */
  static deleteFile(cacheDir: string) {
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
          try {
            fs.rmdirSync(dirPath);
          } catch (error) {
            Logger.error(TAG, 'rmdir sync failed with error message: ' + error.message);
          }
        } else {
          fs.unlink(dirPath).then(() => {
            Logger.info(TAG, 'remove file succeed');
          }).catch((err: Error) => {
            Logger.error(TAG, 'remove file failed with error message: ' + err.message);
          });
        }
      }
    }).catch((err: Error) => {
      Logger.error(TAG, 'list file failed with error message: ' + err.message);
    });
  }

  /**
   * 清除缓存
   * @param cacheDir
   */
  static clearCache(context: Context) {
    FileUtils.getPaths(context).then((paths) => {
      paths.forEach((cacheDir) => {
        FileUtils.deleteFile(cacheDir);
      })
    })
  }
}