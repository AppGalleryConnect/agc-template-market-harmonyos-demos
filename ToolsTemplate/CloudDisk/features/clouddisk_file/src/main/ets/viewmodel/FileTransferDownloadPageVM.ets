import { promptAction } from '@kit.ArkUI';
import {
  DownloadFileStatus,
  DownloadFileStatusCode,
  CacheUtil,
  FileInfo,
  FileTransferProgressingStatus,
  MockService,
  RouterMap,
  TCLogger,
  TimeUtil,
  FailedFileType,
  ProgressingFileType,
  GlobalContext,
  Constants
} from 'common';
import {
  FileOperationUtil, FileSelectPickerUtil
} from 'module_cloud_upload';
import { FileListSelectViewVM } from 'clouddisk_file_select';
import { NewFileFolderOperationSelectVM } from 'clouddisk_file_operation';
import { phoneRouterControl, NavPageInfo } from 'oh_router';
import { BusinessError } from '@kit.BasicServicesKit';

@ObservedV2
export class FileTransferDownloadPageVM {
  private readonly logTag: string = 'FileTransferDownloadPageVM'
  private static _rootInstance: FileTransferDownloadPageVM;

  public static get rootInstance(): FileTransferDownloadPageVM {
    if (FileTransferDownloadPageVM._rootInstance === undefined) {
      FileTransferDownloadPageVM._rootInstance = new FileTransferDownloadPageVM()
    }
    return FileTransferDownloadPageVM._rootInstance;
  }

  // 下载文件更新列表
  @Trace downloadFileProgressingList: FileInfo[] = []
  // 文件下载更新提示
  @Trace downloadFileUpdate: FileTransferProgressingStatus = new FileTransferProgressingStatus()
  // 云存储是否登录成功
  private fileOperationUtil: FileOperationUtil = new FileOperationUtil();
  // 下载工具
  private downloadFileOperationUtil: FileOperationUtil = new FileOperationUtil();
  // 下载进行中的文件类型
  @Trace downloadProgressingFileType: ProgressingFileType[] = MockService.fileTransferDownloadProgressingList
  // 下载进行中的文件类型
  @Trace downloadFailedFileType: FailedFileType[] = MockService.fileTransferDownloadFailedList
  // 显示上拉操作栏
  @Trace isShowOperation: boolean = false;
  // 下载已完成的文件
  @Trace downloadSelectVM: FileListSelectViewVM =
    new FileListSelectViewVM(MockService.fileTransferDownloadCompleteList);

  // 开启下载文件任务
  public startDownloadFileTask(fileInfo: FileInfo) {
    this.downloadFileOperationUtil.setDownloadProgressUtil((downloadFileStatus: DownloadFileStatus) => {
      // 更新下载进度
      this.updateDownloadFileStatus(downloadFileStatus, fileInfo, false, false)
    })
    const fileName: string = fileInfo.name.split('/').pop() as string
    // 初始化云存储登录
    if (!FileOperationUtil.isInitSuccess) {
      this.fileOperationUtil.init().then((res: boolean) => {
        FileOperationUtil.isInitSuccess = true
        this.fileOperationUtil.restartDownloadTask(fileName).then((res: boolean) => {
          if (!res) {
            this.downloadFileTask(fileInfo)
          }
        })
      })
      return
    }
    this.fileOperationUtil.restartDownloadTask(fileName).then((res: boolean) => {
      if (!res) {
        this.downloadFileTask(fileInfo)
      }
    })
  }

  // 开启重新下载文件任务
  public startDownloadFailedFileTask(fileInfo: FileInfo) {
    this.downloadFileOperationUtil.setDownloadProgressUtil((downloadFileStatus: DownloadFileStatus) => {
      // 更新下载进度
      this.updateDownloadFileStatus(downloadFileStatus, fileInfo, false, false)
    })
    // 初始化云存储登录
    if (!FileOperationUtil.isInitSuccess) {
      this.fileOperationUtil.init().then((res: boolean) => {
        FileOperationUtil.isInitSuccess = true
        this.downloadFileTask(fileInfo, false)
      })
      return
    }
    this.downloadFileTask(fileInfo, false)
  }

