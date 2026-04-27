import { fileIo, fileUri, fileIo as fs, ListFileOptions } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { PersistenceV2Util } from './PersistenceV2Util';
import { RandomUtil } from './RandomUtil';


let listFileOption: ListFileOptions = {
  recursion: false,
  listNum: 0,
  filter: {
    suffix: ['.mp3']
  }
}

export class FileUtil {
  context: common.UIAbilityContext | null = null

  constructor(context: common.UIAbilityContext) {
    this.context = context
  }

  static persistenceV2Util = new PersistenceV2Util()

  /**
   * 读取指定目录下mp3文件
   * pathDir 文件夹名称(/data/storage/el2/base/haps/entry/cache/work/)
   */
  readFilesByDir(pathDir: string) {
    return fileIo.listFileSync(pathDir, listFileOption);
  }

  /**
   * 获取作品集目录
   * return 作品集目录( /data/storage/el2/base/haps/entry/cache/work/)
   */
  getAudioOutDir() {
    const dstDir = this.context?.cacheDir + '/work/'
    if (!fileIo.accessSync(dstDir)) {
      fileIo.mkdirSync(dstDir)
    }
    return dstDir
  }

  /**
   * 获取音乐库文件夹目录
   * context common.UIAbilityContext
   * return 音乐库文件夹目录( /data/storage/el2/base/haps/entry/files/music/)
   */
  getAudioCacheDir() {
    const dstDir = this.context?.filesDir + '/music/'
    if (!fileIo.accessSync(dstDir)) {
      fileIo.mkdirSync(dstDir)
    }
    return dstDir
  }

  /*
   * 获取pcm存放路径
   */
  getAudioPcmDir() {
    const dstDir = this.context?.cacheDir + '/pcm/'
    if (!fileIo.accessSync(dstDir)) {
      fileIo.mkdirSync(dstDir)
    }
    return dstDir
  }

  /**
   * 根据沙箱路径删除文件
   * filePath 完整文件名称（/data/storage/el2/base/haps/entry/cache/work/test.mp3）*/
  deleteFileByPath(filePath: string): boolean {
    try {
      if (!fileIo.accessSync(filePath)) {
        return true
      }
      fileIo.unlinkSync(filePath)
      return true
    } catch (err) {
      return false
    }

  }

  /**
   * 根据沙箱路径删除文件
   * filePath 完整文件名称（/data/storage/el2/base/haps/entry/cache/work/test.mp3）*/
  static deleteFile(filePath: string): boolean {
    try {
      if (!fileIo.accessSync(filePath)) {
        return true
      }
      fileIo.unlinkSync(filePath)
      return true
    } catch (err) {
      return false
    }
  }

