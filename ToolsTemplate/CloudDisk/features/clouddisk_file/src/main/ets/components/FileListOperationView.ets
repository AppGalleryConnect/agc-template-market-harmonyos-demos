import { FileOperationType, OperationSelect, OperationSelectVM } from 'clouddisk_file_operation';

import { DirectorDetailPageVM } from '../viewmodel/DirectorDetailPageVM';
import { PersistenceV2, promptAction } from '@kit.ArkUI';
import { FileListSelectView } from 'clouddisk_file_select';
import {
  TCLogger,
  FileInfo,
  RouterMap,
  FileType,
  GlobalContext,
  MockService,
  PreferenceConstant,
  PreferenceUtil,
  UserInfo,
  Constants
} from 'common';
import { phoneRouterControl } from 'oh_router';
import { SettingPrivateSpacePasswordPageBuilder } from '../pages/SettingPrivateSpacePasswordPage';
import { MoveDirectorFirstPageBuilder, MoveDirectorFirstPageParam } from '../pages/MoveDirectorFirstPage';
import { VipCenterPageBuilder } from 'collect_personal_info';
import { FileTransferManagerPageVM } from '../viewmodel/FileTransferManagerPageVM';
import { FileManagerPageVM } from '../viewmodel/FileManagerPageVM';

const SORT_TAG: string = '排序'
const FILTER_TAG: string = '筛选'
const TAG: string = 'FileListOperationView';

/**
 * @usage: 用于文件列表操作和管理场景。提供文件排序、筛选、视图切换（列表/宫格）、文件操作
 * （下载、删除、分享、重命名、移动、移入隐私空间、收藏）等功能。关键数据结构：FileManagerPageVM
 * （文件管理页面视图模型）、OperationSelectVM（操作选择视图模型）、FileInfo（文件信息）、
 * FileType（文件类型枚举）、FileOperationType（操作类型枚举）、UserInfo（用户信息，包含isVip会员状态）。
 * 包含if逻辑：根据文件类型判断操作（非目录和隐私空间跳转详情页，隐私空间需验证密码），
 * 根据VIP状态判断是否可开启隐私空间，根据操作类型执行不同操作。
 * @layout: 垂直布局。顶部为操作栏（排序按钮、筛选按钮、视图切换按钮横向排列），
 * 第二行为筛选类型标签列表（筛选开启时显示），主体为FileListSelectView文件列表选择视图，
 * 底部绑定操作弹框（选中文件时显示）。
 * @constraints: vm文件管理视图模型不能为空，文件操作回调函数必须正确处理，
 * 隐私空间功能需要VIP权限，移动和删除操作必须正确更新文件列表
 * @isGen: true
 * @fileType: component
 * @zhName: 文件列表操作视图组件
 */
@ComponentV2
export struct FileListOperationView {
  @Require @Param vm: DirectorDetailPageVM
  operationVM: OperationSelectVM = new OperationSelectVM([
    FileOperationType.Download,
    FileOperationType.Delete,
    FileOperationType.Share,
    FileOperationType.Rename,
    FileOperationType.Move,
    FileOperationType.MoveToPrivateSpace,
    FileOperationType.Collect
  ])
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  // 标记是否在当前页面跳转开通了vip
  private isJumpToOpenVIP: boolean = false

