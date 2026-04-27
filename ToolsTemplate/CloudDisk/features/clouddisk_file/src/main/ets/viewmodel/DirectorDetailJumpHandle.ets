import {
  Constants, FileInfo, GlobalContext, RouterMap,
} from 'common';
import { phoneRouterControl } from 'oh_router';
import { DirectorDetailPageBuilder } from '../pages/DirectorDetailPage';
import { FileTransferManagerPageBuilder } from '../pages/FileTransferManagerPage';
import { FileTransferManagerPageVM } from './FileTransferManagerPageVM';
import { FileManagerPageVM } from './FileManagerPageVM';

// 部分通用能力提取处理避免循环引用，主要是上传、下载
@ObservedV2
export class DirectorDetailJumpHandle {
  // 文件根目录，移动文件需要用到
  private static _rootInstance: DirectorDetailJumpHandle;

  public static get rootInstance(): DirectorDetailJumpHandle {
    if (DirectorDetailJumpHandle._rootInstance === undefined) {
      DirectorDetailJumpHandle._rootInstance = new DirectorDetailJumpHandle()
    }
    return DirectorDetailJumpHandle._rootInstance;
  }

  public initalWithContext() {
    // 目录列表详情
    GlobalContext.getUIContext().getHostContext()?.eventHub.on(Constants.JUMPTO_DIRECTORPAGE_KEY,
      (fileInfo: FileInfo) => {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.DIRECTOR_DETAIL_PAGE,
          builder: wrapBuilder(DirectorDetailPageBuilder),
          param: fileInfo
        })
      })

    // 文件传输页面
    GlobalContext.getUIContext().getHostContext()?.eventHub.on(Constants.JUMPTO_FILETRANSFERMANAGERPAGE_KEY,
      () => {
        // 绑定vm操作对象
        phoneRouterControl.jumpPage({
          pageName: RouterMap.FILE_TRANSFER_MANAGER_PAGE,
          builder: wrapBuilder(FileTransferManagerPageBuilder),
        })
      })

    // 文件传输状态
    GlobalContext.getUIContext().getHostContext()?.eventHub.on(Constants.FILETRANSFERSTATUS_KEY,
      (status: string) => {
        FileTransferManagerPageVM.rootInstance.selectedCompleteStatus = status
        if (status === '进行中') {
          FileTransferManagerPageVM.rootInstance.selectedTabTitle = '上传'
        }
      })

    // 添加文件
    GlobalContext.getUIContext().getHostContext()?.eventHub.on(Constants.ADDFILELIST_KEY,
      (fileList: FileInfo[]) => {
        FileManagerPageVM.rootInstance.addFileToCurrentList(fileList)
      })
  }
}