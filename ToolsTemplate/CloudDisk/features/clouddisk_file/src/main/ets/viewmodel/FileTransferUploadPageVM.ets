import { promptAction } from '@kit.ArkUI';
import { NewFileFolderOperationSelectVM } from 'clouddisk_file_operation';
import {
  CacheUtil,
  FileInfo,
  FileTransferProgressingStatus,
  FileType,
  GlobalContext,
  MockService,
  RouterMap,
  TCLogger,
  TimeUtil,
  UserInfo,
  ProgressingFileType,
  FailedFileType,
  UploadFileStatus,
  UploadFileStatusCode,
  Constants
} from 'common';
import { FileListSelectViewVM } from 'clouddisk_file_select';
import { NavPageInfo, phoneRouterControl } from 'oh_router';
import { FileOperationUtil, FileSelectPickerUtil } from 'module_cloud_upload';
import { media } from '@kit.MediaKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import image from '@ohos.multimedia.image';
import { BusinessError } from '@kit.BasicServicesKit';

@ObservedV2
export class FileTransferUploadPageVM {
  private readonly logTag: string = 'FileTransferUploadPageVM'
  private static _rootInstance: FileTransferUploadPageVM;

  public static get rootInstance(): FileTransferUploadPageVM {
    if (FileTransferUploadPageVM._rootInstance === undefined) {
      FileTransferUploadPageVM._rootInstance = new FileTransferUploadPageVM()
    }
    return FileTransferUploadPageVM._rootInstance;
  }

  // 上传文件更新列表
  @Trace uploadFileProgressingList: FileInfo[] = []
  // 文件上传更新提示
  @Trace uploadFileUpdate: FileTransferProgressingStatus = new FileTransferProgressingStatus()
  // 下载工具
  private uploadFileSelectUtil: FileSelectPickerUtil = new FileSelectPickerUtil();
  // 云存储是否登录成功
  private fileOperationUtil: FileOperationUtil = new FileOperationUtil();
  // 新建文件上拉框操作对象
  private newFileOperationSelectVM: NewFileFolderOperationSelectVM = new NewFileFolderOperationSelectVM();
  // 进行中的文件类型
  @Trace progressingFileType: ProgressingFileType[] = MockService.fileTransferUploadProgressingList
  // 进行中的文件类型
  @Trace failedFileType: FailedFileType[] = MockService.fileTransferUploadFailedList
  // 显示上拉操作栏
  @Trace isShowOperation: boolean = false;
  // 文件选择工具
  @Trace selectVM: FileListSelectViewVM = new FileListSelectViewVM(MockService.fileTransferUploadCompleteList);

  // 开始上传文件任务
  public startRetryUploadFileTask(filePath: string) {
    this.uploadFileSelectUtil.setProgressUtil((uploadFileStatus: UploadFileStatus) => {
      // 更新下载进度
      this.updateUploadFileStatus(uploadFileStatus, false, false)
    })
    const fileName: string = filePath.split('/').pop() as string
    // 初始化云存储登录
    if (!FileOperationUtil.isInitSuccess) {
      this.fileOperationUtil.init().then((res: boolean) => {
        FileOperationUtil.isInitSuccess = true
        this.fileOperationUtil.restartUploadTask(fileName).then((res: boolean) => {
          if (!res) {
            this.retryUploadFileTask(filePath)
          }
        })
      })
      return
    }
    this.fileOperationUtil.restartUploadTask(fileName).then((res: boolean) => {
      if (!res) {
        this.retryUploadFileTask(filePath)
      }
    })
  }

  // 重新上传文件任务
  public retryFailedFileTask(fileName: string, filePath: string) {
    this.uploadFileSelectUtil.setProgressUtil((uploadFileStatus: UploadFileStatus) => {
      // 更新下载进度
      this.updateUploadFileStatus(uploadFileStatus, false, false)
    })
    // 初始化云存储登录
    if (!FileOperationUtil.isInitSuccess) {
      this.fileOperationUtil.init().then((res: boolean) => {
        FileOperationUtil.isInitSuccess = true
        this.retryUploadFailedFileTask(fileName, filePath)
      })
      return
    }
    this.retryUploadFailedFileTask(fileName, filePath)
  }

