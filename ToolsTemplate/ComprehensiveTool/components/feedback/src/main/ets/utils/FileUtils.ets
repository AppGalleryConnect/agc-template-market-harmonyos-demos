import { common, contextConstant } from '@kit.AbilityKit';
import { fileUri, fileIo as fs } from '@kit.CoreFileKit';
import { UIContext } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { UtilLog } from '@hw-agconnect/util-log';
import { StandardCharsets } from '../common/CustomTypes';

export class FileUtils {
  private static _context: Context | undefined;

  public static get context(): common.UIAbilityContext {
    return FileUtils._context as common.UIAbilityContext;
  }

  private static _uiContext: UIContext;

  public static get uiContext(): UIContext {
    return FileUtils._uiContext;
  }

  public static async initUIContext(uiContext: UIContext) {
    FileUtils._uiContext = uiContext;
    FileUtils._context = uiContext.getHostContext();
  }

  /**
   * 该方法用于更改当前 UI Ability 上下文实例的区域模式
   *
   * @param area      - 区域模式
   * @returns 设置成功返回 true，失败返回 false
   */
  public static changeAreaMode(area: contextConstant.AreaMode): boolean {
    if (FileUtils.context) {
      FileUtils.context.area = area;
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
   * @returns 所存放文件对应的资源标志符
   */
  public static async saveFileToCache(
    srcUriOrPath: string,
    area: contextConstant.AreaMode = contextConstant.AreaMode.EL2,
  ): Promise<fileUri.FileUri> {
    const srcUriObject: fileUri.FileUri = new fileUri.FileUri(srcUriOrPath);
    const destPath: string = FileUtils.context.cacheDir + '/' + srcUriObject.name;
    const srcPath: string = srcUriObject.path;
    if (srcPath === destPath) {
      return new fileUri.FileUri(destPath);
    }
    if (!FileUtils.changeAreaMode(area)) {
      throw new Error(`Failed to set file storage area mode: ${area}`);
    }
    try {
      fs.accessSync(srcPath, fs.AccessModeType.EXIST);
    } catch (error) {
      throw new Error(`Source file does not exist: ${srcPath}`);
    }
    try {
      fs.accessSync(srcPath, fs.AccessModeType.READ);
    } catch (error) {
      throw new Error(`Source file is not readable: ${srcPath}`);
    }
    let destFile: fs.File | null = null;
    let srcFile: fs.File | null = null;
    try {
      destFile = fs.openSync(destPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC);
      srcFile = fs.openSync(srcPath, fs.OpenMode.READ_ONLY);
      fs.copyFileSync(srcFile.fd, destFile.fd);
      return new fileUri.FileUri(destPath);
    } catch (error) {
      UtilLog.error(0x00F0, '[FileUtils]',
        `Failed to openSync and copyFileSync, errCode: ${error.code}, errMessage: ${error.message}`);
      return new fileUri.FileUri('');
    } finally {
      FileUtils.safeClose(destFile);
    }
  }

  /**
   * 将传入对象序列化为 JSON 文件形式存放至 Cache 目录
   *
   * @param obj       - 任意可序列化对象
   * @param filename  - 目标文件名
   * @param area      - 文件区域模式
   * @returns 所存放文件对应的资源标志符
   */
  public static async saveJsonToCache(
    obj: ESObject,
    filename: string,
    area: contextConstant.AreaMode = contextConstant.AreaMode.EL2,
  ): Promise<fileUri.FileUri> {
    const destPath: string = FileUtils.context.cacheDir + '/' + filename;
    if (!FileUtils.changeAreaMode(area)) {
      throw new Error(`Failed to set file storage area mode: ${area}`);
    }
    const jsonStr: string = JSON.stringify(obj, null, 2);
    let destFile: fs.File | null = null;
    try {
      destFile = fs.openSync(destPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC);
      fs.writeSync(destFile.fd, jsonStr);
      return new fileUri.FileUri(destPath);
    } catch (error) {
      UtilLog.error(0x00F0, '[FileUtils]',
        `Failed to openSync and writeSync, errCode: ${error.code}, errMessage: ${error.message}`);
      return new fileUri.FileUri('');
    } finally {
      FileUtils.safeClose(destFile);
    }
  }

  /**
   * 尝试从 Cache 目录读取指定文件并采用 JSON 反序列化
   *
   * @param filename  - 目标文件名
   * @param area      - 文件区域模式
   * @returns 反序列化得到的对象
   */
  public static async readJsonFromCache(
    filename: string,
    area: contextConstant.AreaMode = contextConstant.AreaMode.EL2,
  ): Promise<ESObject> {
    const filePath: string = FileUtils.context.cacheDir + '/' + filename;
    if (!FileUtils.changeAreaMode(area)) {
      throw new Error(`Failed to set file storage area mode: ${area}`);
    }
    try {
      fs.accessSync(filePath, fs.AccessModeType.EXIST);
    } catch (error) {
      throw new Error(`Source file does not exist: ${filePath}`);
    }
    try {
      fs.accessSync(filePath, fs.AccessModeType.READ);
    } catch (error) {
      throw new Error(`Source file is not readable: ${filePath}`);
    }
    let file: fs.File | null = null;
    try {
      file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      try {
        const stat: fs.Stat = fs.statSync(filePath);
        const buffer: ArrayBuffer = new ArrayBuffer(stat.size);
        try {
          fs.readSync(file.fd, buffer);
        } catch (error) {
          UtilLog.error(0x00F0, '[FileUtils]',
            `Failed to readSync, errCode: ${error.code}, errMessage: ${error.message}`);
          throw new Error(`Failed to readSync`);
        }
        const decoder: util.TextDecoder = util.TextDecoder.create(StandardCharsets.UTF_8);
        return JSON.parse(decoder.decodeToString(new Uint8Array(buffer)));
      } catch (error) {
        UtilLog.error(0x00F0, '[FileUtils]',
          `Failed to statSync, errCode: ${error.code}, errMessage: ${error.message}`);
        throw new Error(`Failed to statSync`);
      }
    } catch (error) {
      UtilLog.error(0x00F0, '[FileUtils]',
        `Failed to openSync, errCode: ${error.code}, errMessage: ${error.message}`);
      throw error as Error;
    } finally {
      FileUtils.safeClose(file);
    }
  }

  private static safeClose(file: fs.File | null): void {
    if (file) {
      try {
        fs.closeSync(file);
      } catch (error) {
        UtilLog.error(0x00F0, '[FileUtils]',
          `Failed to closeSync, errCode: ${error.code}, errMessage: ${error.message}`);
      }
    }
  }
}
