import { OHPage, phoneRouterControl } from 'oh_router';
import { FileTransferManagerPageVM, } from '../viewmodel/FileTransferManagerPageVM';
import { FileOperationType, OperationSelectVM } from 'clouddisk_file_operation';
import { FileManagerPageVM } from '../viewmodel/FileManagerPageVM';
import { FileOperationUtil } from 'module_cloud_upload';
import { FileTransferUploadView } from '../components/FileTransferUploadView';
import { FileTransferDownloadView } from '../components/FileTransferDownloadView';
import { FileInfo, TCLogger, BarVM, HeaderView, FailedFileType, MockService } from 'common';
import { FileTransferDownloadPageVM } from '../viewmodel/FileTransferDownloadPageVM';
import { FileTransferUploadPageVM } from '../viewmodel/FileTransferUploadPageVM';

@Builder
export function FileTransferManagerPageBuilder(info: Object) {
  FileTransferManagerPage()
}


/**
 * @usage: 用于展示文件传输管理页面。提供文件上传和下载任务的管理功能，支持查看传输进度、重试失败任务、切换上传下载标签等功能。
 * 关键数据结构包括FileTransferManagerPageVM（文件传输管理视图模型，单例模式rootInstance，
 * 包含selectedTabTitle当前选中标签、fileTransferUploadPageVM上传视图模型、fileTransferDownloadPageVM下载视图模型、
 * downloadSelectedCompleteStatus下载完成状态）、FailedFileType（失败文件类型，包含name名称、path路径、des描述）、
 * FileOperationUtil（文件操作工具类，包含init初始化方法和isInitSuccess初始化成功标志）。
 * 包含if逻辑：根据selectedTabTitle判断显示上传或下载视图。
 * @layout: 页面采用Column垂直布局。顶部是titleLayout标题栏（RelativeContainer、高度58vp、左右内边距16vp），
 * 包含返回按钮Image（28x28、左对齐）和标题Text"文件传输"（字号16、加粗、居中对齐）。
 * 第二行是tabTitleLayout标签切换栏（Row、高度41vp），包含"上传"和"下载"两个RelativeContainer（宽度88vp），
 * 每个包含标题Text和底部Divider指示器（宽度12vp、高度3vp、圆角2vp、蓝色#2FAFFF）。
 * 下方是分割线Divider（高度0.5vp、黑色透明度#F0000000）。主体根据selectedTabTitle显示FileTransferUploadView上传视图或
 * FileTransferDownloadView下载视图（占满剩余空间），支持重试失败任务uploadRetryFunc回调。
 * @constraints: FileTransferManagerPageVM.rootInstance为单例模式不可修改；
 * FileOperationUtil初始化参数'cloud-disk-kow6o'固定；重试失败任务会先从失败列表中删除再重新开始任务；
 * 上传重试会调用startRetryUploadFileTask方法，下载重试会调用startDownloadFileTask方法；
 * 标签切换会更新selectedTabTitle状态。
 * @isGen: true
 * @fileType: page
 * @zhName: 文件传输管理页面
 * @component: OHPage,FileTransferUploadView,FileTransferDownloadView
 * @image: screenshot/file/file_transfer.png
 */

@ComponentV2
export struct FileTransferManagerPage {
  private readonly logTag: string = 'FileTransferManagerPage'
  @Local vm: FileTransferManagerPageVM = FileTransferManagerPageVM.rootInstance
  @Local fileManagerPageVM: FileManagerPageVM = FileManagerPageVM.rootInstance;
  operationVM: OperationSelectVM = new OperationSelectVM([
    FileOperationType.Download,
    FileOperationType.Delete,
    FileOperationType.Share,
    FileOperationType.Rename
  ])
  // 文件操作工具
  private fileOperationUtil: FileOperationUtil = new FileOperationUtil();