  // 停止下载文件任务
  public stopDownloadFileTask(fileName: string): Promise<boolean> {
    return new Promise<boolean>((resolve, reject) => {
      this.fileOperationUtil.stopDownloadTask(fileName).then((res: boolean) => {
        resolve(res)
      }).catch((err: BusinessError) => {
        resolve(false)
      })
    })
  }

  // 下载文件任务
  private downloadFileTask(fileInfo: FileInfo, checkName: boolean = true) {
    this.downloadFileOperationUtil.checkAndDownloadFile(fileInfo, checkName).then((result) => {
      // 成功
      if (result.code === DownloadFileStatusCode.SUCCESS) {
        promptAction.showToast({
          message: result.fileName + ' 下载成功！'
        })
        // 添加文件
        this.updateDownloadFileStatus(result, fileInfo, true)
        GlobalContext.getUIContext().getHostContext()?.eventHub.emit(Constants.FILETRANSFERSTATUS_KEY, '已完成')
        TCLogger.info(this.logTag, `downloadFile succeeded, result: ${JSON.stringify(result)}`)
      } else {
        promptAction.showToast({
          message: result.fileName + ' 下载失败！'
        })
        // 上传失败了
        this.updateDownloadFileStatus(result, fileInfo, true, false)
        GlobalContext.getUIContext().getHostContext()?.eventHub.emit(Constants.FILETRANSFERSTATUS_KEY, '任务失败')
        TCLogger.info(this.logTag, `downloadFile failed, result: ${JSON.stringify(result)}`)
      }
    })
  }

  // 上报下载进度
  updateDownloadFileStatus(item: DownloadFileStatus, fileInfoItem: FileInfo, isCompleted: boolean = false,
    isSucceed: boolean = true) {
    // 文件类型
    const filename: string = item.fileName.split('/').pop() as string
    const fileType: string = filename.split('.').pop() as string
    item.fileSuffix = FileSelectPickerUtil.getFileType(fileType)
    // 创建时间
    item.createTime =
      `${TimeUtil.getCurDate(TimeUtil.PATTERN_DATE_HYPHEN)} ${TimeUtil.getCurTime(TimeUtil.PATTERN_TIME_COLON)}`;
    // 创建文件对象
    const fileInfo: FileInfo = new FileInfo(item.fileSuffix, item.fileName.split('/').pop() as string, item.createTime);
    // 文件的fileId
    fileInfo.fileId = fileInfoItem.fileId
    fileInfo.path = item.filePath
    fileInfo.fileSize = CacheUtil.formatCacheFileSize(item.fileSize)
    fileInfo.fileSizeByte = item.fileSize
    fileInfo.updateTime = item.createTime
    fileInfo.progress = item.progress
    fileInfo.progressDes =
      `${CacheUtil.formatCacheFileSize(item.progress)}/${CacheUtil.formatCacheFileSize(item.fileSize)}`
    fileInfo.speed = CacheUtil.formatCacheFileSpeed(item.progress, item.progressTime)
    fileInfo.vipStatus = item.vipStatus
    fileInfo.des = `${CacheUtil.formatCacheFileSize(item.fileSize)} 下载到：缓存/`
    fileInfo.downloadUrl = item.fileName
    fileInfo.isCompleted = isCompleted
    fileInfo.isSucceed = isSucceed
    // 添加更新下载列表文件
    this.updateAndAddDownloadFileStatus(fileInfo)
  }

