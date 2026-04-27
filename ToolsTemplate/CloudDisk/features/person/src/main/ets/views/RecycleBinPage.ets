// 回收站
import { BarVM, FileInfo, HeaderView, MockService, TCLogger } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { RecycleBinViewModel } from '../viewmodel/RecycleBinViewModel'
import { FileListSelectView, FileListSelectViewFrom, FileListSelectViewVM, } from 'clouddisk_file_select'
import { FileOperationType, OperationSelect, OperationSelectVM } from 'clouddisk_file_operation'

const TAG: string = 'RecycleBinPageBuilder'

@Builder
export function RecycleBinPageBuilder() {
  RecycleBinPage()
}


/**
 * @usage: 用于展示回收站页面。提供已删除文件的管理功能，支持文件还原和永久删除操作。
 * 关键数据结构包括RecycleBinViewModel（回收站视图模型）、FileListSelectViewVM（文件列表选择视图模型）、
 * FileOperationType（文件操作类型枚举，包含BackUp还原、DeleteForevery永久删除）、show（控制底部弹框显示）、rePlay（控制还原进度显示）。
 * 包含if逻辑：根据show状态显示底部操作弹框，根据rePlay状态显示还原进度条，根据操作类型判断执行还原或永久删除。
 * @layout: 页面采用Stack堆叠布局。顶部是HeaderView导航栏，
 * 第二行是提示文字Row，主体是FileListSelectView文件列表选择视图（占满剩余空间），
 * 底部通过bindSheet绑定操作弹框。还原时在底部显示进度条（旋转图标、进度百分比、蓝色背景）。
 * @isGen: true
 * @fileType: page
 * @zhName: 回收站页面
 * @component: OHPage,HeaderView,FileListSelectView,OperationSelect
 * @image: screenshot/Person/recycleBin.jpg
 */

@ComponentV2
struct RecycleBinPage {
  @Local pat: number = 0
  @Local show: boolean = false
  @Local rePlay: boolean = false
  @Local imageAngle: number = 0
  recycleBinVM = new RecycleBinViewModel()
  fileListSelectViewVM = new FileListSelectViewVM(Array.from(MockService.recycleBinFileList))

