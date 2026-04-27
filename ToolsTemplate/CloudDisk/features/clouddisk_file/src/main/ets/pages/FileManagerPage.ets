import { promptAction } from '@kit.ArkUI';
import { OHPage, phoneRouterControl } from 'oh_router';

import { BarVM, FileInfo, FileType, RouterMap, TimeUtil } from 'common';
import {
  NewFileFolderOperationSelect,
  NewFileFolderOperationSelectVM,
  NewFolderInputSelect
} from 'clouddisk_file_operation';
import { VipCenterPageBuilder } from 'collect_personal_info';
import { FileManagerPageVM } from '../viewmodel/FileManagerPageVM';
import { FileTransferManagerPageBuilder } from './FileTransferManagerPage';
import { FileTransferManagerPageVM } from '../viewmodel/FileTransferManagerPageVM';
import { FileTransferUploadPageVM } from '../viewmodel/FileTransferUploadPageVM';
import { FileViewSwitchView } from 'cloud_view_switch';
import { RenameDialog } from 'cloud_operation_item';

/**
 * @usage: 用于管理云盘文件的主页面。提供文件列表展示、文件上传、新建文件夹、文件传输管理等核心功能。
 * 关键数据结构包括FileManagerPageVM（文件管理视图模型）、FileTransferManagerPageVM（文件传输视图模型）、
 * NewFileFolderOperationSelectVM（新建文件夹操作视图模型）。页面支持文件上传进度跟踪、文件传输状态管理、新建文件夹弹窗操作等功能。
 * @layout: 页面采用垂直布局（Column），顶部是标题栏（Row），包含"文件"标题（左对齐）和传输图标按钮（右对齐）。
 * 中间是FileViewSwitchView文件列表操作组件（占据剩余空间）。右下角固定位置放置文件传输悬浮按钮，
 * 点击可弹出NewFileFolderOperationSelect底部操作面板。页面还包含NewFolderInputSelect自定义弹窗用于输入文件夹名称。
 * @constraints: FileManagerPageVM.rootInstance为单例模式不可修改；文件上传进度更新逻辑固定；
 * 底部操作面板的高度、圆角、交互行为不可变更；悬浮按钮的位置和尺寸固定。
 * @isGen: true
 * @fileType: page
 * @subPage: FileTransferManagerPage，LoginPage，VipCenterPage,OpenPrivateSpacePage,MultilevelFilePage，
 * PrivateSpaceListPage,ImageVideoPage，MoveFileFirstPage
 * @domain: 云存储
 * @zhName: 文件管理页面
 * @component: OHPage,FileViewSwitchView,NewFileFolderOperationSelect,NewFolderInputSelect,
 * FileTransferManagerPageBuilder
 * @image: screenshot/file.jpg
 */

// 文件tab主页
@ComponentV2
export struct FileManagerPage {
  vm: FileManagerPageVM = FileManagerPageVM.rootInstance
  @Local offsetX: number = 0
  @Local offsetY: number = 0
  @Local imageWidth: number = 62
  @Local imageHeight: number = 62
  @Local screenWidth: number = 0
  @Local screenHeight: number = 0
  // 记录拖拽开始时的位置
  private startX: number = 0
  private startY: number = 0
  private isDragging: boolean = false
  // 吸附距离阈值
  private snapThreshold: number = 50
  fileTransferVm: FileTransferManagerPageVM = FileTransferManagerPageVM.rootInstance
  newFileFolderVm: NewFileFolderOperationSelectVM = new NewFileFolderOperationSelectVM()
  @Local fileFolderName: string = ''
  @Consumer('currentIndexTab') currentIndexTab: number = 0;

  @Monitor('currentIndexTab')
  changeTabIndex() {
    if (this.currentIndexTab === 2) {
      FileManagerPageVM.rootInstance.reInitializeAgain()
    }
  }

  @Builder
  inputCustomDialog() {
    NewFolderInputSelect({
      closeWithResult: (text?: string) => {
        if (text !== undefined) {
          this.fileFolderName = text
          // 添加到文件列表中
          const fileInfo: FileInfo = new FileInfo(FileType.Director, this.fileFolderName,
            `${TimeUtil.getCurDate(TimeUtil.PATTERN_DATE_HYPHEN)} ${TimeUtil.getCurTime(TimeUtil.PATTERN_TIME_COLON)}`)
          fileInfo.fileId = Date.now()

          FileManagerPageVM.rootInstance.addFileToCurrentList([fileInfo])
        }
        promptAction.closeCustomDialog(this.vm.newFolderDialogId)
      }
    })
  }

  @Monitor('newFileFolderVm.isShowInput')
  openInputDialog() {
    promptAction.openCustomDialog({
      builder: () => {
        this.inputCustomDialog()
      },
      alignment: DialogAlignment.Center,
      width: '90%'
    })
      .then((id) => {
        this.vm.newFolderDialogId = id
      })
  }

