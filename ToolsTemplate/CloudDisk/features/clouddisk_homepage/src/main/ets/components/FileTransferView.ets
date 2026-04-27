import { FileOperationType, OperationSelect, OperationSelectVM } from 'clouddisk_file_operation';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { FileListSelectView } from 'clouddisk_file_select';
import { MainPageVM } from '../viewmodel/MainPageVM';
import { phoneRouterControl } from 'oh_router';
import {
  FileType, GlobalContext, FileInfo, PreferenceConstant, PreferenceUtil,
  RouterMap, TCLogger, UserInfo, MockService } from 'common';
import { FileTransferManagerPageVM } from 'clouddisk_file';
import {
  SettingPrivateSpacePasswordPageBuilder
} from 'clouddisk_file/src/main/ets/pages/SettingPrivateSpacePasswordPage';
import {
  MoveDirectorFirstPageBuilder, MoveDirectorFirstPageParam
} from 'clouddisk_file/src/main/ets/pages/MoveDirectorFirstPage';
import { VipCenterPageBuilder } from 'collect_personal_info';
import { PersistenceV2 } from '@kit.ArkUI';
import { FileManagerPageVM } from 'clouddisk_file/src/main/ets/viewmodel/FileManagerPageVM';

const TAG: string = 'FileTransferView';

/**
 * @usage: 用于首页文件列表展示和文件操作场景。提供文件列表选择、文件操作（下载、删除、分享、重命名）、
 * 文件预览等功能。关键数据结构：MainPageVM（主页视图模型，包含selectVM文件选择视图模型、
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
 * @zhName: 文件传输视图组件
 * @component: FileListSelectView,OperationSelect
 */
@ComponentV2
export struct FileTransferView {
  @Param @Require vm: MainPageVM
  operationVM: OperationSelectVM = new OperationSelectVM([FileOperationType.Download,
    FileOperationType.Delete, FileOperationType.Share, FileOperationType.Rename, FileOperationType.Move,
    FileOperationType.MoveToPrivateSpace, FileOperationType.Collect
  ])
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  aboutToAppear(): void {
    // 注册选择文件事件
    this.fileOperationEventInitial()
  }

