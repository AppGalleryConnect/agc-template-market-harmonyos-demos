import { promptAction } from '@kit.ArkUI';
import { FileOperationType, OperationSelect, OperationSelectVM } from 'clouddisk_file_operation';
import { FileInfo, RouterMap, TCLogger, ProgressingFileType, FailedFileType, MockService } from 'common';
import { FileListSelectViewVM } from 'clouddisk_file_select';
import { phoneRouterControl } from 'oh_router';
import { VipCenterPageBuilder } from 'collect_personal_info';
import { FileTransferManagerPageVM } from '../viewmodel/FileTransferManagerPageVM';
import { FileTransferUploadPageVM } from '../viewmodel/FileTransferUploadPageVM';

/**
 * @usage: 用于文件上传任务管理场景。提供上传任务列表展示、任务状态切换（全部、已完成、进行中、任务失败）、
 * 任务操作（暂停、继续、重试、删除）、文件选择和批量操作等功能。关键数据结构：FileTransferManagerPageVM
 * （文件传输管理视图模型）、FailedFileType（失败文件类型）、ProgressingFileType（进行中文件类型）、
 * FileInfo（文件信息）、OperationSelectVM（操作选择视图模型）。
 * 包含if逻辑：根据selectedCompleteStatus状态显示不同的文件列表（全部、已完成、进行中、任务失败），
 * 根据VIP状态显示会员加速标识。
 * @layout: 垂直布局。顶部为状态标签列表（全部、已完成、进行中、任务失败横向排列），
 * 第二行为操作区域（进行中显示暂停按钮，失败显示重试按钮），第三行为已选中文件提示（全部和已完成状态显示），
 * 主体为文件列表（根据状态显示不同列表），底部绑定操作弹框。
 * @constraints: vm文件传输管理视图模型不能为空，uploadRetryFunc重试回调函数必须正确处理，
 * 文件操作回调函数必须正确处理
 * @isGen: true
 * @fileType: component
 * @zhName: 文件上传视图组件
 * @subPage: LoginPage,VipCenterPage
 * @component: OperationSelect
 * @image: screenshot/file/file_transfer_upload.png
 */
@ComponentV2
export struct FileTransferUploadView {
  private readonly logTag: string = 'FileTransferUploadView'
  @Param @Require uploadRetryFunc: (item: FailedFileType) => void
  @Local vm: FileTransferManagerPageVM = FileTransferManagerPageVM.rootInstance
  operationVM: OperationSelectVM = new OperationSelectVM([
    FileOperationType.Download, FileOperationType.Delete, FileOperationType.Share,
    FileOperationType.Rename])

  aboutToAppear(): void {
    // 注册选择文件事件
    this.fileOperationEventRegister()
  }

  // 文件选择回调初始化
  private fileOperationEventRegister() {
    // 选中某一项文件
    this.vm.fileTransferUploadPageVM.selectVM.didSelectedAtIndexAction = (_: number) => {
      // 控制底部弹框是否出现
      const isVisibled: boolean = (this.vm.fileTransferUploadPageVM.selectVM.selectedIndexes.size > 0) ? true : false
      if (isVisibled !== this.vm.fileTransferUploadPageVM.isShowOperation) {
        this.vm.fileTransferUploadPageVM.isShowOperation = isVisibled
      }

      if (isVisibled) {
        this.operationVM.updateFileList(this.vm.fileTransferUploadPageVM.selectVM.getAllSelected())
      }
    }

    // 全选&反选
    this.vm.fileTransferUploadPageVM.selectVM.changeAllSelectedAction = (isVisibled: boolean) => {
      this.vm.fileTransferUploadPageVM.isShowOperation = isVisibled

      if (isVisibled) {
        this.operationVM.updateFileList(this.vm.fileTransferUploadPageVM.selectVM.fileList)
      }
    }

    // 上传列表底部
    this.operationVM.didSelectEvent = (uploadOperationType: FileOperationType) => {
      if (uploadOperationType === FileOperationType.Collect) {
        TCLogger.info(this.logTag, 'collected is changed');
        return
      }

      switch (uploadOperationType) {
        case FileOperationType.Delete: {
          // 删除弹框
          this.openDeleteAllDialog()
        }
          break;
        case FileOperationType.Rename: {
          this.vm.fileTransferUploadPageVM.selectVM.selectedIndexes.clear()
        }
          break;
        default:
          break;
      }

      // 隐藏底部
      this.vm.fileTransferUploadPageVM.isShowOperation = false
    }
  }