  aboutToAppear(): void {
    // 选中某一项
    this.vm.selectVM.didSelectedAtIndexAction = (_: number) => {
      // 控制底部弹框是否出现
      const isVisible: boolean = (this.vm.selectVM.selectedIndexes.size > 0) ? true : false
      if (isVisible !== this.vm.isShow) {
        this.vm.isShow = isVisible
      }

      if (isVisible) {
        this.operationVM.updateFileList(this.vm.selectVM.getAllSelected())
      }
    }
    // 全选、反选切换
    this.vm.selectVM.changeAllSelectedAction = (isAllSelected: boolean) => {
      this.vm.isShow = isAllSelected

      if (isAllSelected) {
        this.operationVM.updateFileList(this.vm.selectVM.getAllSelected())
      }
    }
    // 单击某行
    this.vm.selectVM.didClickAtIndexAction = (index: number) => {
      // 非目录 or 隐私空间
      if (this.vm.selectVM.fileList[index].fileType !== FileType.Director &&
        this.vm.selectVM.fileList[index].fileType !== FileType.PrivateSpace) {
        FileManagerPageVM.routerToFileDetail(this.vm.selectVM.fileList[index])
        // 隐藏下方的操作栏
        this.vm.isShow = false
        return
      }

      // 隐私空间
      if (this.vm.selectVM.fileList[index].fileType === FileType.PrivateSpace) {
        if (!this.openPrivateSpace()) {
          TCLogger.warn(TAG, 'privatespace not opened, goto open')
          return
        }

        // 已开启隐私空间
        FileManagerPageVM.routerToPrivateSpace(MockService.privateSpaceInfo)
        return
      }

      this.vm.jumpToNextlevelDirector(index)

      if (this.vm.levelDirectorList.length === 0) {
        GlobalContext.getUIContext().getHostContext()?.eventHub.emit(Constants.JUMPTO_DIRECTORPAGE_KEY,
          this.vm.selectVM.fileList[index])
      }
    }
    // 弹框操作项参数
    this.operationVM.didSelectEvent = (type: FileOperationType) => {
      if (type === FileOperationType.Collect) {
        TCLogger.warn(TAG, 'collected is changed')
        return
      }

      switch (type) {
        case FileOperationType.Delete: {
          this.deleteFiles()
          return
        }
        case FileOperationType.MoveToPrivateSpace: {
          if (!this.openPrivateSpace()) {
            TCLogger.warn(TAG, 'privatespace not opened, goto open')
          } else {
            this.moveToPrivateSpace()
          }
        }
          break;
        case FileOperationType.Move: {
          this.moveFileList()
        }
          break;
        case FileOperationType.Download: {
          this.downloadFileList()
        }
          break;
        case FileOperationType.Rename: {
          this.vm.selectVM.selectedIndexes.clear()
        }
          break;
        default:
          break;
      }

      this.vm.isShow = false
    }
  }

  @Builder
  dealWithFileSheet() {
    OperationSelect({ vm: this.operationVM })
  }

