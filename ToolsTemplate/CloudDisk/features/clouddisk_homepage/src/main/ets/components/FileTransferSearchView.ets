import { FileOperationType, OperationSelect, OperationSelectVM } from 'clouddisk_file_operation';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { FileListSelectView } from 'clouddisk_file_select';
import { phoneRouterControl } from 'oh_router';
import { TCLogger,FileInfo, PreferenceConstant, FileType, GlobalContext, MockService, PreferenceUtil,
  RouterMap, UserInfo
} from 'common';
import { FileTransferManagerPageVM } from 'clouddisk_file';
import { FileManagerPageVM } from 'clouddisk_file/src/main/ets/viewmodel/FileManagerPageVM';
import { SearchPageVM } from '../viewmodel/SearchPageVM';
import { PersistenceV2 } from '@kit.ArkUI';
import {
  SettingPrivateSpacePasswordPageBuilder
} from 'clouddisk_file/src/main/ets/pages/SettingPrivateSpacePasswordPage';
import {
  MoveDirectorFirstPageBuilder,
  MoveDirectorFirstPageParam
} from 'clouddisk_file/src/main/ets/pages/MoveDirectorFirstPage';
import { VipCenterPageBuilder } from 'collect_personal_info';

const TAG: string = 'FileTransferSearchView';

/**
 * @usage: 用于搜索结果展示和文件操作场景。提供文件列表选择、文件操作（下载、删除、分享、重命名）、
 * 文件预览等功能。关键数据结构：SearchPageVM（搜索页面视图模型，包含selectVM文件选择视图模型、
 * isShowOperation是否显示操作弹框布尔值）、OperationSelectVM（操作选择视图模型）、FileInfo（文件信息）、
 * FileType（文件类型枚举，包含Director目录、PrivateSpace隐私空间）、FileOperationType（操作类型枚举，
 * 包含Download下载、Delete删除、Share分享、Rename重命名、Collect收藏）。
 * 包含if逻辑：根据文件类型判断是否跳转详情页（非目录和隐私空间跳转详情页），根据操作类型执行不同操作。
 * @layout: 垂直布局。主体为FileListSelectView文件列表选择视图（占据全部空间），
 * 底部绑定操作弹框（选中文件时显示，包含下载、删除、分享、重命名操作按钮）。
 * @constraints: vm.selectVM文件选择视图模型不能为空，文件操作回调函数必须正确处理，
 * 下载和删除操作必须正确更新文件列表
 * @isGen: true
 * @fileType: component
 * @zhName: 文件搜索视图组件
 * @component: FileListSelectView,OperationSelect
 */
@ComponentV2
export struct FileTransferSearchView {
  @Param @Require vm: SearchPageVM
  operationVM: OperationSelectVM = new OperationSelectVM([
    FileOperationType.Download, FileOperationType.Delete,
    FileOperationType.Share, FileOperationType.Rename,
    FileOperationType.Move, FileOperationType.MoveToPrivateSpace,
    FileOperationType.Collect])
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  aboutToAppear(): void {
    // 注册选择文件事件
    this.registerOperationEvent()
  }

  // 文件选择回调初始化
  private registerOperationEvent() {
    // 选中
    this.vm.selectVM.didSelectedAtIndexAction = () => {
      // 控制底部弹框是否出现
      const isShowBottomView: boolean = (this.vm.selectVM.selectedIndexes.size > 0) ? true : false
      if (isShowBottomView !== this.vm.isShowOperation) {
        this.vm.isShowOperation = isShowBottomView
      }

      if (isShowBottomView) {
        this.operationVM.updateFileList(this.vm.selectVM.getAllSelected())
      }
    }
    // 全选、反选切换
    this.vm.selectVM.changeAllSelectedAction = (isShowBottomView: boolean) => {
      this.vm.isShowOperation = isShowBottomView

      if (isShowBottomView) {
        this.operationVM.updateFileList(this.vm.selectVM.fileList)
      }
    }

    // 点击整行
    this.vm.selectVM.didClickAtIndexAction = (rowIndex: number) => {
      // 非目录&隐私空间
      if (this.vm.selectVM.fileList[rowIndex].fileType !== FileType.Director &&
        this.vm.selectVM.fileList[rowIndex].fileType !== FileType.PrivateSpace) {
        const fileInfo: FileInfo = this.vm.selectVM.fileList[rowIndex]
        FileManagerPageVM.routerToFileDetail(fileInfo)
        this.vm.isShowOperation = false
        return
      }

      // 隐私空间
      if (this.vm.selectVM.fileList[rowIndex].fileType === FileType.PrivateSpace) {
        if (!this.openedPrivateSpace()) {
          TCLogger.warn(TAG, 'privatespace not opened, goto open at classification')
          return
        }

        // 已开启隐私空间
        FileManagerPageVM.routerToPrivateSpace(MockService.privateSpaceInfo)
        return
      }
    }
    // 弹框操作项参数
    this.operationVM.didSelectEvent = (type: FileOperationType) => {
      if (type === FileOperationType.Collect) {
        // 收藏
        hilog.warn(0x000, 'FileTransferUploadView', 'collected is changed')
        return
      }

      switch (type) {
        case FileOperationType.Delete: {
          const timeStamp = Date.now()
          const fileList: FileInfo[] = this.vm.selectVM.getAllSelected()
          fileList.forEach((item) => {
            item.deletetime = timeStamp
          })
          MockService.deleteFileListFromTargetList(fileList, MockService.allFileList)
          MockService.deleteFileListFromTargetList(fileList, MockService.currentFileList)
          MockService.addFileListToTargetList(fileList, MockService.recycleBinFileList)
          this.vm.selectVM.deleteAllSelected()
        }
          break;
        case FileOperationType.MoveToPrivateSpace: {
          if (!this.openedPrivateSpace()) {
            TCLogger.warn(TAG, 'privatespace not opened, goto open at classification')
          } else {
            this.moveToPrivateSpace()
          }
        }
          break;
        case FileOperationType.Move: {
          // 移动文件
          this.moveFileList()
        }
          break;
        case FileOperationType.Download: {
          // 下载
          this.downloadFileList()
        }
          break;
        case FileOperationType.Rename: {
          // 重命名
          this.vm.selectVM.selectedIndexes.clear()
        }
          break;
        default:
          break;
      }

      // 隐藏底部栏
      this.vm.isShowOperation = false
    }
  }

