import { common, contextConstant } from '@kit.AbilityKit';
import { fileUri, fileIo as fs } from '@kit.CoreFileKit';
import { UIContext } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';

import { StandardCharsets } from '../common/CustomTypes';

export class FileUtils {
  /**
   * 尝试进一步获取 Ability 上下文实例
   *
   * @param uiContext UI 上下文实例 (可选，不传将尝试通过追溯当前方法的调用链获取 UI Ability Context)
   */
  public static getUIAbilityContext(uiContext?: UIContext): common.UIAbilityContext | null {
    const context: common.Context | undefined = uiContext ? uiContext.getHostContext() : getContext();
    if (context) {
      return context as common.UIAbilityContext;
    } else {
      return null;
    }
  }

  /**
   * 该方法用于更改当前 UI Ability 上下文实例的区域模式
   *
   * @param area      - 区域模式
   * @param uiContext - UI 上下文实例
   * @returns 设置成功返回 true，失败返回 false
   */
  public static changeAreaMode(area: contextConstant.AreaMode, uiContext?: UIContext): boolean {
    const context: common.Context | null = FileUtils.getUIAbilityContext(uiContext);
    if (context) {
      context.area = area;
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
    uiContext?: UIContext
  ): Promise<fileUri.FileUri> {
    const context: common.UIAbilityContext = FileUtils.getUIAbilityContext(uiContext)!;
    const srcUriObject: fileUri.FileUri = new fileUri.FileUri(srcUriOrPath);
    const destPath: string = context.cacheDir + '/' + srcUriObject.name;
    const srcPath: string = srcUriObject.path;
    if (srcPath === destPath) {
      return new fileUri.FileUri(destPath);
    }
    if (!FileUtils.changeAreaMode(area, uiContext)) {
      throw new Error(`Failed to set file storage area mode: ${area}`);
    }
    if (!fs.accessSync(srcPath, fs.AccessModeType.EXIST)) {
      throw new Error(`Source file does not exist: ${srcPath}`);
    }
    if (!fs.accessSync(srcPath, fs.AccessModeType.READ)) {
      throw new Error(`Source file is not readable: ${srcPath}`);
    }
    let destFile: fs.File | null = null;
    let srcFile: fs.File | null = null;
    try {
      destFile = fs.openSync(destPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC);
      srcFile = fs.openSync(srcPath, fs.OpenMode.READ_ONLY);
      fs.copyFileSync(srcFile.fd, destFile.fd);
      return new fileUri.FileUri(destPath);
    } finally {
      FileUtils.safeClose(destFile);
      FileUtils.safeClose(srcFile);
    }
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
    obj: Object,
    filename: string,
    area: contextConstant.AreaMode = contextConstant.AreaMode.EL2,
    uiContext?: UIContext
  ): Promise<fileUri.FileUri> {
    const context: common.UIAbilityContext = FileUtils.getUIAbilityContext(uiContext)!;
    const destPath: string = context.cacheDir + '/' + filename;
    if (!FileUtils.changeAreaMode(area, uiContext)) {
      throw new Error(`Failed to set file storage area mode: ${area}`);
    }
    const jsonStr: string = JSON.stringify(obj, null, 2);
    let destFile: fs.File | null = null;
    try {
      destFile = fs.openSync(destPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC);
      fs.writeSync(destFile.fd, jsonStr);
      return new fileUri.FileUri(destPath);
    } finally {
      FileUtils.safeClose(destFile);
    }
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
    uiContext?: UIContext
  ): Promise<Object> {
    const context: common.UIAbilityContext = FileUtils.getUIAbilityContext(uiContext)!;
    const filePath: string = context.cacheDir + '/' + filename;
    if (!FileUtils.changeAreaMode(area, uiContext)) {
      throw new Error(`Failed to set file storage area mode: ${area}`);
    }
    if (!fs.accessSync(filePath, fs.AccessModeType.EXIST)) {
      throw new Error(`Source file does not exist: ${filePath}`);
    }
    if (!fs.accessSync(filePath, fs.AccessModeType.READ)) {
      throw new Error(`Source file is not readable: ${filePath}`);
    }
    let file: fs.File | null = null;
    try {
      file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      const stat: fs.Stat = fs.statSync(filePath);
      const buffer: ArrayBuffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      const decoder: util.TextDecoder = util.TextDecoder.create(StandardCharsets.UTF_8);
      return JSON.parse(decoder.decodeToString(new Uint8Array(buffer)));
    } finally {
      FileUtils.safeClose(file);
    }
  }

  private static safeClose(file: fs.File | null): void {
    if (file) {
      try { fs.closeSync(file); } catch {}
    }
  }
}