  @Builder
  fileSortPopDialog() {
    Column() {
      ForEach(this.vm.sortList, (item: string, index: number) => {
        Text(item + SORT_TAG)
          .fontSize(14)
          .fontColor((this.vm.currentSortIndex === index) ? '#2FAFFF' : '#000000')
          .padding({ top: 12, bottom: 12 })
          .onClick(() => {
            this.vm.sortFileList(index)
            this.vm.isSortDialogVisible = false
          })
      }, (item: string, idx: number) => JSON.stringify(item) + idx)
    }
    .width(180)
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: 12,
      bottom: 12,
      left: 16,
      right: 16
    })
  }

  build() {
    Column() {
      Row() {
        // 排序方式
        Row() {
          Text(this.vm.sortList[this.vm.currentSortIndex] + SORT_TAG)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#999EA2')
          Image($r('app.media.sort_icon'))
            .width(16)
            .height(16)
            .objectFit(ImageFit.Contain)
            .margin({ left: 2 })
        }
        .onClick(() => {
          this.vm.isSortDialogVisible = true
        })
        .bindPopup(this.vm.isSortDialogVisible, {
          builder: this.fileSortPopDialog,
          placement: Placement.Bottom,
          popupColor: Color.White,
          enableArrow: false,
          radius: $r('sys.float.corner_radius_level10'),
          offset: { x: 10 },
          onStateChange: (e) => {
            if (!e.isVisible) {
              this.vm.isSortDialogVisible = false
            }
          }
        })


        Blank()

        // 筛选方式
        Row() {
          Text(FILTER_TAG)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.vm.isFilterSelected ? '#444444' : '#999EA2')
          Image(this.vm.isFilterSelected ? $r('app.media.filter_selected') : $r('app.media.filter_unselected'))
            .width(16)
            .height(16)
            .objectFit(ImageFit.Contain)
            .margin({ left: 2 })
        }
        .onClick(() => {
          this.vm.isFilterSelected = !this.vm.isFilterSelected
        })

        // 列表样式
        Image(this.vm.selectVM.isListVisibleGridMode ? $r('app.media.list_view_icon') : $r('app.media.grid_view_icon'))
          .width(16)
          .height(16)
          .objectFit(ImageFit.Contain)
          .margin({ left: 14 })
          .onClick(() => {
            this.vm.selectVM.isListVisibleGridMode = !this.vm.selectVM.isListVisibleGridMode
          })
      }
      .height(40)
      .width('100%')
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)

      // 文件筛选类型列表
      List({ space: 8 }) {
        ForEach(this.vm.fileTypeTitles, (item: string, index: number) => {
          ListItem() {
            Column() {
              Text(item)
                .fontSize(12)
                .fontColor((this.vm.fileTypeIndex === index) ? '#2FAFFF' : '#9DA3AA')
            }
            .width(48)
            .height(22)
            .borderRadius(8)
            .backgroundColor('#F0F9FF')
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              if (this.vm.fileTypeIndex === index) {
                return
              }

              this.vm.filterListBySelectedType(index)
            })
          }
        }, (item: string, idx: number) => JSON.stringify(item) + idx)
      }
      .width('100%')
      .height(38)
      .padding({
        left: 16,
        right: 16,
        top: 8,
        bottom: 8
      })
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .visibility(this.vm.isFilterSelected ? Visibility.Visible : Visibility.None)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

      FileListSelectView({ vm: this.vm.selectVM, selectRowBgColor: '#F1F3F5' })
        .width('100%')
        .layoutWeight(1)
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .bindSheet($$this.vm.isShow, this.dealWithFileSheet(),
      {
        showClose: false,
        height: 40 + 48 * 2,
        enableOutsideInteractive: true,
        maskColor: Color.Transparent,
        radius: { topLeft: 0, topRight: 0 },
        preferType: SheetType.BOTTOM
      })
  }

  private showTipDialog(msg: ResourceStr, sureText: ResourceStr, sureAction: () => void) {
    GlobalContext.getUIContext().showAlertDialog({
      message: msg,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          action: () => {
          }
        },
        {
          value: sureText,
          action: () => {
            sureAction()
          }
        }
      ]
    })

  }

  // 开启隐私空间
  private openPrivateSpace(): boolean {
    if (!PreferenceUtil.getInstance().has(PreferenceConstant.PRIVATE_SPACE_PASSWORD_KEY)) {
      // 在当前页面跳转到vip页面且成功开通，跳过提示
      if (this.isJumpToOpenVIP && this.userInfo.isVip) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.OPEN_PRIVATE_SPACE_PAGE,
          builder: wrapBuilder(SettingPrivateSpacePasswordPageBuilder),
          param: false
        })
        return false
      }

      this.showTipDialog($r('app.string.open_private_space_message'), $r('app.string.dialog_sure_open'), () => {
        if (this.userInfo.isVip) {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.OPEN_PRIVATE_SPACE_PAGE,
            builder: wrapBuilder(SettingPrivateSpacePasswordPageBuilder),
          })

          this.vm.isShow = false
        } else {
          this.showTipDialog($r('app.string.upgrade_open_private_space'), $r('app.string.goto_upgrade'), () => {
            this.isJumpToOpenVIP = true
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

    return true
  }

  // 移入到隐私空间
  private moveToPrivateSpace() {
    GlobalContext.getUIContext().showAlertDialog({
      message: $r('app.string.private_space_move_tip'),
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          action: () => {
          }
        },
        {
          value: $r('app.string.sure'),
          action: () => {
            const selectedList = this.vm.selectVM.getAllSelected()
            MockService.addFileListToPrivateSpaceFilePage(selectedList)
            this.vm.deleteAllSelected()
          }
        }
      ]
    })
  }

  // 移动文件
  private moveFileList() {
    const ids: number[] = this.operationVM.checkedFileIds()
    const param: MoveDirectorFirstPageParam = {
      fileIds: ids,
      completeAction: (fileIds: number[]) => {
        // 移动文件
        this.vm.moveFileList(fileIds, ids)
      },
      backDirectionAction: () => {
        this.vm.isShow = true
      }
    }
    phoneRouterControl.jumpPage({
      pageName: RouterMap.MOVE_FILE_FIRST_PAGE,
      builder: wrapBuilder(MoveDirectorFirstPageBuilder),
      param: param
    })
  }

  // 下载文件
  private downloadFileList() {
    const selectedList: FileInfo[] = this.vm.selectVM.getAllSelected()
    this.vm.selectVM.selectedIndexes.clear()
    selectedList.forEach((item) => {
      FileTransferManagerPageVM.rootInstance.fileTransferDownloadPageVM.startDownloadFileTask(item)
    })
  }

  // 删除文件
  private deleteFiles() {
    GlobalContext.getUIContext().showAlertDialog({
      title: $r('app.string.delete_file_title'),
      message: $r('app.string.delete_file_message'),
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          action: () => {
          }
        },
        {
          value: $r('app.string.sure'),
          action: () => {
            const timeStamp = Date.now()
            const fileList: FileInfo[] = this.vm.selectVM.getAllSelected()
            fileList.forEach((item) => {
              item.deletetime = timeStamp
            })
            MockService.addFileListToTargetList(fileList, MockService.recycleBinFileList)
            this.vm.deleteAllSelected()
            this.vm.isShow = false
            promptAction.showToast({
              message: $r('app.string.delete_success'),
              showMode: promptAction.ToastShowMode.TOP_MOST
            })
          }
        }
      ]
    })

  }
}