  // 停止上传文件任务
  public stopUploadFileTask(fileName: string): Promise<boolean> {
    return new Promise<boolean>((resolve, reject) => {
      this.fileOperationUtil.stopUploadTask(fileName).then((res: boolean) => {
        resolve(res)
      }).catch((err: BusinessError) => {
        resolve(false)
      })
    })
  }

  // 开始文件上传进度任务
  private retryUploadFileTask(filePath: string) {
    this.uploadFileSelectUtil.upload(filePath).then((res: UploadFileStatus) => {
      if (res.code === UploadFileStatusCode.SUCCESS) {
        promptAction.showToast({
          message: res.fileName + ' 上传成功！'
        })
        // 添加文件
        this.updateUploadFileStatus(res, true)
        GlobalContext.getUIContext().getHostContext()?.eventHub.emit(Constants.FILETRANSFERSTATUS_KEY, '已完成')
      } else {
        promptAction.showToast({
          message: res.fileName + ' 上传失败！'
        })
        // 上传失败了
        this.updateUploadFileStatus(res, true, false)
        GlobalContext.getUIContext().getHostContext()?.eventHub.emit(Constants.FILETRANSFERSTATUS_KEY, '任务失败')
      }
    })
  }

  // 重新开始文件上传进度任务
  private retryUploadFailedFileTask(fileName: string, filePath: string) {
    this.uploadFileSelectUtil.uploadFailedFile(filePath, fileName).then((res: UploadFileStatus) => {
      if (res.code === UploadFileStatusCode.SUCCESS) {
        promptAction.showToast({
          message: res.fileName + ' 上传成功！'
        })
        // 添加文件
        this.updateUploadFileStatus(res, true)
        GlobalContext.getUIContext().getHostContext()?.eventHub.emit(Constants.FILETRANSFERSTATUS_KEY, '已完成')
      } else {
        promptAction.showToast({
          message: res.fileName + ' 上传失败！'
        })
        // 上传失败了
        this.updateUploadFileStatus(res, true, false)
        GlobalContext.getUIContext().getHostContext()?.eventHub.emit(Constants.FILETRANSFERSTATUS_KEY, '任务失败')
      }
    })
  }

  // 选择文件上传操作
  public selectUploadFileTask(type: string, newFileFolderVm: NewFileFolderOperationSelectVM) {
    this.newFileOperationSelectVM = newFileFolderVm
    this.uploadFileSelectUtil.setProgressUtil((uploadFileStatus: UploadFileStatus) => {
      // 更新下载进度
      this.updateUploadFileStatus(uploadFileStatus, false, false)
    })
    if (!FileOperationUtil.isInitSuccess) {
      this.fileOperationUtil.init().then((res: boolean) => {
        FileOperationUtil.isInitSuccess = true
        this.uploadFileTask(type)
      })
      return
    }
    this.uploadFileTask(type)
  }

