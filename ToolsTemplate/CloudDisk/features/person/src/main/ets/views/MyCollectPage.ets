import { FileOperationType, OperationSelect, OperationSelectVM } from 'clouddisk_file_operation';
import { BarVM, Constants, FileInfo, FileType, HeaderView, MockService, RouterMap } from 'common';
import { FileListSelectView, FileListSelectViewVM } from 'clouddisk_file_select';
import { OHPage, phoneRouterControl } from 'oh_router';
import {
  FileManagerPageVM, FileTransferManagerPageVM } from 'clouddisk_file';
import { MyCollectDirectorPageBuilder, MyCollectDirectorParam } from './MyCollectDirectorPage';

@Builder
export function MyCollectPageBuilder() {
  MyCollectPage()
}

/**
 * @usage: 用于展示我的收藏页面。提供用户收藏文件的管理功能，支持文件下载、分享和取消收藏操作。
 * 关键数据结构包括FileListSelectViewVM（文件列表选择视图模型，数据源为MockService.collectFileList）、
 * FileOperationType（文件操作类型枚举，包含Download下载、Share分享、CancleCollect取消收藏）、show（控制底部弹框显示）。
 * 包含if逻辑：根据show状态显示底部操作弹框，根据操作类型判断执行下载、分享或取消收藏。
 * @layout: 页面采用Column垂直布局。顶部是HeaderView导航栏（标题"我的收藏"和返回按钮，上边距24vp），
 * 主体是FileListSelectView文件列表选择视图（占满剩余空间，底部边距40vp）。
 * 底部通过bindSheet绑定操作弹框（下载、分享、取消收藏按钮，高度112+底部安全区）。
 * @constraints: 收藏文件列表从MockService.collectFileList获取不可修改。
 * @isGen: true
 * @fileType: page
 * @zhName: 我的收藏页面
 * @component: OHPage,HeaderView,FileListSelectView,OperationSelect
 * @image: screenshot/Person/myCollect.jpg
 */

@ComponentV2
struct MyCollectPage {
  @Local show: boolean = false
  fileListSelectViewVM = new FileListSelectViewVM(Array.from(MockService.collectFileList))
  // 只支持下载、分享、收藏
  operationVM: OperationSelectVM = new OperationSelectVM([
    FileOperationType.Download,
    FileOperationType.Share,
    FileOperationType.CancleCollect
  ])

  aboutToAppear(): void {
    this.fileListSelectViewVM.didSelectedAtIndexAction = (_: number) => {
      // 控制底部弹框是否出现
      const isVisible: boolean = (this.fileListSelectViewVM.selectedIndexes.size > 0) ? true : false
      if (isVisible !== this.show) {
        this.show = isVisible
      }

      if (isVisible) {
        this.operationVM.updateFileList(this.fileListSelectViewVM.getAllSelected())
      }
    }

    this.fileListSelectViewVM.changeAllSelectedAction = (isAllSelected: boolean) => {
      this.show = isAllSelected
      if (isAllSelected) {
        this.operationVM.updateFileList(this.fileListSelectViewVM.getAllSelected())
      }
    }

    // 单击某行
    this.fileListSelectViewVM.didClickAtIndexAction = (index: number) => {
      this.show = false

      // 非目录
      if (this.fileListSelectViewVM.fileList[index].fileType !== FileType.Director) {
        FileManagerPageVM.routerToFileDetail(this.fileListSelectViewVM.fileList[index])
        return
      }

      let param: MyCollectDirectorParam = {
        fileinfo: this.fileListSelectViewVM.fileList[index],
        deleteAction: (fileList: FileInfo[]) => {
          MockService.deleteFileListFromTargetList(fileList, MockService.collectFileList)
          MockService.deleteFileListFromTargetList(fileList, this.fileListSelectViewVM.fileList)
        }
      }
      phoneRouterControl.jumpPage({
        pageName: RouterMap.COLLECT_FILE_LIST_PAGE,
        builder: wrapBuilder(MyCollectDirectorPageBuilder),
        param: param
      })
    }
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      }
    })
  }

  @Builder
  dealWithFileSheet() {
    OperationSelect({
      vm: OperationSelectVM.createInstanceWithData(true, [FileOperationType.Download,
        FileOperationType.Share, FileOperationType.CancleCollect], (type: FileOperationType) => {
        if (type === FileOperationType.Download) {
          this.DownloadData()
        } else if (type === FileOperationType.Share) {

        } else if (type === FileOperationType.CancleCollect) {
          this.fileListSelectViewVM.getAllSelected().forEach((item) => {
            item.isCollected = false
          })
          this.deleteDate()
        }
      })
    })
  }

  //下载方法的调用
  DownloadData() {
    this.show = false
    const selectedList: FileInfo[] = this.fileListSelectViewVM.getAllSelected()
    this.fileListSelectViewVM.selectedIndexes.clear()
    selectedList.forEach((item) => {
      FileTransferManagerPageVM.rootInstance.fileTransferDownloadPageVM.startDownloadFileTask(item)
    })
  }

  //取消收藏方法的调用
  deleteDate() {
    this.show = false
    MockService.deleteFileListFromTargetList(this.fileListSelectViewVM.getAllSelected(), MockService.collectFileList)
    this.fileListSelectViewVM.deleteAllSelected()
  }

  @Builder
  render() {
    Column() {
      Column() {
        HeaderView({
          title: '我的收藏',
          clickBackBtn: () => {
            this.show = false
            phoneRouterControl.popPage();
          }
        })
      }
      .width(Constants.FULL_SIZE)
      .height(58 + BarVM.instance.staBarH)
      .justifyContent(FlexAlign.End)
      .backgroundColor($r('sys.color.comp_background_primary_contrary'))

      if (this.fileListSelectViewVM.fileList.length !== 0) {
        FileListSelectView({ vm: this.fileListSelectViewVM })
          .width('100%')
          .layoutWeight(1)
          .margin({ bottom: 40 })
      } else {
        this.NoFileList()
      }
    }
    .bindSheet($$this.show, this.dealWithFileSheet(),
      {
        showClose: false,
        height: 88,
        enableOutsideInteractive: true,
        maskColor: Color.Transparent,
        radius: { topLeft: 0, topRight: 0 },
        shouldDismiss: (sheetDismiss: SheetDismiss) => {
          this.fileListSelectViewVM.selectedIndexes.clear()
          sheetDismiss.dismiss()
        },
        preferType: SheetType.BOTTOM
      })
  }

  @Builder
  NoFileList() {
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
