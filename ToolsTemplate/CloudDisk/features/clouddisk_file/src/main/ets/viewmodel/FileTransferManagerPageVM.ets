import { PersistenceV2 } from '@kit.ArkUI';
import { FileTransferUploadPageVM } from './FileTransferUploadPageVM';
import { FileTransferDownloadPageVM } from './FileTransferDownloadPageVM';
import { FileInfo, UserInfo } from 'common';

/**
 * 全部和已完成文件类型
 */
export interface AllAndCompletedFileType {
  name: string,
  img: ResourceStr,
  des: string,
  isSelected: boolean
}

@ObservedV2
export class FileTransferManagerPageVM {
  private static _rootInstance: FileTransferManagerPageVM;

  public static get rootInstance(): FileTransferManagerPageVM {
    if (FileTransferManagerPageVM._rootInstance === undefined) {
      FileTransferManagerPageVM._rootInstance = new FileTransferManagerPageVM()
    }
    return FileTransferManagerPageVM._rootInstance;
  }

  // 上传文件页面VM
  @Trace fileTransferUploadPageVM: FileTransferUploadPageVM = FileTransferUploadPageVM.rootInstance
  // 下载文件页面VM
  @Trace fileTransferDownloadPageVM: FileTransferDownloadPageVM = FileTransferDownloadPageVM.rootInstance
  // 当前选中tab标签
  @Trace selectedTabTitle: string = '上传'
  // 完成状态标签数组
  completeStatusArray: string[] = ['全部', '已完成', '进行中', '任务失败']
  // 选中的完成状态标签
  @Trace selectedCompleteStatus: string = '进行中'
  @Trace downloadSelectedCompleteStatus: string = '进行中'
  // 全局用户信息对象
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  // 删除上传所有文件的对话框id
  @Trace deleteAllDialogId: number = 1003
  // 删除下载所有文件的对话框id
  @Trace deleteDownloadAllDialogId: number = 1004

  // 根据FileId更新上传 和 下载文件列表中的parenFileId
  public updateFileListParentFileId(fileInfo: FileInfo) {
    // 上传
    this.fileTransferUploadPageVM.selectVM.fileList.forEach(file => {
      if (file.fileId === fileInfo.fileId) {
        file.parentFileId = fileInfo.parentFileId
      }
    })
    // 下载
    this.fileTransferDownloadPageVM.downloadSelectVM.fileList.forEach(file => {
      if (file.fileId === fileInfo.fileId) {
        file.parentFileId = fileInfo.parentFileId
      }
    })
  }
}