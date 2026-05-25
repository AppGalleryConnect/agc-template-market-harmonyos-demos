import { common, contextConstant } from '@kit.AbilityKit';
import { fileUri, fileIo as fs } from '@kit.CoreFileKit';
import { NormalizedError } from './NormalizedError';
import { BytesUtils } from './BytesUtils';
import { Logger } from 'external_interactions';

const TAG: string = '[FileUtils]';

export class FileUtils {

  private static context: common.UIAbilityContext | undefined = undefined;

  /**
   * FileUtils 需初始化后使用。
   */
  public static init(context: common.UIAbilityContext): void {
    FileUtils.context = context;
  }
  /**
   * 将文件保存至应用沙箱的 Cache 目录。
   *
   * @param srcUriOrPath - 源文件 URI 或路径；
   * @param area         - 区域模式；
   * @returns 所存放文件的资源标志符；
   */
  public static async saveFileToCache(
    srcUriOrPath: string,
    area: contextConstant.AreaMode = contextConstant.AreaMode.EL2
  ): Promise<fileUri.FileUri> {
    if (!FileUtils.context) {
      throw new Error('FileUtils has not been initialized.');
    }
    FileUtils.context.area = area;
    let destFile: fs.File | null = null;
    let srcFile: fs.File | null = null;
    try {
      const srcObj: fileUri.FileUri = new fileUri.FileUri(srcUriOrPath);
      const srcPath: string = srcObj.path;
      if (!fs.accessSync(srcPath, fs.AccessModeType.EXIST)) {
        throw new Error(`Source file does not exist: ${srcPath}`);
      }
      if (!fs.accessSync(srcPath, fs.AccessModeType.READ)) {
        throw new Error(`Source file is not readable: ${srcPath}`);
      }
      const destPath: string = FileUtils.context.cacheDir + '/' + srcObj.name;
      if (srcPath === destPath) {
        return new fileUri.FileUri(destPath);
      }
      destFile = fs.openSync(destPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC);
      srcFile = fs.openSync(srcPath, fs.OpenMode.READ_ONLY);
      fs.copyFileSync(srcFile.fd, destFile.fd);
      return new fileUri.FileUri(destPath);
    } catch (e) {
      NormalizedError.logAndThrow(e);
    } finally {
      FileUtils.safeClose(destFile);
      FileUtils.safeClose(srcFile);
    }
  }
  /**
   * 将传入对象序列化为 JSON 文件形式存放至 Cache 目录。
   *
   * @param obj       - 任意可序列化对象；
   * @param filename  - 目标文件名；
   * @param area      - 文件区域模式；
   * @param uiContext - UI 上下文实例；
   * @returns 所存放文件的资源标志符；
   */
  public static async saveJsonToCache(
    obj: ESObject,
    filename: string,
    area: contextConstant.AreaMode = contextConstant.AreaMode.EL2
  ): Promise<fileUri.FileUri> {
    if (!FileUtils.context) {
      throw new Error('FileUtils has not been initialized.');
    }
    FileUtils.context.area = area;
    let destFile: fs.File | null = null;
    try {
      const destPath: string = FileUtils.context.cacheDir + '/' + filename;
      const jsonStr: string = JSON.stringify(obj, null, 2);
      destFile = fs.openSync(destPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC);
      fs.writeSync(destFile.fd, jsonStr);
      return new fileUri.FileUri(destPath);
    } catch (e) {
      NormalizedError.logAndThrow(e);
    } finally {
      FileUtils.safeClose(destFile);
    }
  }
  /**
   * 尝试从 Cache 目录读取指定文件并采用 JSON 反序列化。
   *
   * @param filename - 目标文件名；
   * @param area     - 文件区域模式；
   * @returns 反序列化得到的对象；
   */
  public static async readJsonFromCache(
    filename: string,
    area: contextConstant.AreaMode = contextConstant.AreaMode.EL2,
  ): Promise<ESObject> {
    if (!FileUtils.context) {
      throw new Error('FileUtils has not been initialized.');
    }
    FileUtils.context.area = area;
    let file: fs.File | null = null;
    try {
      const filePath: string = FileUtils.context.cacheDir + '/' + filename;
      if (!fs.accessSync(filePath, fs.AccessModeType.EXIST)) {
        throw new Error(`Source file does not exist: ${filePath}`);
      }
      if (!fs.accessSync(filePath, fs.AccessModeType.READ)) {
        throw new Error(`Source file is not readable: ${filePath}`);
      }
      file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      const stat: fs.Stat = fs.statSync(filePath);
      const buffer: ArrayBuffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      return JSON.parse(BytesUtils.decodeUtf8(new Uint8Array(buffer)));
    } catch (e) {
      NormalizedError.logAndThrow(e);
    } finally {
      FileUtils.safeClose(file);
    }
  }
  /**
   * 安全关闭文件 (吞噬异常)。
   */
  private static safeClose(file: fs.File | null): void {
    if (file) {
      try {
        fs.closeSync(file);
      } catch (e) {
        Logger.error(TAG, `${JSON.stringify(NormalizedError.from(e).toLogLine())}`);
      }
    }
  }
}
