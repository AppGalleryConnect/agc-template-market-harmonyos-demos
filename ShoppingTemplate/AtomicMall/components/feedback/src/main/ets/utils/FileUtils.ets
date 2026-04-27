import { common, contextConstant } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { UIContext } from '@kit.ArkUI';
import { fileUri, fileIo as fs } from '@kit.CoreFileKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { LOG_TAG } from '../common/Config';
import { StandardCharsets } from '../common/CustomTypes';

export class FileUtils {
  private static _context: common.UIAbilityContext;

  public static setUIAbilityContext(uiContext: UIContext) {
    const context: common.Context | undefined = uiContext.getHostContext();
    if (context) {
      FileUtils._context = context as common.UIAbilityContext;
    }
  }

  /**
   * 该方法用于更改当前 UI Ability 上下文实例的区域模式
   *
   * @param area      - 区域模式
   * @param uiContext - UI 上下文实例
   * @returns 设置成功返回 true，失败返回 false
   */
  public static changeAreaMode(area: contextConstant.AreaMode): boolean {
    if (FileUtils._context) {
      FileUtils._context.area = area;
      return true;
    } else {
      return false;
    }
  }

  /**
   * 将文件保存至应用沙箱的 Cache 目录
   *
   * @param srcUriOrPath - 源文件 URI 或路径
   * @param area         - 文件区域模式
   * @param uiContext    - UI 上下文实例
   * @returns 所存放文件对应的资源标志符
   */
  public static async saveFileToCache(
    srcUriOrPath: string,
    area: contextConstant.AreaMode = contextConstant.AreaMode.EL2,
  ): Promise<fileUri.FileUri> {
    const srcUriObject: fileUri.FileUri = new fileUri.FileUri(srcUriOrPath);
    const destPath: string = FileUtils._context.cacheDir + '/' + srcUriObject.name;
    const srcPath: string = srcUriObject.path;
    let destFile: fs.File | null = null;
    let srcFile: fs.File | null = null;
    try {
      if (srcPath === destPath) {
        return new fileUri.FileUri(destPath);
      }
      if (!FileUtils.changeAreaMode(area)) {
        throw new Error(`Failed to set file storage area mode: ${area}`);
      }
      if (!fs.accessSync(srcPath, fs.AccessModeType.EXIST)) {
        throw new Error(`Source file does not exist: ${srcPath}`);
      }
      if (!fs.accessSync(srcPath, fs.AccessModeType.READ)) {
        throw new Error(`Source file is not readable: ${srcPath}`);
      }
      destFile = fs.openSync(
        destPath,
        fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC,
      );
      srcFile = fs.openSync(srcPath, fs.OpenMode.READ_ONLY);
      fs.copyFileSync(srcFile.fd, destFile.fd);
      return new fileUri.FileUri(destPath);
    } catch (err) {
      UtilLog.error(LOG_TAG, 'save file to cache failed. error:' + JSON.stringify(err));
    } finally {
      FileUtils.safeClose(destFile);
      FileUtils.safeClose(srcFile);
    }
    return new fileUri.FileUri('');
  }

  /**
   * 将传入对象序列化为 JSON 文件形式存放至 Cache 目录
   *
   * @param obj       - 任意可序列化对象
   * @param filename  - 目标文件名
   * @param area      - 文件区域模式
   * @param uiContext - UI 上下文实例
   * @returns 所存放文件对应的资源标志符
   */
  public static async saveJsonToCache(
    obj: ESObject,
    filename: string,
    area: contextConstant.AreaMode = contextConstant.AreaMode.EL2,
  ): Promise<fileUri.FileUri> {
    const destPath: string = FileUtils._context.cacheDir + '/' + filename;
    if (!FileUtils.changeAreaMode(area)) {
      throw new Error(`Failed to set file storage area mode: ${area}`);
    }
    const jsonStr: string = JSON.stringify(obj, null, 2);
    let destFile: fs.File | null = null;
    try {
      destFile = fs.openSync(
        destPath,
        fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC,
      );
      fs.writeSync(destFile.fd, jsonStr);
      return new fileUri.FileUri(destPath);
    } catch (err) {
      UtilLog.error(LOG_TAG, 'save file to json failed. error:' + JSON.stringify(err));
    } finally {
      FileUtils.safeClose(destFile);
    }
    return new fileUri.FileUri('');
  }

  /**
   * 尝试从 Cache 目录读取指定文件并采用 JSON 反序列化
   *
   * @param filename  - 目标文件名
   * @param area      - 文件区域模式
   * @param uiContext - UI 上下文实例
   * @returns 反序列化得到的对象
   */
  public static async readJsonFromCache(
    filename: string,
    area: contextConstant.AreaMode = contextConstant.AreaMode.EL2,
  ): Promise<ESObject> {
    const filePath: string = FileUtils._context.cacheDir + '/' + filename;
    let file: fs.File | null = null;
    let buffer: ArrayBuffer | undefined;
    try {
      if (!FileUtils.changeAreaMode(area)) {
        throw new Error(`Failed to set file storage area mode: ${area}`);
      }
      if (!fs.accessSync(filePath, fs.AccessModeType.EXIST)) {
        throw new Error(`Source file does not exist: ${filePath}`);
      }
      if (!fs.accessSync(filePath, fs.AccessModeType.READ)) {
        throw new Error(`Source file is not readable: ${filePath}`);
      }
      file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      const stat: fs.Stat = fs.statSync(filePath);
      buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
    } catch (err) {
      UtilLog.error(LOG_TAG, 'read file from json failed. error:' + JSON.stringify(err));
    } finally {
      FileUtils.safeClose(file);
    }
    if(buffer){
      const decoder: util.TextDecoder = util.TextDecoder.create(
        StandardCharsets.UTF_8,
      );
      return JSON.parse(decoder.decodeToString(new Uint8Array(buffer)));
    }
    return Promise.reject();
  }

  private static safeClose(file: fs.File | null): void {
    if (file) {
      try {
        fs.closeSync(file);
      } catch {
      }
    }
  }
}