  // 选择文件上传任务
  private uploadFileTask(type: string) {
    if (type === '文件' || type === '音频') {
      this.uploadFileSelectUtil.uploadDocumentFile().then((uri: string) => {
        // 上传文件
        this.uploadFileSelectUtil.upload(uri).then((res: UploadFileStatus) => {
          if (res.code === UploadFileStatusCode.SUCCESS) {
            promptAction.showToast({
              message: res.fileName + ' 上传成功！'
            })
            // 添加文件
            this.updateUploadFileStatus(res, true)
            GlobalContext.getUIContext().getHostContext()?.eventHub.emit(Constants.FILETRANSFERSTATUS_KEY, '已完成')
          } else {
            promptAction.showToast({
              message: res.fileName + ' 上传失败！'
            })
            // 上传失败了
            this.updateUploadFileStatus(res, true, false)
            GlobalContext.getUIContext().getHostContext()?.eventHub.emit(Constants.FILETRANSFERSTATUS_KEY, '任务失败')
          }
        })
      })
    } else if (type === '照片' || type === '视频') {
      this.uploadFileSelectUtil.uploadMedia().then((uri: string) => {
        // 上传文件
        this.uploadFileSelectUtil.upload(uri).then((res: UploadFileStatus) => {
          if (res.code === UploadFileStatusCode.SUCCESS) {
            promptAction.showToast({
              message: res.fileName + ' 上传成功！'
            })
            // 添加文件
            this.updateUploadFileStatus(res, true)
            GlobalContext.getUIContext().getHostContext()?.eventHub.emit(Constants.FILETRANSFERSTATUS_KEY, '已完成')
          } else {
            promptAction.showToast({
              message: res.fileName + ' 上传失败！'
            })
            // 上传失败了
            this.updateUploadFileStatus(res, true, false)
            GlobalContext.getUIContext().getHostContext()?.eventHub.emit(Constants.FILETRANSFERSTATUS_KEY, '任务失败')
          }
        })
      })
    } else {
      promptAction.showToast({
        message: '未知项'
      })
    }
  }

  // 上报上传进度
  updateUploadFileStatus(item: UploadFileStatus, isCompleted: boolean = false, isSucceed: boolean = true) {
    const userInfo: UserInfo = new UserInfo()
    // 文件类型
    const filename: string = item.fileName.split('/').pop() as string
    const fileType: string = filename.split('.').pop() as string
    item.fileSuffix = FileSelectPickerUtil.getFileType(fileType)
    // 创建时间
    item.createTime =
      `${TimeUtil.getCurDate(TimeUtil.PATTERN_DATE_HYPHEN)} ${TimeUtil.getCurTime(TimeUtil.PATTERN_TIME_COLON)}`;
    // 创建文件对象
    const fileInfo: FileInfo = new FileInfo(item.fileSuffix, item.fileName.split('/').pop() as string, item.createTime);
    fileInfo.path = item.filePath
    fileInfo.fileSize = CacheUtil.formatCacheFileSize(item.fileSize)
    fileInfo.fileSizeByte = item.fileSize
    fileInfo.updateTime = item.createTime
    fileInfo.progress = item.progress
    fileInfo.progressDes =
      `${CacheUtil.formatCacheFileSize(item.progress)}/${CacheUtil.formatCacheFileSize(item.fileSize)}`
    fileInfo.speed = CacheUtil.formatCacheFileSpeed(item.progress, item.progressTime)
    fileInfo.vipStatus = item.vipStatus
    fileInfo.des = `${CacheUtil.formatCacheFileSize(item.fileSize)} 上传到：文件/`
    fileInfo.downloadUrl = item.fileName
    fileInfo.isCompleted = isCompleted
    fileInfo.isSucceed = isSucceed
    if (item.fileSuffix === FileType.Picture) {
      fileInfo.thumbnailUrl = item.cachePath
    } else if (isCompleted && item.fileSuffix === FileType.Video) {
      const preStr: string = item.cachePath.split('/').pop() as string
      const desPath: string = GlobalContext.getUIAbilityContext().cacheDir + '/' + preStr.split('.')[0] + '.png'
      fileInfo.thumbnailUrl = desPath
      this.checkFirstFrame(item, desPath)
    }

    // 添加更新下载列表文件
    this.updateAndAddUploadFileStatus(fileInfo)
  }

