import { FileOperationType, OperationSelect, OperationSelectVM } from 'clouddisk_file_operation';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { FileListSelectView } from 'clouddisk_file_select';
import { phoneRouterControl } from 'oh_router';
import { FileTransferManagerPageVM } from 'clouddisk_file';
import { FileInfo, FileType, GlobalContext, MockService, PreferenceConstant, PreferenceUtil, RouterMap,
  TCLogger, UserInfo } from 'common';
import { SearchClassificationPageVM } from '../viewmodel/SearchClassificationPageVM';
import { PersistenceV2 } from '@kit.ArkUI';
import { MoveDirectorFirstPageBuilder, MoveDirectorFirstPageParam
} from 'clouddisk_file/src/main/ets/pages/MoveDirectorFirstPage';
import { FileManagerPageVM } from 'clouddisk_file/src/main/ets/viewmodel/FileManagerPageVM';
import { SettingPrivateSpacePasswordPageBuilder
} from 'clouddisk_file/src/main/ets/pages/SettingPrivateSpacePasswordPage';
import { VipCenterPageBuilder } from 'collect_personal_info';

const TAG: string = 'FileTransferSearchClassificationView';

/**
 * @usage: 用于搜索分类结果展示和文件操作场景。提供文件列表选择、文件操作（下载、删除、分享、重命名）、
 * 文件预览等功能。关键数据结构：SearchClassificationPageVM（搜索分类页面视图模型，包含selectVM文件选择视图模型、
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
 * @zhName: 文件搜索分类视图组件
 * @component: FileListSelectView,OperationSelect
 */
@ComponentV2
export struct FileTransferSearchClassificationView {
  @Param @Require vm: SearchClassificationPageVM
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  operationVM: OperationSelectVM = new OperationSelectVM([
    FileOperationType.Download, FileOperationType.Delete, FileOperationType.Share,
    FileOperationType.Rename, FileOperationType.Move, FileOperationType.MoveToPrivateSpace,
    FileOperationType.Collect])

  aboutToAppear(): void {
    // 注册选择文件事件
    this.initialOperationEvent()
  }