  // 文件选择回调初始化
  private fileOperationEventInitial() {
    // 选中某一项
    this.vm.selectVM.didSelectedAtIndexAction = (atIdx: number) => {
      // 控制底部弹框是否出现
      const operationIsVisible: boolean = (this.vm.selectVM.selectedIndexes.size > 0) ? true : false
      if (operationIsVisible !== this.vm.isShowOperation) {
        this.vm.isShowOperation = operationIsVisible
      }

      if (operationIsVisible) {
        this.operationVM.updateFileList(this.vm.selectVM.getAllSelected())
      }
    }

    // 全选、反选按钮
    this.vm.selectVM.changeAllSelectedAction = (isChecked: boolean) => {
      this.vm.isShowOperation = isChecked

      if (isChecked) {
        this.operationVM.updateFileList(this.vm.selectVM.fileList)
      }
    }

    // 单击某项文件
    this.vm.selectVM.didClickAtIndexAction = (clickIdx: number) => {
      // 非目录 or 隐私空间
      if (this.vm.selectVM.fileList[clickIdx].fileType !== FileType.Director &&
        this.vm.selectVM.fileList[clickIdx].fileType !== FileType.PrivateSpace) {
        const fileInfo: FileInfo = this.vm.selectVM.fileList[clickIdx]
        FileManagerPageVM.routerToFileDetail(fileInfo)
        // 隐藏下方的操作栏
        this.vm.isShowOperation = false
        return
      }

      // 隐私空间判断
      if (this.vm.selectVM.fileList[clickIdx].fileType === FileType.PrivateSpace) {
        if (!this.canOpenPrivateSpace()) {
          TCLogger.warn(TAG, 'privatespace now not opened, goto open')
          return
        }

        // 已开启隐私空间
        FileManagerPageVM.routerToPrivateSpace(MockService.privateSpaceInfo)
        return
      }
    }

    // 弹框操作项参数回调
    this.operationVM.didSelectEvent = (operationType: FileOperationType) => {
      if (operationType === FileOperationType.Collect) {
        hilog.warn(0x000, 'FileTransferUploadView', 'collected is changed')
        return
      }

      switch (operationType) {
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
          if (!this.canOpenPrivateSpace()) {
            TCLogger.warn(TAG, 'privatespace now not opened, goto open')
          } else {
            this.startToMoveToPrivateSpace()
          }
        }
          break;
        case FileOperationType.Move: {
          this.startToMoveFileList()
        }
          break;
        case FileOperationType.Download: {
          this.startToMoveFileList()
        }
          break;
        case FileOperationType.Rename: {
          // clear
          this.vm.selectVM.selectedIndexes.clear()
        }
          break;
        default:
          break;
      }

      // hiddle operation
      this.vm.isShowOperation = false
    }
  }

  // 下载文件
  private startToDownloadFileList() {
    const checkedList: FileInfo[] = this.vm.selectVM.getAllSelected()
    this.vm.selectVM.selectedIndexes.clear()
    checkedList.forEach((item) => {
      FileTransferManagerPageVM.rootInstance.fileTransferDownloadPageVM.startDownloadFileTask(item)
    })
  }

  // 移动文件
  private startToMoveFileList() {
    const ids: number[] = this.operationVM.checkedFileIds()
    const moveParam: MoveDirectorFirstPageParam = {
      fileIds: ids,
      completeAction: (fileIds: number[]) => {
        // 移动文件
        let targetInfo: FileInfo | undefined = undefined
        for (let i = 0; i < fileIds.length; i++) {
          const tmpId = fileIds[i]
          const tmpList: FileInfo[] = (targetInfo !== undefined) ? (targetInfo as FileInfo).contentList :
          MockService.currentFileList
          for (let j = 0; j < tmpList.length; j++) {
            if (tmpList[j].fileId === tmpId) {
              targetInfo = tmpList[j]
              break
            }
          }
        }

        const selectedItems: FileInfo[] = this.vm.selectVM.getAllSelected()
        if (targetInfo !== undefined) {
          if (targetInfo.fileType === FileType.PrivateSpace) {
            MockService.addFileListToPrivateSpaceHomePage(selectedItems)
          } else {
            MockService.addFileListToTargetList(selectedItems, targetInfo.contentList)
            selectedItems.forEach((item) => {
              // 移动到根目录
              item.parentFileId = targetInfo!.fileId
              // 同时更新文件传输页面列表元素的parentFileId
              FileTransferManagerPageVM.rootInstance.updateFileListParentFileId(item)
            })
          }
        } else {
          // 添加到目标目录
          MockService.addFileListToTargetList(selectedItems, MockService.currentFileList)
          selectedItems.forEach((item) => {
            item.parentFileId = 0
          })
        }
      },
      backDirectionAction: () => {
        // 直接返回
        this.vm.isShowOperation = true
      }
    }
    phoneRouterControl.jumpPage({
      builder: wrapBuilder(MoveDirectorFirstPageBuilder),
      pageName: RouterMap.MOVE_FILE_FIRST_PAGE,
      param: moveParam
    })
  }

  // 移入到隐私空间
  private startToMoveToPrivateSpace() {
    GlobalContext.getUIContext().showAlertDialog({
      message: $r('app.string.private_space_move_tip'),
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      alignment: DialogAlignment.Center,
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          action: () => {
          }
        },
        {
          value: $r('app.string.sure'),
          action: () => {
            const checkedList = this.vm.selectVM.getAllSelected()
            MockService.deleteFileListFromTargetList(checkedList, MockService.allFileList)
            MockService.addFileListToPrivateSpaceHomePage(checkedList)
            MockService.deleteFileListFromTargetList(checkedList, MockService.currentFileList)
            this.vm.selectVM.deleteAllSelected()
          }
        }
      ],
      showInSubWindow: true,
      isModal: true,
      autoCancel: false,
    })
  }

  // 开启隐私空间
  private canOpenPrivateSpace(): boolean {
    if (!PreferenceUtil.getInstance().has(PreferenceConstant.PRIVATE_SPACE_PASSWORD_KEY)) {
      this.showTipDialog($r('app.string.open_private_space_message'), $r('app.string.dialog_sure_open'), () => {
        if (this.userInfo.isVip) {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.OPEN_PRIVATE_SPACE_PAGE,
            builder: wrapBuilder(SettingPrivateSpacePasswordPageBuilder),
          })

          this.vm.isShow = false
        } else {
          this.showTipDialog($r('app.string.upgrade_open_private_space'), $r('app.string.goto_upgrade'), () => {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.VIP_CENTER_PAGE,
              builder: wrapBuilder(VipCenterPageBuilder)
            })
            this.vm.isShow = false
          })

        }
      })
      return false
    }

    // 已经开启了
    return true
  }

  private showTipDialog(showMsg: ResourceStr, btnText: ResourceStr, sureAction: () => void) {
    GlobalContext.getUIContext().showAlertDialog({
      message: showMsg,
      autoCancel: false,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          action: () => {
          }
        },
        {
          value: btnText,
          action: () => {
            sureAction()
          }
        }
      ]
    })
  }

  @Builder
  controlFileSheet() {
    OperationSelect({ vm: this.operationVM, bgColor: '#FFFFFF' })
  }

  build() {
    Column() {
      FileListSelectView({ vm: this.vm.selectVM, selectRowBgColor: '#FFFFFF' })
        .width('100%')
        .layoutWeight(1)
    }
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .bindSheet($$this.vm.isShowOperation, this.controlFileSheet(),
      {
        showClose: false,
        maskColor: Color.Transparent,
        radius: { topLeft: 0, topRight: 0 },
        height: 40 + 48 * 2,
        enableOutsideInteractive: true,
        preferType: SheetType.BOTTOM
      })
  }
}