  // 获取首帧
  async checkFirstFrame(item: UploadFileStatus, desPath: string): Promise<void> {
    let fileFd: number | undefined = undefined
    let fd: number | null = null;
    try {
      // 获取首帧
      let avImageGenerator: media.AVImageGenerator = await media.createAVImageGenerator();

      fileFd = fs.openSync(item.cachePath, fs.OpenMode.READ_WRITE).fd;
      let avFileDescriptor: media.AVFileDescriptor = { fd: fileFd };
      avImageGenerator.fdSrc = avFileDescriptor;
      let timeUs = 0;
      let queryOption = media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC;
      let param: media.PixelMapParams = {
        width: 300,
        height: 300
      };
      const pixelMap = await avImageGenerator.fetchFrameByTime(timeUs, queryOption, param);
      // Release resources(Promise mode)
      avImageGenerator.release();

      // 存储
      const imagePacker = image.createImagePacker();
      const imageBuffer = await imagePacker.packToData(pixelMap, {
        format: 'image/png',
        quality: 100
      });
      const mode = fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE;
      fd = fs.openSync(desPath, mode).fd;
      fs.truncateSync(fd);
      fs.writeSync(fd, imageBuffer);
    } catch (e) {
    } finally {
      if (fileFd !== undefined) {
        fs.closeSync(fileFd)
      }
      if (fd !== undefined) {
        fs.closeSync(fd);
      }

      fs.unlink(item.cachePath)
    }
  }

  // 跳转文件传输页面
  public updateAndAddUploadFileStatus(file: FileInfo, isJump: boolean = true) {
    const fileInfoList: FileInfo[] =
      this.uploadFileProgressingList.filter((fileInfo: FileInfo, i: number) => {
        if (this.uploadFileProgressingList[i].name === file.name &&
          this.uploadFileProgressingList[i].isCompleted === false) {
          file.fileId = this.uploadFileProgressingList[i].fileId
          this.uploadFileProgressingList[i] = file
          // 修改文件传输状态
          this.uploadFileUpdate.index = i
          this.uploadFileUpdate.isNewAdd = false
          this.addFileToProgressingList()
          TCLogger.info(this.logTag,
            'Update uploadFileUpdate: ' + file.name + ', progress: ' + (file.progress / file.fileSizeByte * 100) +
              ', uploadFileUpdate: ' + JSON.stringify(this.uploadFileUpdate));
          return true
        } else {
          return false
        }
      })
    if (fileInfoList.length === 0) {
      this.putFileInfoToList(file, isJump)
    }
  }

  // 添加记录到列表中
  putFileInfoToList(fileInfo: FileInfo, isJump: boolean = true) {
    // 使用时间戳作为文件id
    fileInfo.fileId = Date.now()
    this.uploadFileProgressingList.push(fileInfo)
    TCLogger.info(this.logTag,
      'Add uploadFileUpdate: ' + fileInfo.name + ', progress: ' + (fileInfo.progress / fileInfo.fileSizeByte * 100) +
        ', uploadFileUpdate: ' + JSON.stringify(this.uploadFileUpdate));
    // 修改文件传输状态
    this.uploadFileUpdate.index = this.uploadFileProgressingList.length - 1
    this.uploadFileUpdate.isNewAdd = true
    this.addFileToProgressingList()
    if (isJump) {
      if (this.newFileOperationSelectVM) {
        // 隐藏上传文件上拉框
        this.newFileOperationSelectVM.isShow = false
      }
      // 主动跳转文件传输页面
      this.jumpToFileTransferPage()
    }
  }

  // 跳转文件传输页面
  jumpToFileTransferPage() {
    // 跳转下载tab的进行中标签
    GlobalContext.getUIContext().getHostContext()?.eventHub.emit(Constants.FILETRANSFERSTATUS_KEY, '进行中')
    const navPageInfoList: NavPageInfo[] = phoneRouterControl.getNavPageInfoList().filter((navPageInfo) => {
      return navPageInfo.pageName === RouterMap.FILE_TRANSFER_MANAGER_PAGE
    })
    if (navPageInfoList.length === 0) {
      GlobalContext.getUIContext().getHostContext()?.eventHub.emit(Constants.JUMPTO_FILETRANSFERMANAGERPAGE_KEY)
    }
  }