  // 跳转文件传输页面
  private updateAndAddDownloadFileStatus(file: FileInfo, isJump: boolean = true,
    newFileFolderVm?: NewFileFolderOperationSelectVM) {
    const fileInfoList: FileInfo[] =
      this.downloadFileProgressingList.filter((fileInfo: FileInfo, i: number) => {
        if (this.downloadFileProgressingList[i].name === file.name &&
          this.downloadFileProgressingList[i].isCompleted === false) {
          this.downloadFileProgressingList[i] = file
          // 修改文件传输状态
          this.downloadFileUpdate.index = i
          this.downloadFileUpdate.isNewAdd = false
          this.addFileToDownloadProgressingList()
          TCLogger.info(this.logTag,
            'Update downloadFileUpdate: ' + file.name + ', progress: ' + (file.progress / file.fileSizeByte * 100) +
              ', downloadFileUpdate: ' + JSON.stringify(this.downloadFileUpdate));
          return true
        } else {
          return false
        }
      })
    if (fileInfoList.length === 0) {
      if (newFileFolderVm) {
        this.putFileInfoToDownloadList(file, isJump, newFileFolderVm)
      } else {
        this.putFileInfoToDownloadList(file, isJump)
      }
    }
  }

  // 添加记录到列表中
  putFileInfoToDownloadList(fileInfo: FileInfo, isJump: boolean = true,
    newFileFolderVm?: NewFileFolderOperationSelectVM) {
    this.downloadFileProgressingList.push(fileInfo)
    TCLogger.info(this.logTag,
      'Add downloadFileUpdate: ' + fileInfo.name + ', progress: ' + (fileInfo.progress / fileInfo.fileSizeByte * 100) +
        ', downloadFileUpdate: ' + JSON.stringify(this.downloadFileUpdate));
    // 修改文件传输状态
    this.downloadFileUpdate.index = this.downloadFileProgressingList.length - 1
    this.downloadFileUpdate.isNewAdd = true
    this.addFileToDownloadProgressingList()
    if (isJump) {
      if (newFileFolderVm) {
        // 隐藏上传文件上拉框
        newFileFolderVm.isShow = false
      }
      // 主动跳转文件传输页面
      this.jumpToFileTransferPage()
    }
  }

  /**
   * 添加下载进行中文件到列表中
   */
  addFileToDownloadProgressingList() {
    if (this.downloadFileUpdate.isNewAdd) {
      const item = this.downloadFileProgressingList[this.downloadFileUpdate.index]
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
      this.downloadProgressingFileType.push(progressingFile)
    }
    // 更新进行中的文件
    const item = this.downloadFileProgressingList[this.downloadFileUpdate.index]
    const itemName = item.name.split('/').pop() as string
    for (let index = 0; index < this.downloadProgressingFileType.length; index++) {
      const progressingFile = this.downloadProgressingFileType[index]
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
        this.handleDownloadProgressingFile(progressingFile, item)
        break;
      }
    }
  }

  // 传输完成，结果：已完成、任务失败
  handleDownloadProgressingFile(progressingFile: ProgressingFileType, item: FileInfo) {
    if (progressingFile.progress === 100 && item.isCompleted === true && item.isSucceed === true) {
      this.downloadProgressingFileType =
        this.downloadProgressingFileType.filter((item) => item.name !== progressingFile.name)
      // 避免Mock数据没同步，需要重新获取数据
      MockService.fileTransferDownloadProgressingList = this.downloadProgressingFileType
      // 加到已完成列表
      this.downloadSelectVM.fileList.push(item)
    } else if (item.isCompleted === true && item.isSucceed === false) {
      this.downloadProgressingFileType =
        this.downloadProgressingFileType.filter((item) => item.name !== progressingFile.name)
      // 加入到任务失败列表
      const failedFile: FailedFileType = new FailedFileType()
      failedFile.name = progressingFile.name
      failedFile.img = progressingFile.img
      failedFile.des = '下载失败'
      failedFile.isRetry = false
      failedFile.path = progressingFile.path
      this.downloadFailedFileType.push(failedFile)
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