  // 绑定上拉新建文件夹操作栏
  @Builder
  dealWithFileSheet() {
    NewFileFolderOperationSelect({
      vm: this.newFileFolderVm,
      selectFile: (type: string) => {
        FileTransferUploadPageVM.rootInstance.selectUploadFileTask(type, this.newFileFolderVm)
      },
      jumpVip: () => {
        if (!this.newFileFolderVm.userInfo?.isLogin) {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.LOGIN_PAGE,
          })
        } else {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.VIP_CENTER_PAGE,
            builder: wrapBuilder(VipCenterPageBuilder)
          })
        }
      }
    })
  }

  aboutToAppear(): void {
    this.vm.renameAction = (name: string, icon: ResourceStr, complete: (text: string) => void) => {
      this.openRenameDialog(name, icon, complete)
    }
  }

  // 重命名对话框
  private openRenameDialog(name: string, icon: ResourceStr, complete: (text: string) => void) {
    promptAction.openCustomDialog({
      builder: () => {
        this.renameDialogBuilder(name, icon, complete)
      },
      alignment: DialogAlignment.Center,
      width: '90%'
    })
      .then((id) => {
        FileManagerPageVM.rootInstance.renameDialogId = id
      })
  }

  @Builder
  renameDialogBuilder(name: string, icon: ResourceStr, complete: (text: string) => void) {
    RenameDialog({
      name: name, icon: icon, changeCompletedAction: (success: boolean, text?: string) => {
        if (success && text !== name) {
          complete(text ?? '')
        }

        promptAction.closeCustomDialog(FileManagerPageVM.rootInstance.renameDialogId)
      }
    })
  }

  private snapToEdge(x: number, y: number): Position {
    let snapX = x
    let snapY = y
    // 检查是否靠近左边缘
    if (x <= 0) {
      snapX = 0
    }
    // 检查是否靠近右边缘
    else if (x >= this.screenWidth - this.imageWidth) {
      snapX = this.screenWidth - this.imageWidth
    }
    // 检查是否靠近上边缘
    if (y <= this.snapThreshold) {
      snapY = 0
    }
    // 检查是否靠近下边缘
    else if (y >= this.screenHeight - this.imageHeight) {
      snapY = this.screenHeight - this.imageHeight
    }
    return { x: snapX, y: snapY }
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      Row() {
        Text($r('app.string.file'))
          .fontSize($r('sys.float.Title_M'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))

        Image($r('app.media.icon_transfer'))
          .width($r('app.float.vp_24'))
          .height($r('app.float.vp_24'))
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            // 主动跳转文件传输页面
            phoneRouterControl.jumpPage({
              pageName: RouterMap.FILE_TRANSFER_MANAGER_PAGE,
              builder: wrapBuilder(FileTransferManagerPageBuilder),
            })

            // 关闭底部弹框
            this.vm.selectVM.isShow = false
          })
      }
      .width('100%')
      .height(58)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 16, right: 16 })

      FileViewSwitchView({ vm: this.vm.selectVM })
        .layoutWeight(1)

      Image($r('app.media.file_transfer'))
        .width(this.imageWidth)
        .height(this.imageHeight)
        .position({ x: this.offsetX, y: this.offsetY })

        .gesture(
          PanGesture()
            .onActionStart((event: GestureEvent) => {
              // 记录开始拖拽时的位置
              this.startX = this.offsetX
              this.startY = this.offsetY
              this.isDragging = true
            })
            .onActionUpdate((event: GestureEvent) => {
              if (!this.isDragging) {
                return
              }
              let newX = this.startX + event.offsetX
              let newY = this.startY + event.offsetY

              newX = Math.max(0, Math.min(newX, this.screenWidth))
              newY = Math.max(0, Math.min(newY, this.screenHeight - (150 - BarVM.instance.aiBarH * 2)))

              this.offsetX = newX
              this.offsetY = newY
            })
            .onActionEnd(() => {
              this.isDragging = false
              const snappedPosition = this.snapToEdge(this.offsetX, this.offsetY)
              this.offsetX = snappedPosition.x as number
              this.offsetY = snappedPosition.y as number
            })
            .onActionCancel(() => {
              this.isDragging = false
            })

        )
        .onClick(() => {
          this.newFileFolderVm.isShow = !this.newFileFolderVm.isShow
        })
        .bindSheet($$this.newFileFolderVm.isShow, this.dealWithFileSheet(),
          {
            showClose: false,
            height: 384,
            enableOutsideInteractive: false,
            radius: { topLeft: 24, topRight: 24 },
            preferType: SheetType.BOTTOM
          })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .padding({ top: BarVM.instance.aiBarH })
    .backgroundColor(Color.White)
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.screenWidth = newValue.width as number
      this.screenHeight = newValue.height as number
      this.offsetX = this.screenWidth - 32 - this.imageWidth
      this.offsetY = this.screenHeight - (100 - BarVM.instance.aiBarH) - this.imageHeight
    })
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render()
      }
    })
  }
}