  /**
   * 添加进行中文件到列表中
   */
  addFileToProgressingList() {
    if (this.uploadFileUpdate.isNewAdd) {
      const item = this.uploadFileProgressingList[this.uploadFileUpdate.index]
      const progressingFile = new ProgressingFileType()
      progressingFile.id = item.fileId
      progressingFile.name = item.name.split('/').pop() as string
      progressingFile.img = FileListSelectViewVM.getImageSource(item.fileType)
      progressingFile.fileType = item.fileType
      progressingFile.progress = (item.progress / item.fileSizeByte * 100)
      progressingFile.progressDes = item.progressDes
      progressingFile.speed = item.speed
      progressingFile.vipStatus = item.vipStatus
      progressingFile.isStop = false
      progressingFile.path = item.path
      this.progressingFileType.push(progressingFile)
    }
    // 更新进行中的文件
    const item = this.uploadFileProgressingList[this.uploadFileUpdate.index]
    const itemName = item.name.split('/').pop() as string
    for (let index = 0; index < this.progressingFileType.length; index++) {
      const progressingFile = this.progressingFileType[index]
      if (itemName === progressingFile.name) {
        progressingFile.name = item.name.split('/').pop() as string
        progressingFile.img = FileListSelectViewVM.getImageSource(item.fileType)
        progressingFile.fileType = item.fileType
        progressingFile.progress = (item.progress / item.fileSizeByte * 100)
        progressingFile.progressDes = item.progressDes
        progressingFile.speed = item.speed
        progressingFile.vipStatus = item.vipStatus
        progressingFile.isStop = false
        progressingFile.path = item.path
        // 传输结束，从进行中列表中删除，添加到已完成、任务失败列表中
        this.handleProgressingFile(progressingFile, item)
        break;
      }
    }
  }

  // 传输完成，结果：已完成、任务失败
  handleProgressingFile(progressingFile: ProgressingFileType, item: FileInfo) {
    if (progressingFile.progress === 100 && item.isCompleted === true && item.isSucceed === true) {
      this.progressingFileType =
        this.progressingFileType.filter((item) => item.name !== progressingFile.name)
      // 避免Mock数据没同步，需要重新获取数据
      MockService.fileTransferUploadProgressingList = this.progressingFileType
      // 加到已完成列表
      this.selectVM.fileList.push(item)
      // 加到文件页面文件列表中
      GlobalContext.getUIContext().getHostContext()?.eventHub.emit(Constants.ADDFILELIST_KEY, [item])
      // 首页的文件列表
      MockService.allFileList.push(item)
    } else if (item.isCompleted === true && item.isSucceed === false) {
      this.progressingFileType =
        this.progressingFileType.filter((item) => item.name !== progressingFile.name)
      // 加入到任务失败列表
      const failedFile: FailedFileType = new FailedFileType()
      failedFile.name = progressingFile.name
      failedFile.img = progressingFile.img
      failedFile.des = '上传失败'
      failedFile.isRetry = false
      failedFile.path = progressingFile.path
      this.failedFileType.push(failedFile)
    }
  }

  // 根据文件id获取文件所在目录
  getFilePathByFileId(fileId: number, parentFileId: number): void {
    // 先判断是否在文件页面根目录下
    const isRoot: boolean =
      MockService.checkFileIsBasicPath(fileId, MockService.currentFileList)
    if (isRoot) {
      // 返回文件页面
      phoneRouterControl.popPage()
      return
    }
    const fileInfo: FileInfo | undefined =
      MockService.searchFileInfoBy(parentFileId, MockService.currentFileList)
    if (fileInfo) {
      GlobalContext.getUIContext().getHostContext()?.eventHub.emit(Constants.JUMPTO_DIRECTORPAGE_KEY,
        fileInfo)
    } else {
      promptAction.showToast({
        message: '未找到文件位置'
      })
    }
  }
}