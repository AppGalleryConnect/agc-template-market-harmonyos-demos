import { fileIo, fileUri, fileIo as fs, picker } from '@kit.CoreFileKit';
import { abilityAccessCtrl, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BufferUtil } from './BufferUtil';
import { FileType } from '../common/Constant';
import { FileVo } from '../model/FileVo';
import { contact } from '@kit.ContactsKit';
import { connection } from '@kit.NetworkKit';
import Logger from '../common/Constant';

interface FileGroups {
  images: string[]; // 图片文件地址数组
  documents: string[]; // 文档文件地址数组
  videos: string[]; // 视频文件地址数组
}

// 保存文件到本地
export class FileUtil {
  static deleteSandboxFile(uri: string) {
    try {
      fileIo.unlinkSync(uri)
    } catch (err) {
      Logger.error('unlink file error ', JSON.stringify(err))
    }
  }

  // 格式化文件大小
  static formatFileSize(bytes: number): string {
    if (bytes < 1000) {
      return `${bytes} B`
    }
    if (bytes < 1000 * 1000) {
      return `${(bytes / 1000).toFixed(1)} KB`
    }
    if (bytes < 1000 * 1000 * 1000) {
      return `${(bytes / (1000 * 1000)).toFixed(1)} MB`
    }
    return `${(bytes / (1000 * 1000 * 1000)).toFixed(1)} GB`
  }

  // 获取文件信息
  static async getFileInfo(uri: string, type: FileType): Promise<FileVo | null> {
    try {
      // 将从文件选择器获取的uri ASCII码格式转化为字符串
      // 转换为可用路径
      const path: string = new fileUri.FileUri(uri).path;
      // 从URI中提取文件名
      const fileName = path.substring(path.lastIndexOf('/') + 1) || '未知文件'
      return {
        name: fileName,
        uri: uri,
        size: getSize(uri), // 模拟文件大小
        type: type,
      }
    } catch (err) {
      Logger.error('获取文件信息失败:', JSON.stringify(err))
      return null
    }
  }

  static getDownloadDirectoryPath(context: common.UIAbilityContext): Promise<string> {
    return new Promise((resolve, reject) => {
      const documentViewPicker = new picker.DocumentViewPicker(context);
      const documentSaveOptions = new picker.DocumentSaveOptions();
      documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD; //保存模式为DOWNLOAD
      documentViewPicker.save(documentSaveOptions).then(async (documentSaveResult: Array<string>) => {
        // 获取 Download 目录
        let uri = new fileUri.FileUri(documentSaveResult[0]);
        resolve(uri.path)
      }).catch((err: BusinessError) => {
        Logger.error(`Invoke documentViewPicker.save failed, code is ${err.code}, message is ${err.message}`);
        reject(err)
      })
    })
  }