  /**
   * 文件复制
   *sourcePath 源文件路径 (file://docs/storage/Users/currentUser/Sounds/test.mp3)
   * return dstPath 沙箱路径  (/data/storage/el2/base/haps/entry/files/tempMusic/xxx.mp3)
   */
  copyFilePath(sourcePath: string): string {
    let dstDir = this.context?.filesDir + '/tempMusic/';
    if (!fileIo.accessSync(dstDir)) {
      fileIo.mkdirSync(dstDir)
    }
    let fileName = this.getRandom() + '';
    const pathArr = this.splitFilePath(sourcePath);
    if (pathArr.length >= 3 && pathArr[2]) {
      fileName += '.' + pathArr[2];
    } else {
      fileName += '.mp4'; // 默认后缀，如果无法解析
    }

    let dstPath = dstDir + fileName;
    let srcFile: fs.File | null = null;
    let dstFile: fs.File | null = null;
    try {
      srcFile = fileIo.openSync(sourcePath, fileIo.OpenMode.READ_ONLY);
      dstFile = fileIo.openSync(dstPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      fileIo.copyFileSync(srcFile.fd, dstFile.fd);
      return dstPath;
    } catch (error) {
      // 尝试直接使用路径复制作为回退方案
      try {
        if (fileIo.accessSync(sourcePath)) {
          fileIo.copyFileSync(sourcePath, dstPath);
          return dstPath;
        }
      } catch (e) {
      }
      return '';
    } finally {
      // 必须判空，否则如果 openSync 失败，srcFile/dstFile 为 null，调用 closeSync 会闪退
      if (srcFile) {
        try {
          fileIo.closeSync(srcFile);
        } catch (e) {
        }
      }
      if (dstFile) {
        try {
          fileIo.closeSync(dstFile);
        } catch (e) {
        }
      }
    }
  }

  /*
   * 文件复制到指定位置
   * src 源文件路径 沙箱目录或uri
   * destPath  目标路径 沙箱目录或uri
   */
  static async copyFileToDestPath(src: string, destPath: string) {
    let from = src.startsWith('file://') ? src : fileUri.getUriFromPath(src)
    let to = destPath.startsWith('file://') ? destPath : fileUri.getUriFromPath(destPath)
    try {
      await fileIo.copy(from, to)
      return true
    } catch (error) {
      return false
    }

  }

  /**
   * 创建文件夹
   * path 文件夹路径（/data/storage/el2/base/haps/entry/files/music）
   */
  mkdir(path: string) {
    if (!fileIo.accessSync(path)) {
      fileIo.mkdirSync(path)
    }
  }

  /**
   * sourcePath 源文件路径 (file://docs/storage/Users/currentUser/Sounds/test.mp3)
   * return ['file://docs/storage/Users/currentUser/Sounds','test','mp3']
   */
  splitFilePath(sourcePath: string): Array<string> {
    // 获取最后一个斜杠的位置
    const lastSlashIndex = sourcePath.lastIndexOf('/');
    const pathPart = sourcePath.substring(0, lastSlashIndex);

    // 获取文件名部分
    const fileNameWithExt = sourcePath.substring(lastSlashIndex + 1);

    // 分割文件名和扩展名
    const dotIndex = fileNameWithExt.lastIndexOf('.');
    if (dotIndex === -1) {
      return [pathPart, fileNameWithExt, ''];
    }
    const fileName = fileNameWithExt.substring(0, dotIndex);
    const ext = fileNameWithExt.substring(dotIndex + 1);

    return [pathPart, fileName, ext];

  }

  /**
   * 获取进度log目录
   * return 进度log目录( /data/storage/el2/base/haps/entry/cache/log/)
   */
  getLogOutPath() {
    const dstDir = this.context?.cacheDir + '/log/'
    if (!fileIo.accessSync(dstDir)) {
      fileIo.mkdirSync(dstDir)
    }
    let dstPath = dstDir + this.getRandom() + '.log'
    return dstPath
  }

  /**workName：任务名称（调速、调节、降噪等）suffixName文件后缀名
   * 获取音频导出文件全路径
   * return 音频导出文件全路径( /data/storage/el2/base/haps/entry/cache/work/test.mp3)
   */
  getAudioOutPath(workName?: string, suffixName?: string) {
    const dstDir = this.context?.cacheDir + '/work/'
    if (!fileIo.accessSync(dstDir)) {
      fileIo.mkdirSync(dstDir)
    }
    let fileSuffixName = suffixName ? ('.' + suffixName) : '.mp3'
    let lastName = workName ? (workName + fileSuffixName) : fileSuffixName
    let dstPath = dstDir + this.getRandom() + lastName
    return dstPath
  }

  getRandom(): number {
    return new Date().getTime() + RandomUtil.getRandom(10)
  }

  /**workName：任务名称（调节-test.mp3）
   * 获取音频导出文件全路径
   * return 音频导出文件路径( 调节-test.mp3 或者 调节-test(1).mp3)
   */
  generateUniquePathname(workName: string): string {

    let splitPathArray = this.splitFilePath(workName)
    const pathname = splitPathArray[1]
    const suffixName = splitPathArray[2]

    const tempStr = FileUtil.persistenceV2Util.getData('work');
    let existingPaths: Record<string, string>[] = []
    if (!tempStr) { //数据不存在
      return pathname + '.' + suffixName
    }
    if (existingPaths) {
      existingPaths = JSON.parse(tempStr) as Record<string, string>[];
    }
    // 如果列表中没有相同 title，直接返回原值
    if (!existingPaths.some(item => item.title.indexOf(pathname) !== -1)) {
      let lastName = pathname + '.' + suffixName
      return lastName;
    }

    let counter = 1;
    let candidate: string;

    // 循环生成带编号的候选名称，直到找到未使用的
    do {
      candidate = `${pathname}(${counter})`;
      counter++;
    } while (existingPaths.some(item => item.title === candidate));

    let lastName = candidate + '.' + suffixName
    return lastName;
  }
}
