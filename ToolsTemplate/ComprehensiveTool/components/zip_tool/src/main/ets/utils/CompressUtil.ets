import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { fileIo as fs, picker } from '@kit.CoreFileKit';
import { CompressedFile } from '../model/ZipModel';
import { formatBytes, formatTimestamp } from './BaseUtil';
import { FileType } from '../common/Constant';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';

// 在沙箱中创建一个固定的文件夹保存压缩包
export function createDirInSandbox(path: string) {
  if (path && !fs.accessSync(path)) {
    fs.mkdir(path)
  }
}

// 将选中的待压缩文件写入沙箱
export async function writeToSandbox(filePath: string, fileList: string[]) {
  if (!fs.accessSync(filePath)) {
    try {
      fs.mkdirSync(filePath)
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`code is ${err.code}, message is ${err.message}`);
    }
  }
  fileList.forEach(async (file) => {
    const fileName = getFileName(decodeURI(file))
    let inFile: fs.File | null = null
    let originFile: fs.File | null = null
    try {
      inFile = fs.openSync(filePath + `/${fileName}`, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      originFile = fs.openSync(file, fs.OpenMode.READ_ONLY)
      fs.copyFileSync(originFile.fd, inFile.fd)
    } catch (err) {
      Logger.error(`open file data failed with error message: ${err}`);
    } finally {
      if (file) {
        fs.closeSync(inFile)
        fs.closeSync(originFile)
      }
    }
  })
}

// 获取文件名称
function getFileName(path: string) {
  const arr = path.split('/')
  return arr[arr.length-1]
}

// 从文件夹中读取压缩文件
export function readCompressedFile(path: string) {
  const fileList: CompressedFile[] = []
  const arr = fs.listFileSync(path)
  if (arr.length === 0) {
    return []
  }
  arr.forEach((file) => {
    const stat = fs.statSync(`${path}/${file}`)
    const index = file.lastIndexOf('.')
    if (index !== -1) {
      const name = file.slice(0, index)
      const format = file.slice(index)
      if (format === '.zip' || format === '.rar' || format === '.war' || format === '.7z') {
        fileList.push(new CompressedFile(FileType.ZIP, file, name, format, formatBytes(stat.size), 0, ''))
      } else {
        fileList.push(new CompressedFile(FileType.FILE, file, name, format, formatBytes(stat.size), 0, ''))
      }
    } else {
      const count = fs.listFileSync(`${path}/${file}`).length
      fileList.push(new CompressedFile(FileType.FOLDER, file, file, '', '', count, formatTimestamp(stat.mtime, true)))
    }
  })

  return fileList
}

// 获取文件夹列表
export function getFolderList(path: string) {
  const folderList: CompressedFile[] = []
  const fileList = fs.listFileSync(path)
  if (fileList.length === 0) {
    return []
  }
  fileList.forEach((file) => {
    const stat = fs.statSync(`${path}/${file}`)
    const index = file.lastIndexOf('.')
    if (index === -1) {
      const count = fs.listFileSync(`${path}/${file}`).length
      folderList.push(new CompressedFile(FileType.FOLDER, file, file, '', '', count, formatTimestamp(stat.mtime, true)))
    }
  })
  return folderList
}

// 重命名
export function rename(currentFolderPath: string, name: string, originName: string) {
  const newPath = `${currentFolderPath}/${name}`
  const originPath = `${currentFolderPath}/${originName}`
  fs.renameSync(originPath, newPath)
  return newPath
}

// 删除
export function deleteZipDocument(currentFolderPath: string, compressedFileList: CompressedFile[],
  selectedCompressedFileList: string[]) {
  compressedFileList.forEach((compressedFile) => {
    selectedCompressedFileList.forEach((id) => {
      if (compressedFile.id === id) {
        const path = `${currentFolderPath}/${compressedFile.name}`
        if (compressedFile.type === FileType.ZIP) {
          fs.unlinkSync(path)
        } else {
          fs.rmdirSync(path)
        }
      }
    })
  })

  promptAction.showToast({ message: '删除成功！' })
}

// 新建文件夹
export function buildNewFolder(path: string, name: string) {
  const newFolderPath = `${path}/${name}`
  if (fs.accessSync(newFolderPath)) {
    return false
  }
  fs.mkdirSync(newFolderPath)
  return true
}

// 移动
export function moveFile(type: FileType, name: string, filePath: string, moveToPath: string) {
  try {
    if (type === FileType.ZIP || type === FileType.FILE) {
      const path = `${moveToPath}/${name}`
      fs.moveFileSync(filePath, path, 0)
    } else {
      fs.moveDirSync(filePath, moveToPath, 0)
    }
  } catch (err) {
    Logger.error(`Failed to move. Code: ${err.code}, message: ${err.message}`);
  }
}

// 获取存储地址
export async function getStoragePath(name: string) {
  let uris: string = ''
  try {
    const documentSaveOptions = new picker.DocumentSaveOptions(); // 创建文件管理器保存选项实例

    documentSaveOptions.newFileNames = [name]
    const documentViewPicker = new picker.DocumentViewPicker();
    let documentSaveResult = await documentViewPicker.save(documentSaveOptions);
    if (documentSaveResult !== undefined) {
      uris = documentSaveResult[0];
      Logger.info('photoViewPicker.save to file succeed and uris are:' + uris);
    }
  } catch (error) {
    let err: BusinessError = error as BusinessError;
    Logger.info('[picker] photoViewPickerSave error = ' + JSON.stringify(err));
  }

  return uris
}

// 文件存储到手机
export async function reSave(path: string, uris: string) {
  let file: fs.File | null = null;
  let file2: fs.File | null = null;
  try {
    file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
    file2 = fs.openSync(uris + '', fs.OpenMode.READ_WRITE)
    fs.copyFileSync(file.fd, file2.fd)
    promptAction.showToast({ message: '保存成功！' })
  } catch (error) {
    Logger.error(`open file data failed with error message: ${error}`);
  } finally {
    if (file) {
      fs.closeSync(file)
      fs.closeSync(file2)
    }
  }
}