  // 下载文件
  private downloadFileList() {
    const downloadList: FileInfo[] = this.vm.selectVM.getAllSelected()
    this.vm.selectVM.selectedIndexes.clear()
    downloadList.forEach((item) => {
      FileTransferManagerPageVM.rootInstance.fileTransferDownloadPageVM.startDownloadFileTask(item)
    })
  }

  // 移动文件到指定目录
  private moveFileList() {
    const moveIds: number[] = this.operationVM.checkedFileIds()
    const param: MoveDirectorFirstPageParam = {
      fileIds: moveIds,
      completeAction: (fileIds: number[]) => {
        // 移动文件
        let tmpInfo: FileInfo | undefined = undefined
        for (let i = 0; i < fileIds.length; i++) {
          const tmpId = fileIds[i]
          const tmpList: FileInfo[] = (tmpInfo !== undefined) ? (tmpInfo as FileInfo).contentList :
          MockService.currentFileList
          for (let j = 0; j < tmpList.length; j++) {
            if (tmpList[j].fileId === tmpId) {
              tmpInfo = tmpList[j]
              break
            }

          }
        }

        const tmpItems: FileInfo[] = this.vm.selectVM.getAllSelected()
        tmpItems.forEach((item) => {
          if (tmpInfo !== undefined) {
            (tmpInfo as FileInfo).contentList.push(item)
          } else {
            FileManagerPageVM.rootInstance.addFileToCurrentList([item])
          }
        })
      },
      backDirectionAction: () => {
        // 隐藏底部栏
        this.vm.isShowOperation = true
      }
    }
    // 跳转路由
    phoneRouterControl.jumpPage({
      pageName: RouterMap.MOVE_FILE_FIRST_PAGE,
      param: param,
      builder: wrapBuilder(MoveDirectorFirstPageBuilder)
    })
  }

  // 移入隐私空间
  private moveToPrivateSpace() {
    GlobalContext.getUIContext().showAlertDialog({
      message: $r('app.string.private_space_move_tip'),
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          action: () => {
          }
        },
        {
          value: $r('app.string.sure'),
          action: () => {
            const tmpList = this.vm.selectVM.getAllSelected()
            MockService.deleteFileListFromTargetList(tmpList, MockService.allFileList)
            MockService.addFileListToPrivateSpaceHomePage(tmpList)
            MockService.deleteFileListFromTargetList(tmpList, MockService.currentFileList)
            this.vm.selectVM.deleteAllSelected()
          }
        }
      ],
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      autoCancel: false,
    })
  }

  // 开启隐私空间
  private openedPrivateSpace(): boolean {
    if (!PreferenceUtil.getInstance().has(PreferenceConstant.PRIVATE_SPACE_PASSWORD_KEY)) {
      this.showDialog($r('app.string.open_private_space_message'), $r('app.string.dialog_sure_open'), () => {
        if (this.userInfo.isVip) {
          // vip
          phoneRouterControl.jumpPage({
            pageName: RouterMap.OPEN_PRIVATE_SPACE_PAGE,
            builder: wrapBuilder(SettingPrivateSpacePasswordPageBuilder),
          })
          // 隐藏操作栏
          this.vm.isShow = false
        } else {
          this.showDialog($r('app.string.upgrade_open_private_space'), $r('app.string.goto_upgrade'), () => {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.VIP_CENTER_PAGE,
              builder: wrapBuilder(VipCenterPageBuilder)
            })
            // 隐藏操作栏
            this.vm.isShow = false
          })

        }
      })
      return false
    }

    return true
  }


  private showDialog(dialogMsg: ResourceStr, dialogSureText: ResourceStr, dialogSureAction: () => void) {
    GlobalContext.getUIContext().showAlertDialog({
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      message: dialogMsg,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          action: () => {
          }
        },
        {
          value: dialogSureText,
          action: () => {
            dialogSureAction()
          }
        }
      ]
    })

  }

  @Builder
  bottomFileSheet() {
    OperationSelect({ vm: this.operationVM, bgColor: '#FFFFFF' })
  }

  build() {
    Column() {
      FileListSelectView({ vm: this.vm.selectVM, selectRowBgColor: '#FFFFFF' })
        .width('100%')
        .layoutWeight(1)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .bindSheet($$this.vm.isShowOperation, this.bottomFileSheet(),
      {
        showClose: false,
        maskColor: Color.Transparent,
        radius: { topLeft: 0, topRight: 0 },
        preferType: SheetType.BOTTOM,
        enableOutsideInteractive: true,
        height: 40 + 48 * 2
      })
  }
}