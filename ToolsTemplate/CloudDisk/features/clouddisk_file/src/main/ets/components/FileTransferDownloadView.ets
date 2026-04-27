import { promptAction } from '@kit.ArkUI';
import { FileListSelectViewVM } from 'clouddisk_file_select';
import { FileOperationType, OperationSelect, OperationSelectVM } from 'clouddisk_file_operation';
import { FileInfo, RouterMap, TCLogger, ProgressingFileType, FailedFileType, MockService } from 'common';
import { phoneRouterControl } from 'oh_router';
import { VipCenterPageBuilder } from 'collect_personal_info';
import { FileTransferManagerPageVM } from '../viewmodel/FileTransferManagerPageVM';
import { FileTransferDownloadPageVM } from '../viewmodel/FileTransferDownloadPageVM';

/**
 * @usage: 用于文件下载任务管理场景。提供下载任务列表展示、任务状态切换（全部、已完成、进行中、任务失败）、
 * 任务操作（暂停、继续、重试、删除）、文件选择和批量操作等功能。关键数据结构：FileTransferManagerPageVM
 * （文件传输管理视图模型）、FailedFileType（失败文件类型）、ProgressingFileType（进行中文件类型）、
 * FileInfo（文件信息）、OperationSelectVM（操作选择视图模型）。
 * 包含if逻辑：根据downloadSelectedCompleteStatus状态显示不同的文件列表（全部、已完成、进行中、任务失败），
 * 根据VIP状态显示会员加速标识。
 * @layout: 垂直布局。顶部为状态标签列表（全部、已完成、进行中、任务失败横向排列），
 * 第二行为操作区域（进行中显示暂停按钮，失败显示重试按钮），第三行为已选中文件提示（全部和已完成状态显示），
 * 主体为文件列表（根据状态显示不同列表），底部绑定操作弹框。
 * @constraints: vm文件传输管理视图模型不能为空，uploadRetryFunc重试回调函数必须正确处理，
 * 文件操作回调函数必须正确处理
 * @isGen: true
 * @fileType: component
 * @zhName: 文件下载视图组件
 * @subPage: LoginPage,VipCenterPage
 * @component: OperationSelect
 * @image: screenshot/file/file_transfer_download.png
 */
@ComponentV2
export struct FileTransferDownloadView {
  private readonly logTag: string = 'FileTransferDownloadView'
  @Local vm: FileTransferManagerPageVM = FileTransferManagerPageVM.rootInstance
  @Param @Require uploadRetryFunc: (item: FailedFileType) => void
  operationVM: OperationSelectVM = new OperationSelectVM([
    FileOperationType.Download, FileOperationType.Delete, FileOperationType.Share, FileOperationType.Rename
  ])

  aboutToAppear(): void {
    this.fileOperationEvent()
  }

  // 文件选择回调初始化
  private fileOperationEvent() {
    // 选中某一项
    this.vm.fileTransferDownloadPageVM.downloadSelectVM.didSelectedAtIndexAction = (_: number) => {
      // 控制底部弹框是否出现
      const isDownloadVisible: boolean =
        (this.vm.fileTransferDownloadPageVM.downloadSelectVM.selectedIndexes.size > 0) ? true : false
      if (isDownloadVisible !== this.vm.fileTransferDownloadPageVM.isShowOperation) {
        this.vm.fileTransferDownloadPageVM.isShowOperation = isDownloadVisible
      }

      if (isDownloadVisible) {
        this.operationVM.updateFileList(this.vm.fileTransferDownloadPageVM.downloadSelectVM.getAllSelected())
      }
    }
    // 全选、反选切换
    this.vm.fileTransferDownloadPageVM.downloadSelectVM.changeAllSelectedAction = (isDownloadVisible: boolean) => {
      this.vm.fileTransferDownloadPageVM.isShowOperation = isDownloadVisible

      if (isDownloadVisible) {
        this.operationVM.updateFileList(this.vm.fileTransferDownloadPageVM.downloadSelectVM.fileList)
      }
    }
    // 弹框操作项参数
    this.operationVM.didSelectEvent = (type: FileOperationType) => {
      if (type === FileOperationType.Collect) {
        TCLogger.info(this.logTag, 'collected is changed');
        return
      }

      switch (type) {
        case FileOperationType.Delete: {
          this.openDeleteAllDialog()

        }
          break;
        case FileOperationType.Rename: {
          this.vm.fileTransferDownloadPageVM.downloadSelectVM.selectedIndexes.clear()

        }
          break;
        default:
          break;
      }

      this.vm.fileTransferDownloadPageVM.isShowOperation = false
    }
  }