  private openDeleteAllDialog() {
    promptAction.openCustomDialog({
      builder: () => {
        // 删除全部
        this.deleteAllDialog()
      },
      alignment: DialogAlignment.Center,
      height: 132,
      width: '90%'
    })
      .then((dialogId) => {
        this.vm.deleteAllDialogId = dialogId
      })
  }

  /**
   * 创建全部文件删除对话框
   */
  @Builder
  deleteAllDialog() {
    Column() {
      Text(this.vm.fileTransferUploadPageVM.selectVM.checkIsAllSelected() ? '确认清除全部记录?' : '确认删除文件记录?')
        .fontColor('#000000')
        .textAlign(TextAlign.Center)
        .width('100%')
        .fontSize(14)
        .lineHeight(16)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)

      Row() {
        Text('取消')
          .textAlign(TextAlign.Center)
          .fontColor('rgba(0, 0, 0, 0.6)')
          .fontSize(16)
          .lineHeight(22)
          .layoutWeight(1)
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            promptAction.closeCustomDialog(this.vm.deleteAllDialogId)
          })

        Divider().backgroundColor('rgba(0, 0, 0, 0.2)').width(0.5).height(24)

        Text('确认')
          .fontWeight(FontWeight.Medium)
          .fontSize(16)
          .lineHeight(22)
          .fontColor('#2FAFFF')
          .layoutWeight(1)
          .onClick(() => {
            this.vm.fileTransferUploadPageVM.selectVM.deleteAllSelected()
            promptAction.closeCustomDialog(this.vm.deleteAllDialogId)
          })
          .textAlign(TextAlign.Center)
      }.width('100%').layoutWeight(1).alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({
      left: 24,
      right: 24,
      top: 24,
      bottom: 16
    })
  }

  @Builder
  uploadBottomFileSheet() {
    OperationSelect({ vm: this.operationVM, bgColor: '#FFFFFF' })
  }

  @Builder
  buildScrollSwiper(item: FailedFileType, controller: Scroller) {
    Row() {
      Scroll(controller) {
        this.failedSwiperBuilder(item)
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
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
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  failedSwiperBuilder(item: FailedFileType) {
    Row() {
      Row() {
        Image(item.img)
          .borderRadius(12)
          .size({ width: 40, height: 40 })

        Column() {
          Text(item.name)
            .fontSize(14)
            .lineHeight(16)
            .fontColor('#000000')
            .fontWeight(FontWeight.Medium)
            .maxLines(2)
            .width('100%')

          Text(item.des)
            .fontColor('#FF4D4D')
            .fontSize(11)
            .fontWeight(FontWeight.Regular)
            .margin({ top: 6 })
        }
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Image($r('app.media.file_retry_icon'))
          .size({ width: 24, height: 24 })
          .onClick(() => {
            this.uploadRetryFunc(item)
          })
      }.width('100%').height('100%').padding({ right: 16 })

      Text('删除')
        .fontColor('#FFFFFF')
        .fontSize(14)
        .lineHeight(16)
        .fontWeight(FontWeight.Regular)
        .width(64)
        .height(64)
        .backgroundColor('#FF5050')
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.vm.fileTransferUploadPageVM.failedFileType =
            this.vm.fileTransferUploadPageVM.failedFileType.filter((item1) => item1.name !== item.name)
          MockService.fileTransferUploadFailedList = this.vm.fileTransferUploadPageVM.failedFileType
        })
    }
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
  }

  // 选中某一项
  private didSelectItem(index: number) {
    if (this.vm.fileTransferUploadPageVM.selectVM.selectedIndexes.has(index)) {
      this.vm.fileTransferUploadPageVM.selectVM.selectedIndexes.delete(index)
    } else {
      this.vm.fileTransferUploadPageVM.selectVM.selectedIndexes.add(index)
    }
    this.vm.fileTransferUploadPageVM.selectVM.didSelectedAtIndexAction(index)
  }

  // 任务失败文件列表
  @Builder
  failedFileLayout() {
    Column() {
      List() {
        ForEach(this.vm.fileTransferUploadPageVM.failedFileType, (item: FailedFileType, index) => {
          ListItem() {
            this.buildScrollSwiper(item, new Scroller())
          }
          .height(64)
          .width('100%')
          .backgroundColor('#FFFFFF')
          .padding({ left: 16 })
        }, (item: FailedFileType, idx: number) => JSON.stringify(item) + idx)
      }
      .width('100%')
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
    .layoutWeight(1)
    .width('100%')
    .backgroundColor('#F1F3F5')
  }

  @Builder
  progressingFileBuilder() {
    Column() {
      List() {
        ForEach(this.vm.fileTransferUploadPageVM.progressingFileType, (item: ProgressingFileType, index) => {
          ListItem() {
            Row() {
              Image(FileListSelectViewVM.getImageSource(item.fileType))
                .size({ width: 40, height: 40 })
                .borderRadius(12)

              Column() {
                Text(item.name)
                  .lineHeight(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#000000')
                  .fontSize(14)
                  .width('100%')
                  .maxLines(2)

                Row() {
                  Row()
                    .width(`${item.progress}%`)
                    .borderRadius(1.5)
                    .backgroundColor(item.vipStatus ? '#FFC775' : '#2FAFFF')
                    .height('100%')
                }
                .height(3)
                .width('100%')
                .margin({ top: 6 })
                .backgroundColor('#F7F9FC')
                .borderRadius(1.5)
                .justifyContent(FlexAlign.Start)

                Row() {
                  Text(item.progressDes)
                    .fontSize(11)
                    .fontColor('#99000000').fontWeight(FontWeight.Regular)

                  Text(item.speed).fontSize(11).fontColor('#99000000')
                    .fontWeight(FontWeight.Regular)
                }.width('100%')
                .justifyContent(FlexAlign.SpaceBetween).margin({ top: 6 })

              }.margin({ left: 12 })
              .alignItems(HorizontalAlign.Start).layoutWeight(1)

              Image(item.isStop ? $r('app.media.file_start_icon') : $r('app.media.file_stop_icon'))
                .size({ width: 24, height: 24 })
                .visibility(Visibility.None)
                .onClick(() => {
                  if (item.isStop) {
                    this.vm.selectedCompleteStatus = '进行中'
                    // 重新开始上传任务
                    FileTransferUploadPageVM.rootInstance.startRetryUploadFileTask(item.name)
                    item.isStop = false
                  } else {
                    // 暂停下载任务
                    FileTransferUploadPageVM.rootInstance.stopUploadFileTask(item.name).then((res: boolean) => {
                      // 修改成暂停状态
                      item.isStop = res
                    })
                  }
                })
            }.width('100%')
            .height('100%').justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center)
          }.height(68)
          .width('100%').backgroundColor('#FFFFFF').padding({ left: 16, right: 16 })
        }, (item: ProgressingFileType, idx: number) => JSON.stringify(item) + idx)
      }
      .width('100%')
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
    .layoutWeight(1)
    .width('100%')
    .backgroundColor('#F1F3F5')
  }

  // 已完成文件列表
  @Builder
  completedFileBuilder() {
    Column() {
      List() {
        ForEach(this.vm.fileTransferUploadPageVM.selectVM.fileList, (item: FileInfo, index: number) => {
          ListItem() {
            Row() {
              Image(FileListSelectViewVM.getImageSource(item.fileType))
                .size({ width: 40, height: 40 })
                .borderRadius(12)

              Column() {
                Text(item.name)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .fontColor('#000000')
                  .fontSize(14)
                  .lineHeight(16)
                  .maxLines(2)

                Row() {
                  Text(item.des).fontColor('#99000000').fontSize(11)
                    .fontWeight(FontWeight.Regular)

                  Image($r('app.media.icon_upload_right'))
                    .size({ width: 12, height: 12 }).margin({ left: 1 })
                }
                .onClick(() => {
                  this.vm.fileTransferUploadPageVM.getFilePathByFileId(item.fileId, item.parentFileId)
                })
                .margin({ top: 6 })

              }
              .margin({ left: 12 }).alignItems(HorizontalAlign.Start).layoutWeight(1)

              Image(this.vm.fileTransferUploadPageVM.selectVM.selectedIndexes.has(index) ?
              $r('app.media.file_selected_icon') :
              $r('app.media.file_unselected_icon'))
                .onClick(() => {
                  this.didSelectItem(index)
                })
                .size({ width: 24, height: 24 })
            }
            .width('100%').height('100%').justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center)
          }
          .height(64).width('100%').backgroundColor('#FFFFFF').padding({ left: 16, right: 16 })
        }, (item: FileInfo, idx: number) => JSON.stringify(item) + idx)
      }
      .width('100%')
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
    .layoutWeight(1).width('100%').backgroundColor('#F1F3F5')
  }

  // 全部文件列表
  @Builder
  allFileBuilder() {
    Column() {
      List() {
        ListItem() {
          Row() {
            Text(`已完成(${this.vm.fileTransferUploadPageVM.selectVM.fileList.length})`)
              .lineHeight(14)
              .margin({ left: 16 })
              .fontColor('#99000000')
              .fontWeight(FontWeight.Medium)
              .fontSize(12)
          }
          .width('100%').height('100%').padding({ top: 8 })
          .alignItems(VerticalAlign.Center)
        }
        .width('100%').height(38)
        .backgroundColor('#FFFFFF')

        ForEach(this.vm.fileTransferUploadPageVM.selectVM.fileList, (item: FileInfo, index: number) => {
          ListItem() {
            Row() {
              Image(FileListSelectViewVM.getImageSource(item.fileType)).size({ width: 40, height: 40 })
                .borderRadius(12)

              Column() {
                Text(item.name)
                  .fontSize(14)
                  .lineHeight(16)
                  .fontColor('#000000')
                  .maxLines(2)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')

                Row() {
                  Text(item.des).fontColor('#99000000')
                    .fontSize(11).fontWeight(FontWeight.Regular)

                  Image($r('app.media.icon_upload_right')).size({ width: 12, height: 12 })
                    .margin({ left: 1 })
                }
                .onClick(() => {
                  this.vm.fileTransferUploadPageVM.getFilePathByFileId(item.fileId, item.parentFileId)
                })
                .margin({ top: 6 })

              }
              .margin({ left: 12 })
              .alignItems(HorizontalAlign.Start).layoutWeight(1)

              Image(this.vm.fileTransferUploadPageVM.selectVM.selectedIndexes.has(index) ?
              $r('app.media.file_selected_icon') :
              $r('app.media.file_unselected_icon'))
                .onClick(() => {
                  this.didSelectItem(index)
                })
                .size({ width: 24, height: 24 })
            }
            .width('100%').height('100%')
            .justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center)
          }
          .height(64).width('100%')
          .backgroundColor('#FFFFFF').padding({ left: 16, right: 16 })
        }, (item: FileInfo, idx: number) => JSON.stringify(item) + idx)

        ListItem() {
          Row() {
            Text(`进行中(${this.vm.fileTransferUploadPageVM.progressingFileType.length})`)
              .lineHeight(14)
              .fontColor('#99000000')
              .fontWeight(FontWeight.Medium)
              .fontSize(12)
              .margin({ left: 16 })
          }
          .width('100%').height('100%')
          .alignItems(VerticalAlign.Center)
        }
        .width('100%').height(30)
        .backgroundColor('#FFFFFF')

        ForEach(this.vm.fileTransferUploadPageVM.progressingFileType, (item: ProgressingFileType, index) => {
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
                    // 重新开始上传任务
                    this.vm.selectedCompleteStatus = '进行中'
                    FileTransferUploadPageVM.rootInstance.startRetryUploadFileTask(item.name)
                    item.isStop = false
                  } else {
                    // 暂停下载任务
                    FileTransferUploadPageVM.rootInstance.stopUploadFileTask(item.name).then((res: boolean) => {
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
            Text(`任务失败(${this.vm.fileTransferUploadPageVM.failedFileType.length})`)
              .fontColor('#99000000')
              .fontWeight(FontWeight.Medium)
              .fontSize(12)
              .lineHeight(14)
              .margin({ left: 16 })
          }.width('100%').height('100%').alignItems(VerticalAlign.Center)
        }.width('100%').height(30).backgroundColor('#FFFFFF')

        ForEach(this.vm.fileTransferUploadPageVM.failedFileType, (item: FailedFileType, index) => {
          ListItem() {
            this.buildScrollSwiper(item, new Scroller())
          }
          .width('100%')
          .height(64).backgroundColor('#FFFFFF').padding({ left: 16 })
        }, (item: FailedFileType, idx: number) => JSON.stringify(item) + idx)
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .width('100%')
      .height('100%')

    }
    .layoutWeight(1)
    .width('100%').backgroundColor('#F1F3F5')
  }

  // 文件列表
  @Builder
  fileListLayout() {
    if (this.vm.selectedCompleteStatus === '全部') {
      this.allFileBuilder()
    } else if (this.vm.selectedCompleteStatus === '已完成') {
      this.completedFileBuilder()
    } else if (this.vm.selectedCompleteStatus === '进行中') {
      this.progressingFileBuilder()
    } else if (this.vm.selectedCompleteStatus === '任务失败') {
      this.failedFileLayout()
    }
  }

  // 已选中文件布局
  @Builder
  selectedFileLayout() {
    Row() {
      Text(`已选中${this.vm.fileTransferUploadPageVM.selectVM.selectedIndexes.size}个文件`)
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .fontColor('#99000000')
        .layoutWeight(1)

      Text(`${this.vm.fileTransferUploadPageVM.selectVM.checkIsAllSelected() ? '取消全选' : '全选'}`)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2FAFFF')
        .onClick(() => {
          this.vm.fileTransferUploadPageVM.selectVM.switchAllSelected()
        })
    }
    .width('100%')
    .height(31)
    .backgroundColor('#F1F3F5')
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
    .visibility(this.vm.selectedCompleteStatus === '全部' || this.vm.selectedCompleteStatus === '已完成' ?
    Visibility.Visible : Visibility.None)
  }

  // 全部清除记录
  @Builder
  clearAllLayout() {
    Row() {
      Row() {
        if (this.vm.selectedCompleteStatus === '进行中') {
          Row() {
            Text(`进行中(${this.vm.fileTransferUploadPageVM.progressingFileType.length})`)
              .fontWeight(FontWeight.Medium)
              .fontColor('#99000000')
              .fontSize(12)

            if (this.vm.userInfo.isVip) {
              Row() {
                Image($r('app.media.icon_upload_vip'))
                  .size({ width: 23, height: 13 }).margin({ left: 6 })

                Text(`会员加速中`).fontColor('#C48458')
                  .fontWeight(FontWeight.Medium).fontSize(12).margin({ left: 2 })
              }
              .onClick(() => {
                if (!this.vm.userInfo?.isLogin) {
                  // login
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.LOGIN_PAGE,
                  })
                } else {
                  // vip
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.VIP_CENTER_PAGE,
                    builder: wrapBuilder(VipCenterPageBuilder)
                  })
                }
              })
            }
          }
        } else if (this.vm.selectedCompleteStatus === '任务失败') {
          Row() {
            Text(`任务失败(${this.vm.fileTransferDownloadPageVM.downloadFailedFileType.length})`)
              .fontColor('#99000000')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
          }
        }
      }.layoutWeight(1).justifyContent(FlexAlign.Start)

      if (this.vm.selectedCompleteStatus === '进行中') {
        Text('全部暂停').fontSize(13).fontWeight(FontWeight.Medium).fontColor('#2FAFFF')
          .visibility(Visibility.None)
          .onClick(() => {
            this.vm.fileTransferUploadPageVM.progressingFileType.forEach(item => {
              FileTransferUploadPageVM.rootInstance.stopUploadFileTask(item.name).then((res: boolean) => {
                // 修改成暂停状态
                item.isStop = res
              })
            })
          })
      } else if (this.vm.selectedCompleteStatus === '任务失败') {
        Text('全部重试').fontSize(13).fontWeight(FontWeight.Medium).fontColor('#2FAFFF')
          .onClick(() => {
            this.vm.fileTransferUploadPageVM.failedFileType.forEach(item => {
              this.uploadRetryFunc(item)
            })
          })
      }

    }
    .height(39)
    .width('100%')
    .padding({ left: 16, right: 16, top: 8 })
    .alignItems(VerticalAlign.Center)
    .visibility(this.vm.selectedCompleteStatus === '全部' || this.vm.selectedCompleteStatus === '已完成' ?
    Visibility.None : Visibility.Visible)
  }

  @Builder
  completeStatusLayout() {
    Row() {
      List() {
        ForEach(this.vm.completeStatusArray, (item: string) => {
          ListItem() {
            if (item === '全部') {
              Row() {
                Text(`${item}(${this.vm.fileTransferUploadPageVM.selectVM.fileList.length +
                this.vm.fileTransferUploadPageVM.progressingFileType.length +
                this.vm.fileTransferUploadPageVM.failedFileType.length})`)
                  .fontColor(this.vm.selectedCompleteStatus === item ? '#2FAFFF' : '#B3000000')
                  .fontSize(12)
                  .fontWeight(this.vm.selectedCompleteStatus === item ? FontWeight.Medium : FontWeight.Regular)
                  .padding({ left: 10, right: 10 })
                  .lineHeight(14)
                  .borderRadius(8)
                  .height('100%')
                  .backgroundColor(this.vm.selectedCompleteStatus === item ? '#F0F9FF' : '#F6F8FA')

              }.height('100%').margin({ right: 5 })
            } else if (item === '已完成') {
              Row() {
                Text(`${item}(${this.vm.fileTransferUploadPageVM.selectVM.fileList.length})`)
                  .fontColor(this.vm.selectedCompleteStatus === item ? '#2FAFFF' : '#B3000000')
                  .fontSize(12)
                  .fontWeight(this.vm.selectedCompleteStatus === item ? FontWeight.Medium : FontWeight.Regular)
                  .padding({ left: 10, right: 10 })
                  .lineHeight(14)
                  .borderRadius(8)
                  .height('100%')
                  .backgroundColor(this.vm.selectedCompleteStatus === item ? '#F0F9FF' : '#F6F8FA')

              }.height('100%').margin({ right: 5 })
            } else if (item === '进行中') {
              Row() {
                Text(`${item}(${this.vm.fileTransferUploadPageVM.progressingFileType.length})`)
                  .fontColor(this.vm.selectedCompleteStatus === item ? '#2FAFFF' : '#B3000000')
                  .fontSize(12)
                  .fontWeight(this.vm.selectedCompleteStatus === item ? FontWeight.Medium : FontWeight.Regular)
                  .padding({ left: 10, right: 10 })
                  .lineHeight(14)
                  .borderRadius(8)
                  .height('100%')
                  .backgroundColor(this.vm.selectedCompleteStatus === item ? '#F0F9FF' : '#F6F8FA')

              }.height('100%').margin({ right: 5 })
            } else if (item === '任务失败') {
              Row() {
                Text(`${item}(${this.vm.fileTransferUploadPageVM.failedFileType.length})`)
                  .fontColor(this.vm.selectedCompleteStatus === item ? '#2FAFFF' : '#B3000000')
                  .fontSize(12)
                  .fontWeight(this.vm.selectedCompleteStatus === item ? FontWeight.Medium : FontWeight.Regular)
                  .padding({ left: 10, right: 10 })
                  .lineHeight(14)
                  .borderRadius(8)
                  .height('100%')
                  .backgroundColor(this.vm.selectedCompleteStatus === item ? '#F0F9FF' : '#F6F8FA')

              }.height('100%').margin({ right: 5 })
            }
          }.height('100%')
          .onClick(() => {
            this.vm.selectedCompleteStatus = item
          })
        }, (item: string, idx: number) => JSON.stringify(item) + idx)
      }
      .height(22)
      .layoutWeight(1)
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
    .width('100%')
    .height(38)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
  }

  build() {
    Column() {
      this.completeStatusLayout()

      this.clearAllLayout()

      this.selectedFileLayout()

      this.fileListLayout()
    }
    .width('100%')
    .bindSheet($$this.vm.fileTransferUploadPageVM.isShowOperation, this.uploadBottomFileSheet(),
      {
        height: 88,
        radius: { topLeft: 0, topRight: 0 },
        enableOutsideInteractive: true,
        maskColor: Color.Transparent,
        showClose: false,
        preferType: SheetType.BOTTOM
      })
  }
}