  // 文件选择回调初始化
  private initialOperationEvent() {
    // 选中某一项
    this.vm.selectVM.didSelectedAtIndexAction = (_idx: number) => {
      // 底部弹框是否出现
      const shouldVisible: boolean = (this.vm.selectVM.selectedIndexes.size > 0) ? true : false
      if (shouldVisible !== this.vm.isShowOperation) {
        this.vm.isShowOperation = shouldVisible
      }

      if (shouldVisible) {
        this.operationVM.updateFileList(this.vm.selectVM.getAllSelected())
      }
    }

    // 切换全选、反选
    this.vm.selectVM.changeAllSelectedAction = (isSelected: boolean) => {
      this.vm.isShowOperation = isSelected

      if (isSelected) {
        this.operationVM.updateFileList(this.vm.selectVM.fileList)
      }
    }

    // 单击行
    this.vm.selectVM.didClickAtIndexAction = (idx: number) => {
      // 非目录 or 隐私空间
      if (this.vm.selectVM.fileList[idx].fileType !== FileType.Director &&
        this.vm.selectVM.fileList[idx].fileType !== FileType.PrivateSpace) {

        const item: FileInfo = this.vm.selectVM.fileList[idx]
        FileManagerPageVM.routerToFileDetail(item)
        this.vm.isShowOperation = false // 隐藏下方的操作栏
        return
      }

      // 隐私空间
      if (this.vm.selectVM.fileList[idx].fileType === FileType.PrivateSpace) {
        if (!this.openPrivateSpace()) {
          TCLogger.warn(TAG, 'privatespace not opened, jump to open')
          return
        }

        // 隐私空间已开启
        FileManagerPageVM.routerToPrivateSpace(MockService.privateSpaceInfo)
        return
      }
    }

    // 弹框操作项
    this.operationVM.didSelectEvent = (checkedType: FileOperationType) => {
      if (checkedType === FileOperationType.Collect) {
        hilog.warn(0x000, 'FileTransferUploadView', 'collected now is changed')
        return
      }

      switch (checkedType) {
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
          if (!this.openPrivateSpace()) {
            TCLogger.warn(TAG, 'privatespace not opened, jump to open')
          } else {
            // move to space
            this.beginToMoveToPrivateSpace()
          }
        }
          break;
        case FileOperationType.Move: {
          // move file
          this.beginToMoveFileList()
        }
          break;
        case FileOperationType.Download: {
          // download
          this.beginToDownloadFileList()
        }
          break;
        case FileOperationType.Rename: {
          // rename
          this.vm.selectVM.selectedIndexes.clear()
        }
          break;
        default:
          // default
          break;
      }

      // close items
      this.vm.isShowOperation = false
    }
  }

  // 下载文件
  private beginToDownloadFileList() {
    const selectedItems: FileInfo[] = this.vm.selectVM.getAllSelected()
    this.vm.selectVM.selectedIndexes.clear()
    selectedItems.forEach((item) => {
      FileTransferManagerPageVM.rootInstance.fileTransferDownloadPageVM.startDownloadFileTask(item)
    })
  }

  // 移动文件
  private beginToMoveFileList() {
    const currentIds: number[] = this.operationVM.checkedFileIds()
    const param: MoveDirectorFirstPageParam = {
      fileIds: currentIds,
      completeAction: (toFileIds: number[]) => {
        // 移动文件
        let currentInfo: FileInfo | undefined = undefined
        for (let i = 0; i < toFileIds.length; i++) {
          const tmpId = toFileIds[i]
          const tmpList: FileInfo[] = (currentInfo !== undefined) ? (currentInfo as FileInfo).contentList :
          MockService.currentFileList
          for (let k = 0; k < tmpList.length; k++) {
            if (tmpList[k].fileId === tmpId) {
              currentInfo = tmpList[k]
              break
            }
          }
        }

        //
        const allSelectedItems: FileInfo[] = this.vm.selectVM.getAllSelected()
        if (currentInfo !== undefined) {
          if (currentInfo.fileType === FileType.PrivateSpace) {
            MockService.addFileListToPrivateSpaceHomePage(allSelectedItems)
          } else {
            MockService.addFileListToTargetList(allSelectedItems, currentInfo.contentList)
            allSelectedItems.forEach((item) => {
              // 移动到根目录,同时更新文件传输页面列表元素的parentFileId
              item.parentFileId = currentInfo!.fileId
              FileTransferManagerPageVM.rootInstance.updateFileListParentFileId(item)
            })
          }
        } else {
          MockService.addFileListToTargetList(allSelectedItems, MockService.currentFileList)
          // 移动到根目录
          allSelectedItems.forEach((item) => {
            item.parentFileId = 0
          })
        }
      },
      backDirectionAction: () => {
        // 返回
        this.vm.isShowOperation = true
      }
    }

    // 跳转
    phoneRouterControl.jumpPage({
      param: param,
      pageName: RouterMap.MOVE_FILE_FIRST_PAGE,
      builder: wrapBuilder(MoveDirectorFirstPageBuilder)
    })
  }

  // 移入到隐私空间
  private beginToMoveToPrivateSpace() {
    GlobalContext.getUIContext().showAlertDialog({
      showInSubWindow: true,
      message: $r('app.string.private_space_move_tip'),
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      isModal: true,
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          action: () => {
          }
        },
        {
          value: $r('app.string.sure'),
          action: () => {
            const selectedItems = this.vm.selectVM.getAllSelected()
            MockService.deleteFileListFromTargetList(selectedItems, MockService.allFileList)
            MockService.addFileListToPrivateSpaceHomePage(selectedItems)
            MockService.deleteFileListFromTargetList(selectedItems, MockService.currentFileList)
            this.vm.selectVM.deleteAllSelected()
          }
        }
      ]
    })
  }

  // 隐私空间开启判断
  private openPrivateSpace(): boolean {
    // 判断能否打开隐私空间
    if (!PreferenceUtil.getInstance().has(PreferenceConstant.PRIVATE_SPACE_PASSWORD_KEY)) {
      this.showTipDialog($r('app.string.open_private_space_message'), $r('app.string.dialog_sure_open'), () => {
        if (this.userInfo.isVip) {
          // 路由跳转
          phoneRouterControl.jumpPage({
            builder: wrapBuilder(SettingPrivateSpacePasswordPageBuilder),
            pageName: RouterMap.OPEN_PRIVATE_SPACE_PAGE,
          })
          this.vm.isShow = false
        } else {
          this.showTipDialog($r('app.string.upgrade_open_private_space'), $r('app.string.goto_upgrade'), () => {
            phoneRouterControl.jumpPage({
              builder: wrapBuilder(VipCenterPageBuilder),
              pageName: RouterMap.VIP_CENTER_PAGE,
            })
            this.vm.isShow = false
          })
        }
      })
      return false
    }

    // 已开启
    return true
  }

  // 弹框
  private showTipDialog(message: ResourceStr, buttonText: ResourceStr, completedAction: () => void) {
    GlobalContext.getUIContext().showAlertDialog({
      message: message,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      showInSubWindow: true,
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          action: () => {}
        },
        {
          value: buttonText,
          action: () => {
            completedAction()
          }
        }
      ]
    })

  }

  @Builder
  showOperationSelect() {
    OperationSelect({ vm: this.operationVM, bgColor: '#FFFFFF' })
  }

  build() {
    Column() {
      //
      FileListSelectView({ vm: this.vm.selectVM, selectRowBgColor: '#FFFFFF' })
        .width('100%')
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .bindSheet($$this.vm.isShowOperation, this.showOperationSelect(),
      {
        showClose: false,
        maskColor: Color.Transparent,
        height: 40 + 48 * 2,
        enableOutsideInteractive: true,
        preferType: SheetType.BOTTOM,
        radius: { topLeft: 0, topRight: 0 }
      })
  }
}