  // 保存文件到沙箱
  static async copyToSandbox(context: common.UIAbilityContext, sourcePath: string,
    targetFileName: string): Promise<string> {
    const sandboxDir = context.filesDir; // 沙箱路径
    const targetPath = `${sandboxDir}/${targetFileName}`;
    let sourceFile: fs.File | null = null
    let targetFile: fs.File | null = null
    try {
      sourceFile = fs.openSync(sourcePath, fs.OpenMode.READ_ONLY);
      const buffer = new ArrayBuffer(4096);
      let readSize = fs.readSync(sourceFile.fd, buffer);
      // 写入沙箱文件 循环写入
      targetFile = fs.openSync(targetPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      while (readSize > 0) {
        fs.writeSync(targetFile.fd, buffer.slice(0, readSize));
        readSize = fs.readSync(sourceFile.fd, buffer);
      }
    } catch (err) {
      Logger.error(`copyToSandbox failed: ${JSON.stringify(err)}`)
      return ''
    } finally {
      if (sourceFile) {
        fs.closeSync(sourceFile);
      }
      if (targetFile) {
        fs.closeSync(targetFile);
      }
    }
    return targetPath;
  }

  static getFileName(path: string): string {
    return path.substring(path.lastIndexOf('/') + 1) || '未知文件'
  }

  // 将沙箱路径图片转换为base64
  static async convertImageToBase64(imgPath: string): Promise<string> {
    let file: fs.File | null = null;
    try {
      // 使用@ohos.file.fs模块读取文件
      file = fs.openSync(imgPath, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(file.fd);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      // 将ArrayBuffer转换为base64
      const base64Data = BufferUtil.arrayBufferToBase64(buffer)
      // 添加适当的前缀
      const base64String = 'data:image/jpeg;base64,' + base64Data;
      return base64String;
    } catch (error) {
      Logger.error('图片转换base64失败:', error);
      return '';
    } finally {
      if (file) {
        fs.closeSync(file)
      }
    }
  }

  // 根据后缀名获取文件的类型
  static classifyFiles(filePaths: string[]): FileGroups {
    // 定义各类文件的后缀名集合
    const imageExtensions = new Set(['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg']);
    const documentExtensions = new Set(['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'pdf', 'txt', 'md']);
    const videoExtensions = new Set(['mp4', 'avi', 'mov', 'mkv', 'flv', 'wmv', 'rmvb']);

    // 初始化分类结果
    const result: FileGroups = {
      images: [],
      documents: [],
      videos: [],
    };

    // 遍历所有文件路径进行分类
    filePaths.forEach(filePath => {
      // 获取文件后缀名（转为小写处理）
      const lastDotIndex = filePath.lastIndexOf('.');
      if (lastDotIndex === -1) {
        return;
      } // 没有后缀名的文件不处理

      const extension = filePath.substring(lastDotIndex + 1).toLowerCase();

      // 根据后缀名归类
      if (imageExtensions.has(extension)) {
        result.images.push(filePath);
      } else if (documentExtensions.has(extension)) {
        result.documents.push(filePath);
      } else if (videoExtensions.has(extension)) {
        result.videos.push(filePath);
      }
    });

    return result;
  }
}

function getSize(uri: string): number {
  let file: fs.File | null = null
  try {
    let fileUriObject = new fileUri.FileUri(uri);
    let sandboxPath = fileUriObject.path;
    file = fs.openSync(sandboxPath, fs.OpenMode.READ_ONLY);
    const stat = fs.statSync(sandboxPath); // 获取文件状态信息
    return Number((String(stat.size).replace(/(\.\d{2})\d*/, '$1')));
  } catch (err) {
    Logger.error(`获取文件大小失败: ${err.code}, ${err.message}`);
    return 0;
  } finally {
    if (file) {
      fs.closeSync(file)
    }
  }
}

export function formatBytes(bytes: number, decimals: number = 2): string {
  // 处理0字节的情况
  if (bytes === 0) {
    return '0 B';
  }

  // 定义单位和转换系数
  const k = 1024;
  const dm = decimals < 0 ? 0 : decimals;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

  // 计算最适合的单位指数
  const i = Math.floor(Math.log(bytes) / Math.log(k));

  // 计算转换后的值并格式化
  const value = parseFloat((bytes / Math.pow(k, i)).toFixed(dm));

  return `${value} ${sizes[i]}`;
}

// 联系人写入手机
export function addContactByPermissions(context: common.UIAbilityContext, contactList: contact.Contact[]) {
  const permissions: Array<Permissions> = ['ohos.permission.WRITE_CONTACTS'];
  abilityAccessCtrl.createAtManager()
    .requestPermissionsFromUser(context, permissions)
    .then((result: PermissionRequestResult) => {
      if (result.authResults[0] !== 0) { // 0 表示请求权限成功，其他任何非零值表示请求失败
        Logger.error('request contact permissions failed');
        return;
      }
      contactList.forEach((data) => {
        contact.addContact(context, data).then((data) => {
          Logger.info(`Succeeded in adding Contact. data: ${JSON.stringify(data)}`);
        }).catch((err: BusinessError) => {
          Logger.error(`Failed to add Contact. Code: ${err.code}, message: ${err.message}`);
        });
      })
    })
}

// 图片写入手机
export async function saveImageToAlbum(context: Context, buffer: ArrayBuffer) {
  let file: fs.File | null = null
  try {
    let helper = photoAccessHelper.getPhotoAccessHelper(context)
    let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg')
    file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
    await fs.write(file.fd, buffer);
  } catch (error) {
    Logger.error(`save image to system album failed, error.code:${error.code}, error message: ${error.message}.`)
  } finally {
    if (file) {
      fs.closeSync(file)
    }
  }
}

// 视频写入手机
export async function saveVideoToAlbum(context: Context, buffer: ArrayBuffer) {
  let file: fs.File | null = null
  try {
    let helper = photoAccessHelper.getPhotoAccessHelper(context)
    let uri = await helper.createAsset(photoAccessHelper.PhotoType.VIDEO, 'mp4')
    file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
    await fs.write(file.fd, buffer);
  } catch (error) {
    Logger.error(`save image to system album failed, error.code:${error.code}, error message: ${error.message}.`)
  } finally {
    if (file) {
      fs.closeSync(file)
    }
  }
}

export async function getLocalIPAddress(): Promise<string> {
  try {
    let netHandle = await connection.getDefaultNet();
    if (netHandle) {
      let connectionProperties: connection.ConnectionProperties = await connection.getConnectionProperties(netHandle);
      if (connectionProperties && connectionProperties.linkAddresses) {
        for (let address of connectionProperties.linkAddresses) {
          // 过滤IPv4地址
          if (address.address) {
            return address.address.address;
          }
        }
      }
    }
  } catch (error) {
    Logger.error('获取IP地址失败:', error);
  }
  return '';
}

export function splitJsonStrings(input: string): string[] {
  // 使用}作为分隔符分割字符串
  const parts = input.split('}');

  // 存储结果的数组
  const result: string[] = [];

  // 处理分割后的部分，补全}并过滤空字符串
  parts.forEach(part => {
    if (part.trim() !== '') {
      // 补全被分割掉的}
      result.push(part + '}');
    }
  });

  return result;
}

export function checkStringContent(str: string): boolean {
  // 检查字符串中是否包含"success"
  if (str.includes('success')) {
    return true;
  }
  // 检查字符串中是否包含"code"
  if (str.includes('code')) {
    return false;
  }

  return true;
}