  // 删除文件对话框
  openDeleteAllDialog() {
    promptAction.openCustomDialog({
      builder: () => {
        this.deleteAllDialog()
      },
      alignment: DialogAlignment.Center,
      width: '90%',
      height: 132
    })
      .then((id) => {
        this.vm.deleteDownloadAllDialogId = id
      })
  }

  // 全部文件删除对话框
  @Builder
  deleteAllDialog() {
    Column() {
      Text(this.vm.fileTransferDownloadPageVM.downloadSelectVM.checkIsAllSelected() ? '确认清除全部记录?' :
        '确认删除文件记录?')
        .width('100%')
        .fontSize(14)
        .lineHeight(16)
        .fontColor('#000000')
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .layoutWeight(1)

      Row() {
        Text('取消')
          .layoutWeight(1)
          .fontSize(16)
          .lineHeight(22)
          .fontColor('rgba(0, 0, 0, 0.6)')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            promptAction.closeCustomDialog(this.vm.deleteDownloadAllDialogId)
          })

        Divider().backgroundColor('rgba(0, 0, 0, 0.2)').width(0.5).height(24)

        Text('确认')
          .layoutWeight(1)
          .fontSize(16)
          .lineHeight(22)
          .fontColor('#2FAFFF')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.vm.fileTransferDownloadPageVM.downloadSelectVM.deleteAllSelected()
            promptAction.closeCustomDialog(this.vm.deleteDownloadAllDialogId)
          })
      }.width('100%').layoutWeight(1).alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({
      top: 24,
      bottom: 16,
      left: 24,
      right: 24
    })
  }

  @Builder
  downloadFileSheet() {
    OperationSelect({ vm: this.operationVM, bgColor: '#FFFFFF' })
  }

  @Builder
  buildScrollSwiperLayout(item: FailedFileType, controller: Scroller) {
    Row() {
      Scroll(controller) {
        this.failedSwiperLayout(item)
      }
      .width('100%')
      .height('100%')
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Up) {
          // 如果下滑手势状态，达到阈值，则解除固定
          if (event.touches[0].x - item.x > 5) {
            controller.scrollEdge(Edge.Start)
          } else if (event.touches[0].x - item.x < -5) {
            controller.scrollEdge(Edge.End)
          }
        } else if (event.type === TouchType.Down) {
          // 清空手势滑动状态
          item.x = event.touches[0].x
        }
      })
    }.width('100%').height('100%')
  }

  @Builder
  failedSwiperLayout(item: FailedFileType) {
    Row() {
      Row() {
        Image(item.img).size({ width: 40, height: 40 }).borderRadius(12)

        Column() {
          Text(item.name)
            .fontColor('#000000')
            .fontSize(14)
            .lineHeight(16)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .maxLines(2)

          Text(item.des).fontColor('#FF4D4D').fontSize(11).fontWeight(FontWeight.Regular).margin({ top: 6 })
        }.margin({ left: 12 }).alignItems(HorizontalAlign.Start).layoutWeight(1)

        Image($r('app.media.file_download_retry_icon')).size({ width: 24, height: 24 })
          .onClick(() => {
            this.uploadRetryFunc(item)
          })
      }.width('100%').height('100%').padding({ right: 16 })

      Text('删除')
        .width(64)
        .height(64)
        .fontColor('#FFFFFF')
        .backgroundColor('#FF5050')
        .textAlign(TextAlign.Center)
        .fontSize(14)
        .lineHeight(16)
        .fontWeight(FontWeight.Regular)
        .onClick(() => {
          this.vm.fileTransferDownloadPageVM.downloadFailedFileType =
            this.vm.fileTransferDownloadPageVM.downloadFailedFileType.filter((item1) => item1.name !== item.name)
          MockService.fileTransferDownloadFailedList =
            this.vm.fileTransferDownloadPageVM.downloadFailedFileType
        })

    }.height('100%').justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center)
  }

  // 选中某一项
  private didSelectItem(index: number) {
    if (this.vm.fileTransferDownloadPageVM.downloadSelectVM.selectedIndexes.has(index)) {
      this.vm.fileTransferDownloadPageVM.downloadSelectVM.selectedIndexes.delete(index)
    } else {
      this.vm.fileTransferDownloadPageVM.downloadSelectVM.selectedIndexes.add(index)
    }
    this.vm.fileTransferDownloadPageVM.downloadSelectVM.didSelectedAtIndexAction(index)
  }

  // 任务失败文件列表
  @Builder
  failedFileLayout() {
    Column() {
      List() {
        ForEach(this.vm.fileTransferDownloadPageVM.downloadFailedFileType, (item: FailedFileType, index) => {
          ListItem() {
            this.buildScrollSwiperLayout(item, new Scroller())
          }.height(64).width('100%').backgroundColor('#FFFFFF').padding({ left: 16 })
        }, (item: FailedFileType, idx: number) => JSON.stringify(item) + idx)
      }.width('100%')
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }.layoutWeight(1).width('100%').backgroundColor('#F1F3F5')
  }

  // 进行中的文件列表
  @Builder
  progressingFileLayout() {
    Column() {
      List() {
        ForEach(this.vm.fileTransferDownloadPageVM.downloadProgressingFileType, (item: ProgressingFileType, index) => {
          ListItem() {
            Row() {
              Image(FileListSelectViewVM.getImageSource(item.fileType)).size({ width: 40, height: 40 }).borderRadius(12)

              Column() {
                Text(item.name)
                  .fontColor('#000000')
                  .fontSize(14)
                  .lineHeight(16)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .maxLines(2)

                Row() {
                  Row()
                    .backgroundColor(item.vipStatus ? '#FFC775' : '#2FAFFF')
                    .height('100%')
                    .width(`${item.progress}%`)
                    .borderRadius(1.5)
                }
                .width('100%')
                .height(3)
                .backgroundColor('#F7F9FC')
                .margin({ top: 6 })
                .justifyContent(FlexAlign.Start)
                .borderRadius(1.5)

                Row() {
                  Text(item.progressDes).fontSize(11).fontColor('#99000000').fontWeight(FontWeight.Regular)

                  Text(item.speed).fontSize(11).fontColor('#99000000').fontWeight(FontWeight.Regular)
                }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ top: 6 })

              }.margin({ left: 12 }).alignItems(HorizontalAlign.Start).layoutWeight(1)

              Image(item.isStop ? $r('app.media.file_start_icon') : $r('app.media.file_stop_icon'))
                .size({ width: 24, height: 24 })
                .visibility(Visibility.None)
                .onClick(() => {
                  if (item.isStop) {
                    // 先从失败列表中删除
                    // this.vm.fileTransferDownloadPageVM.downloadProgressingFileType =
                    //   this.vm.fileTransferDownloadPageVM.downloadProgressingFileType.filter((item1) => item1.name !==
                    //   item.name)
                    // MockService.fileTransferDownloadProgressingList =
                    //   this.vm.fileTransferDownloadPageVM.downloadProgressingFileType
                    this.vm.downloadSelectedCompleteStatus = '进行中'
                    // 创建一个文件对象
                    const file: FileInfo = new FileInfo(7, item.name, '')
                    file.downloadUrl = item.path
                    FileTransferDownloadPageVM.rootInstance.startDownloadFileTask(file)
                    item.isStop = false
                  } else {
                    // 暂停下载任务
                    FileTransferDownloadPageVM.rootInstance.stopDownloadFileTask(item.name).then((res: boolean) => {
                      // 修改成暂停状态
                      item.isStop = res
                    })
                  }
                })

            }.width('100%').height('100%').justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center)
          }.height(68).width('100%').backgroundColor('#FFFFFF').padding({ left: 16, right: 16 })
        }, (item: ProgressingFileType, idx: number) => JSON.stringify(item) + idx)
      }.width('100%')
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }.layoutWeight(1).width('100%').backgroundColor('#F1F3F5')
  }

  // 已完成文件列表
  @Builder
  completedFileLayout() {
    Column() {
      List() {
        ForEach(this.vm.fileTransferDownloadPageVM.downloadSelectVM.fileList, (item: FileInfo, index) => {
          ListItem() {
            Row() {
              Image(FileListSelectViewVM.getImageSource(item.fileType)).size({ width: 40, height: 40 }).borderRadius(12)

              Column() {
                Text(item.name)
                  .fontColor('#000000')
                  .fontSize(14)
                  .lineHeight(16)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .maxLines(2)

                Row() {
                  Text(item.des).fontColor('#99000000').fontSize(11).fontWeight(FontWeight.Regular)

                  Image($r('app.media.icon_upload_right')).size({ width: 12, height: 12 }).margin({ left: 1 })
                }
                .margin({ top: 6 })
                .onClick(() => {
                  this.vm.fileTransferDownloadPageVM.getFilePathByFileId(item.fileId, item.parentFileId)
                })

              }.margin({ left: 12 }).alignItems(HorizontalAlign.Start).layoutWeight(1)

              Image(this.vm.fileTransferDownloadPageVM.downloadSelectVM.selectedIndexes.has(index) ?
                $r('app.media.file_selected_icon') :
                $r('app.media.file_unselected_icon'))
                .size({ width: 24, height: 24 })
                .onClick(() => {
                  this.didSelectItem(index)
                })
            }.width('100%').height('100%').justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center)
          }.height(64).width('100%').backgroundColor('#FFFFFF').padding({ left: 16, right: 16 })
        }, (item: FileInfo, idx: number) => JSON.stringify(item) + idx)
      }.width('100%')
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }.layoutWeight(1).width('100%').backgroundColor('#F1F3F5')
  }

  // 全部文件列表
  @Builder
  allFileLayout() {
    Column() {
      List() {
        // 已完成文件列表
        ListItem() {
          Row() {
            Text(`已完成(${this.vm.fileTransferDownloadPageVM.downloadSelectVM.fileList.length})`)
              .fontColor('#99000000')
              .fontWeight(FontWeight.Medium)
              .fontSize(12)
              .lineHeight(14)
              .margin({ left: 16 })
          }.width('100%').height('100%').padding({ top: 8 }).alignItems(VerticalAlign.Center)
        }.width('100%').height(38).backgroundColor('#FFFFFF')

        ForEach(this.vm.fileTransferDownloadPageVM.downloadSelectVM.fileList, (item: FileInfo, index) => {
          ListItem() {
            Row() {
              Image(FileListSelectViewVM.getImageSource(item.fileType)).size({ width: 40, height: 40 }).borderRadius(12)

              Column() {
                Text(item.name)
                  .fontColor('#000000')
                  .fontSize(14)
                  .lineHeight(16)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .maxLines(2)

                Row() {
                  Text(item.des).fontColor('#99000000').fontSize(11).fontWeight(FontWeight.Regular)

                  Image($r('app.media.icon_upload_right')).size({ width: 12, height: 12 }).margin({ left: 1 })
                }
                .margin({ top: 6 })
                .onClick(() => {
                  this.vm.fileTransferDownloadPageVM.getFilePathByFileId(item.fileId, item.parentFileId)
                })

              }.margin({ left: 12 }).alignItems(HorizontalAlign.Start).layoutWeight(1)

              Image(this.vm.fileTransferDownloadPageVM.downloadSelectVM.selectedIndexes.has(index) ?
                $r('app.media.file_selected_icon') :
                $r('app.media.file_unselected_icon'))
                .size({ width: 24, height: 24 })
                .onClick(() => {
                  this.didSelectItem(index)
                })
            }.width('100%').height('100%').justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center)
          }.height(64).width('100%').backgroundColor('#FFFFFF').padding({ left: 16, right: 16 })
        }, (item: FileInfo, idx: number) => JSON.stringify(item) + idx)
        // 进行中文件列表
        ListItem() {
          Row() {
            Text(`进行中(${this.vm.fileTransferDownloadPageVM.downloadProgressingFileType.length})`)
              .fontColor('#99000000')
              .fontWeight(FontWeight.Medium)
              .fontSize(12)
              .lineHeight(14)
              .margin({ left: 16 })
          }.width('100%').height('100%').alignItems(VerticalAlign.Center)
        }.width('100%').height(30).backgroundColor('#FFFFFF')

        ForEach(this.vm.fileTransferDownloadPageVM.downloadProgressingFileType, (item: ProgressingFileType, index) => {
          ListItem() {
            Row() {
              Image(FileListSelectViewVM.getImageSource(item.fileType)).size({ width: 40, height: 40 }).borderRadius(12)

              Column() {
                Text(item.name)
                  .fontColor('#000000')
                  .fontSize(14)
                  .lineHeight(16)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .maxLines(2)

                Row() {
                  Row()
                    .backgroundColor(item.vipStatus ? '#FFC775' : '#2FAFFF')
                    .height('100%')
                    .width(`${item.progress}%`)
                    .borderRadius(1.5)
                }
                .width('100%')
                .height(3)
                .backgroundColor('#F7F9FC')
                .margin({ top: 6 })
                .justifyContent(FlexAlign.Start)
                .borderRadius(1.5)

                Row() {
                  Text(item.progressDes).fontSize(11).fontColor('#99000000').fontWeight(FontWeight.Regular)

                  Text(item.speed).fontSize(11).fontColor('#99000000').fontWeight(FontWeight.Regular)
                }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ top: 6 })

              }.margin({ left: 12 }).alignItems(HorizontalAlign.Start).layoutWeight(1)

              Image(item.isStop ? $r('app.media.file_start_icon') : $r('app.media.file_stop_icon'))
                .size({ width: 24, height: 24 })
                .visibility(Visibility.None)
                .onClick(() => {
                  if (item.isStop) {
                    // 先从失败列表中删除
                    // this.vm.fileTransferDownloadPageVM.downloadProgressingFileType =
                    //   this.vm.fileTransferDownloadPageVM.downloadProgressingFileType.filter((item1) => item1.name !==
                    //   item.name)
                    // MockService.fileTransferDownloadProgressingList =
                    //   this.vm.fileTransferDownloadPageVM.downloadProgressingFileType
                    this.vm.downloadSelectedCompleteStatus = '进行中'
                    // 创建一个文件对象
                    const file: FileInfo = new FileInfo(7, item.name, '')
                    file.downloadUrl = item.path
                    FileTransferDownloadPageVM.rootInstance.startDownloadFileTask(file)
                    item.isStop = false
                  } else {
                    // 暂停下载任务
                    FileTransferDownloadPageVM.rootInstance.stopDownloadFileTask(item.name).then((res: boolean) => {
                      // 修改成暂停状态
                      item.isStop = res
                    })
                  }
                })

            }.width('100%').height('100%').justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center)
          }.height(68).width('100%').backgroundColor('#FFFFFF').padding({ left: 16, right: 16 })
        }, (item: ProgressingFileType, idx: number) => JSON.stringify(item) + idx)
        // 任务失败文件列表
        ListItem() {
          Row() {
            Text(`任务失败(${this.vm.fileTransferDownloadPageVM.downloadFailedFileType.length})`)
              .fontColor('#99000000')
              .fontWeight(FontWeight.Medium)
              .fontSize(12)
              .lineHeight(14)
              .margin({ left: 16 })
          }.width('100%').height('100%').alignItems(VerticalAlign.Center)
        }.width('100%').height(30).backgroundColor('#FFFFFF')

        ForEach(this.vm.fileTransferDownloadPageVM.downloadFailedFileType, (item: FailedFileType, index) => {
          ListItem() {
            this.buildScrollSwiperLayout(item, new Scroller())
          }.height(64).width('100%').backgroundColor('#FFFFFF').padding({ left: 16 })
        }, (item: FailedFileType, idx: number) => JSON.stringify(item) + idx)
      }.width('100%').height('100%')
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }.layoutWeight(1).width('100%').backgroundColor('#F1F3F5')
  }

  // 文件列表
  @Builder
  fileListLayout() {
    if (this.vm.downloadSelectedCompleteStatus === '全部') {
      this.allFileLayout()
    } else if (this.vm.downloadSelectedCompleteStatus === '已完成') {
      this.completedFileLayout()
    } else if (this.vm.downloadSelectedCompleteStatus === '进行中') {
      this.progressingFileLayout()
    } else if (this.vm.downloadSelectedCompleteStatus === '任务失败') {
      this.failedFileLayout()
    }
  }

  // 已选中文件布局
  @Builder
  selectedFileLayout() {
    Row() {
      Text(`已选中${this.vm.fileTransferDownloadPageVM.downloadSelectVM.selectedIndexes.size}个文件`)
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .fontColor('#99000000')
        .layoutWeight(1)

      Text(`${this.vm.fileTransferDownloadPageVM.downloadSelectVM.checkIsAllSelected() ? '取消全选' : '全选'}`)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2FAFFF')
        .onClick(() => {
          this.vm.fileTransferDownloadPageVM.downloadSelectVM.switchAllSelected()
        })
    }
    .width('100%')
    .height(31)
    .backgroundColor('#F1F3F5')
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
    .visibility(this.vm.downloadSelectedCompleteStatus === '全部' ||
      this.vm.downloadSelectedCompleteStatus === '已完成' ?
      Visibility.Visible : Visibility.None)
  }

  // 全部清除记录
  @Builder
  clearAllLayout() {
    Row() {
      Row() {
        if (this.vm.downloadSelectedCompleteStatus === '进行中') {
          Row() {
            Text(`进行中(${this.vm.fileTransferDownloadPageVM.downloadProgressingFileType.length})`)
              .fontColor('#99000000')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)

            if (this.vm.userInfo.isVip) {
              Row() {
                Image($r('app.media.icon_upload_vip')).size({ width: 23, height: 13 }).margin({ left: 6 })

                Text(`会员加速中`).fontColor('#C48458').fontWeight(FontWeight.Medium).fontSize(12).margin({ left: 2 })
              }
              .onClick(() => {
                if (!this.vm.userInfo?.isLogin) {
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.LOGIN_PAGE,
                  })
                } else {
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.VIP_CENTER_PAGE,
                    builder: wrapBuilder(VipCenterPageBuilder)
                  })
                }
              })
            }
          }
        } else if (this.vm.downloadSelectedCompleteStatus === '任务失败') {
          Row() {
            Text(`任务失败(${this.vm.fileTransferDownloadPageVM.downloadFailedFileType.length})`)
              .fontColor('#99000000')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
          }
        }
      }.layoutWeight(1).justifyContent(FlexAlign.Start)

      if (this.vm.downloadSelectedCompleteStatus === '进行中') {
        Text('全部暂停').fontSize(13).fontWeight(FontWeight.Medium).fontColor('#2FAFFF')
          .visibility(Visibility.None)
          .onClick(() => {
            this.vm.fileTransferDownloadPageVM.downloadProgressingFileType.forEach((item: ProgressingFileType) => {
              // 暂停下载任务
              FileTransferDownloadPageVM.rootInstance.stopDownloadFileTask(item.name).then((res: boolean) => {
                // 修改成暂停状态
                item.isStop = res
              })
            })
          })
      } else if (this.vm.downloadSelectedCompleteStatus === '任务失败') {
        Text('全部重试').fontSize(13).fontWeight(FontWeight.Medium).fontColor('#2FAFFF')
          .onClick(() => {
            this.vm.fileTransferDownloadPageVM.downloadFailedFileType.forEach(item => {
              this.uploadRetryFunc(item)
            })
          })
      }

    }
    .height(39)
    .width('100%')
    .padding({ left: 16, right: 16, top: 8 })
    .alignItems(VerticalAlign.Center)
    .visibility(this.vm.downloadSelectedCompleteStatus === '全部' ||
      this.vm.downloadSelectedCompleteStatus === '已完成' ?
      Visibility.None : Visibility.Visible)
  }

  // 完成状态标签列表
  @Builder
  completeStatusLayout() {
    Row() {
      List() {
        ForEach(this.vm.completeStatusArray, (item: string, index) => {
          ListItem() {
            if (item === '全部') {
              Row() {
                Text(`${item}(${this.vm.fileTransferDownloadPageVM.downloadSelectVM.fileList.length +
                this.vm.fileTransferDownloadPageVM.downloadProgressingFileType.length +
                this.vm.fileTransferDownloadPageVM.downloadFailedFileType.length})`)
                  .fontColor(this.vm.downloadSelectedCompleteStatus === item ? '#2FAFFF' : '#B3000000')
                  .fontSize(12)
                  .fontWeight(this.vm.downloadSelectedCompleteStatus === item ? FontWeight.Medium : FontWeight.Regular)
                  .padding({ left: 10, right: 10 })
                  .lineHeight(14)
                  .borderRadius(8)
                  .height('100%')
                  .backgroundColor(this.vm.downloadSelectedCompleteStatus === item ? '#F0F9FF' : '#F6F8FA')

              }.height('100%').margin({ right: 5 })
            } else if (item === '已完成') {
              Row() {
                Text(`${item}(${this.vm.fileTransferDownloadPageVM.downloadSelectVM.fileList.length})`)
                  .fontColor(this.vm.downloadSelectedCompleteStatus === item ? '#2FAFFF' : '#B3000000')
                  .fontSize(12)
                  .fontWeight(this.vm.downloadSelectedCompleteStatus === item ? FontWeight.Medium : FontWeight.Regular)
                  .padding({ left: 10, right: 10 })
                  .lineHeight(14)
                  .borderRadius(8)
                  .height('100%')
                  .backgroundColor(this.vm.downloadSelectedCompleteStatus === item ? '#F0F9FF' : '#F6F8FA')

              }.height('100%').margin({ right: 5 })
            } else if (item === '进行中') {
              Row() {
                Text(`${item}(${this.vm.fileTransferDownloadPageVM.downloadProgressingFileType.length})`)
                  .fontColor(this.vm.downloadSelectedCompleteStatus === item ? '#2FAFFF' : '#B3000000')
                  .fontSize(12)
                  .fontWeight(this.vm.downloadSelectedCompleteStatus === item ? FontWeight.Medium : FontWeight.Regular)
                  .padding({ left: 10, right: 10 })
                  .lineHeight(14)
                  .borderRadius(8)
                  .height('100%')
                  .backgroundColor(this.vm.downloadSelectedCompleteStatus === item ? '#F0F9FF' : '#F6F8FA')

              }.height('100%').margin({ right: 5 })
            } else if (item === '任务失败') {
              Row() {
                Text(`${item}(${this.vm.fileTransferDownloadPageVM.downloadFailedFileType.length})`)
                  .fontColor(this.vm.downloadSelectedCompleteStatus === item ? '#2FAFFF' : '#B3000000')
                  .fontSize(12)
                  .fontWeight(this.vm.downloadSelectedCompleteStatus === item ? FontWeight.Medium : FontWeight.Regular)
                  .padding({ left: 10, right: 10 })
                  .lineHeight(14)
                  .borderRadius(8)
                  .height('100%')
                  .backgroundColor(this.vm.downloadSelectedCompleteStatus === item ? '#F0F9FF' : '#F6F8FA')

              }.height('100%').margin({ right: 5 })
            }
          }.height('100%')
          .onClick(() => {
            this.vm.downloadSelectedCompleteStatus = item
          })
        }, (item: string, idx: number) => JSON.stringify(item) + idx)
      }
      .layoutWeight(1)
      .height(22)
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }.width('100%').height(38).padding({ left: 16, right: 16 }).alignItems(VerticalAlign.Center)
  }

  build() {
    Column() {
      this.completeStatusLayout()
      this.clearAllLayout()
      this.selectedFileLayout()
      this.fileListLayout()
    }
    .width('100%')
    .bindSheet($$this.vm.fileTransferDownloadPageVM.isShowOperation, this.downloadFileSheet(),
      {
        showClose: false,
        height: 88,
        enableOutsideInteractive: true,
        maskColor: Color.Transparent,
        preferType: SheetType.BOTTOM,
        radius: { topLeft: 0, topRight: 0 }
      })
  }
}