  aboutToAppear(): void {
    this.fileListSelectViewVM.listFrom = FileListSelectViewFrom.RECYCLEBIN
    this.fileListSelectViewVM.didSelectedAtIndexAction = (_: number) => {
      // 控制底部弹框是否出现
      const isVisible: boolean = (this.fileListSelectViewVM.selectedIndexes.size > 0) ? true : false
      if (isVisible !== this.show) {
        this.show = isVisible
      }
    }

    this.fileListSelectViewVM.changeAllSelectedAction = (isAllSelected: boolean) => {
      this.show = isAllSelected
    }
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      isFullScreen: false
    })
  }

  @Builder
  dealWithFileSheet() {
    OperationSelect({
      vm: OperationSelectVM.createInstanceWithData(false, [FileOperationType.BackUp,
        FileOperationType.DeleteForevery], (type: FileOperationType) => {
        if (type === FileOperationType.BackUp) {
          this.pat = 0
          this.rePlay = true
          let timerID = setInterval(() => {
            this.imageAngle += 10
            if (this.imageAngle >= 360) {
              this.imageAngle = 0
            }
            if (this.pat === 100) {
              clearInterval(timerID)
              this.rePlay = false
              this.pat = 0
              MockService.restoreFileList(this.fileListSelectViewVM.getAllSelected())
              this.deleteDate(false)
            } else {
              this.pat += 5
            }
          }, 100)
        } else {
          this.showAlert('确认永久删除吗？' ,'永久删除后文件将无法再找回', '确定')
        }
      })
    })
      .backgroundColor(Color.White)
  }

  showAlert(title : string ,message: ResourceStr, sureBtnText: string) {
    this.getUIContext().showAlertDialog({
      title : title ,
      message: message,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: '取消',
          action: () => {
          }
        },
        {
          value: sureBtnText,
          action: () => {
            this.deleteDate(true)
          }
        }
      ]
    })
  }

  deleteDate(shouldClearRestore: boolean) {
    this.show = false
    const fileList: FileInfo[] = this.fileListSelectViewVM.getAllSelected()
    MockService.deleteFileListFromTargetList(fileList,
        MockService.recycleBinFileList)

    this.fileListSelectViewVM.deleteAllSelected()

    if (shouldClearRestore) {
      const deleteCollectList: FileInfo[] = Array.from(fileList)
      fileList.forEach((item) => {
        MockService.collectFileList.forEach((subItem) => {
          if (subItem.parentFileId === 0) {
            TCLogger.info(TAG, 'parentFileId === 0')
            return
          }

          if (!subItem.parentFileId.toString().includes(item.fileId.toString())) {
            TCLogger.info(TAG, 'parentFileId not include fileId')
            return
          }

          TCLogger.info(TAG, 'collect add delete fileid = ' + subItem.fileId.toString())
          deleteCollectList.push(subItem)
        })
      })

      MockService.deleteFileListFromTargetList(deleteCollectList, MockService.collectFileList)
    } else {
      TCLogger.info(TAG, 'not should dealWith collect')
    }
  }

  @Builder
  render() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Column() {
          HeaderView({
            title: $r('app.string.recycle_bin'),
            clickBackBtn: () => {
              this.show = false
              phoneRouterControl.popPage();
            }
          })
        }
        .height(58 + BarVM.instance.staBarH)
        .justifyContent(FlexAlign.End)
        .backgroundColor($r('app.color.white'))
        if (this.fileListSelectViewVM.fileList.length !== 0){
          Column() {
            Row() {
              Text($r('app.string.not_vip_tip_recyclebin'))
                .font({
                  size: $r('sys.float.Body_M'),
                })
                .fontColor($r('sys.color.font_tertiary'))
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .height($r('app.float.vp_35'))
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .backgroundColor('#FFF1F3F5')
            .onClick(() => {

            })

            FileListSelectView({ vm: this.fileListSelectViewVM })
              .width('100%')
              .layoutWeight(1)
          }
        }else {
          this.NoFileList()
        }

      }
      .bindSheet($$this.show, this.dealWithFileSheet(),
        {
          showClose: false,
          height: 40 + 48,
          maskColor: Color.Transparent,
          enableOutsideInteractive :true,
          radius: { topLeft: 0, topRight: 0 },
          shouldDismiss: (sheetDismiss: SheetDismiss) => {
            this.fileListSelectViewVM.selectedIndexes.clear()
            sheetDismiss.dismiss()
          },
          preferType: SheetType.BOTTOM
        })

      if (this.rePlay) {
        Row() {
          Row() {
            Image($r('app.media.ring'))
              .width($r('app.float.vp_20'))
              .height($r('app.float.vp_20'))
              .rotate({ z: 1, angle: this.imageAngle })
            Text('正在还原')
              .margin({ left: $r('app.float.vp_8') })
              .font({
                size: $r('sys.float.Body_M'),
                weight: FontWeight.Medium
              })
              .fontColor($r('sys.color.font_on_primary'))
              .textAlign(TextAlign.Start)
            Blank()
            Text(`${this.pat}%`)
              .font({
                size: $r('sys.float.Body_S'),
                weight: FontWeight.Medium
              })
              .textAlign(TextAlign.End)
              .fontColor($r('sys.color.font_on_primary'))

          }
          .borderRadius($r('sys.float.corner_radius_level6'))
          .width('100%')
          .height($r('app.float.vp_36'))
          .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          .backgroundColor('#FF6095B6')
        }
        .margin({ bottom: 124 + px2vp(BarVM.instance.aiBarHeight.value) })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
      }
    }
  }
  @Builder
  NoFileList(){
    Column() {
      Image($r('app.media.ic_nofilelist')).width(120).height(120).margin({top : '50%'})
      Text('暂无文件')
        .fontColor($r('app.color.dark_color_9DA3AA'))
        .fontSize($r('app.float.fontsize_12'))
        .lineHeight(14)
        .margin({ top: 18 })
      Blank()
      Row().width('100%').height(25).backgroundColor(Color.White)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .backgroundColor($r('app.color.dark_color_F1F3F5'))
  }
}