  aboutToAppear(): void {
    if (!FileOperationUtil.isInitSuccess) {
      this.fileOperationUtil.init().then((res: boolean) => {
        FileOperationUtil.isInitSuccess = true
        TCLogger.info(this.logTag, `Succeeded init Auth Login, result: ${JSON.stringify(res)}`);
      })
    }
  }
  aboutToDisappear(): void {
    this.vm.fileTransferDownloadPageVM.downloadSelectVM.selectedIndexes.clear()
    this.vm.fileTransferUploadPageVM.selectVM.selectedIndexes.clear()
  }
  // 上传和下载标签切换
  @Builder
  tabTitleLayout() {
    Row() {
      // 上传
      RelativeContainer() {
        Text('上传')
          .fontColor(this.vm.selectedTabTitle === '上传' ? '#000000' : '#99000000')
          .fontSize(14)
          .fontWeight(this.vm.selectedTabTitle === '上传' ? FontWeight.Medium : FontWeight.Regular)
          .alignRules({
            middle: { align: HorizontalAlign.Center, anchor: '__container__' },
            center: { align: VerticalAlign.Center, anchor: '__container__' }
          })
          .id('upload')

        Row()
          .backgroundColor('#2FAFFF')
          .width(12)
          .height(3)
          .borderRadius(2)
          .margin({ top: 4 })
          .alignRules({
            middle: { align: HorizontalAlign.Center, anchor: '__container__' },
            top: { align: VerticalAlign.Bottom, anchor: 'upload' }
          })
          .visibility(this.vm.selectedTabTitle === '上传' ? Visibility.Visible : Visibility.Hidden)
      }.width(88).height('100%')
      .onClick(() => {
        if (this.vm.selectedTabTitle === '上传') {
          return
        }
        this.vm.selectedTabTitle = '上传'
        this.vm.fileTransferDownloadPageVM.downloadSelectVM.selectedIndexes.clear()
        // 隐藏上传和下载的上拉框
        this.vm.fileTransferUploadPageVM.isShowOperation = false
        this.vm.fileTransferDownloadPageVM.isShowOperation = false
      })

      // 下载
      RelativeContainer() {
        Text('下载')
          .fontColor(this.vm.selectedTabTitle === '下载' ? '#000000' : '#99000000')
          .fontSize(14)
          .fontWeight(this.vm.selectedTabTitle === '下载' ? FontWeight.Medium : FontWeight.Regular)
          .alignRules({
            middle: { align: HorizontalAlign.Center, anchor: '__container__' },
            center: { align: VerticalAlign.Center, anchor: '__container__' }
          })
          .id('download')

        Row()
          .backgroundColor('#2FAFFF')
          .width(12)
          .height(3)
          .borderRadius(2)
          .margin({ top: 4 })
          .alignRules({
            middle: { align: HorizontalAlign.Center, anchor: '__container__' },
            top: { align: VerticalAlign.Bottom, anchor: 'download' }
          })
          .visibility(this.vm.selectedTabTitle === '下载' ? Visibility.Visible : Visibility.Hidden)
      }.width(88).height('100%')
      .onClick(() => {
        if (this.vm.selectedTabTitle === '下载') {
          return
        }
        this.vm.selectedTabTitle = '下载'
        this.vm.fileTransferUploadPageVM.selectVM.selectedIndexes.clear()
        // 隐藏上传和下载的上拉框
        this.vm.fileTransferUploadPageVM.isShowOperation = false
        this.vm.fileTransferDownloadPageVM.isShowOperation = false
      })
    }.width('100%').height(41).justifyContent(FlexAlign.Start)
  }

  // 标题和返回
  @Builder
  titleLayout() {
    HeaderView({
      title: '文件传输',
      clickBackBtn: () => {
        phoneRouterControl.popPage();
      }
    })
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      this.titleLayout()

      this.tabTitleLayout()

      // 分割线
      Divider().width('100%').height(0.5).backgroundColor('rgba(0, 0, 0, 0.06)')

      if (this.vm.selectedTabTitle === '上传') {
        FileTransferUploadView({
          uploadRetryFunc: (item: FailedFileType) => {
            // 先从失败列表中删除
            this.vm.fileTransferUploadPageVM.failedFileType =
              this.vm.fileTransferUploadPageVM.failedFileType.filter((item1) => item1.name !== item.name)
            MockService.fileTransferUploadFailedList = this.vm.fileTransferUploadPageVM.failedFileType
            this.vm.selectedCompleteStatus = '进行中'
            FileTransferUploadPageVM.rootInstance.retryFailedFileTask(item.name, item.path)
          }
        }).layoutWeight(1)

      } else if (this.vm.selectedTabTitle === '下载') {
        FileTransferDownloadView({
          uploadRetryFunc: (item: FailedFileType) => {
            // 先从失败列表中删除
            this.vm.fileTransferDownloadPageVM.downloadFailedFileType =
              this.vm.fileTransferDownloadPageVM.downloadFailedFileType.filter((item1) => item1.name !== item.name)
            MockService.fileTransferDownloadFailedList = this.vm.fileTransferDownloadPageVM.downloadFailedFileType
            this.vm.downloadSelectedCompleteStatus = '进行中'
            // 创建一个文件对象
            const file: FileInfo = new FileInfo(7, item.name, '')
            file.downloadUrl = item.path
            file.des = item.des
            FileTransferDownloadPageVM.rootInstance.startDownloadFailedFileTask(file)
          }
        }).layoutWeight(1)
      }

    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .padding({ top: BarVM.instance.staBarH })
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render()
      }
    })
  }
}