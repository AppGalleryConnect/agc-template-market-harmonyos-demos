import { OHPage, phoneRouterControl } from 'oh_router';

import { BarVM, FileInfo, FileType, HeaderView, TCLogger } from 'common';
import { FileListSelectView } from 'clouddisk_file_select';
import { MyCollectDirectorVM } from '../viewmodel/MyCollectDirectorVM';
import { FileOperationType, OperationSelect } from 'clouddisk_file_operation';
import { FileManagerPageVM, FileTransferManagerPageVM } from 'clouddisk_file';

const TAG: string = 'MyCollectDirectorPage'

// 面包屑导航收藏页面
@ComponentV2
struct MyCollectDirectorPage {
  private title: string = '我的收藏'
  @Require @Param param: MyCollectDirectorParam;
  vm: MyCollectDirectorVM = new MyCollectDirectorVM(new FileInfo(FileType.All))

  aboutToAppear(): void {
    this.vm = new MyCollectDirectorVM(this.param.fileinfo)
    // 选中某一项
    this.vm.selectVM.didSelectedAtIndexAction = (_: number) => {
      // 控制底部弹框是否出现
      const isVisible: boolean = (this.vm.selectVM.selectedIndexes.size > 0) ? true : false
      if (isVisible !== this.vm.isShow) {
        this.vm.isShow = isVisible
      }

      if (isVisible) {
        this.vm.operationVM.updateFileList(this.vm.selectVM.getAllSelected())
      }
    }
    // 全选、反选切换
    this.vm.selectVM.changeAllSelectedAction = (isAllSelected: boolean) => {
      this.vm.isShow = isAllSelected

      if (isAllSelected) {
        this.vm.operationVM.updateFileList(this.vm.selectVM.getAllSelected())
      }
    }
    // 单击某行
    this.vm.selectVM.didClickAtIndexAction = (index: number) => {
      // 非目录 or 隐私空间
      if (this.vm.selectVM.fileList[index].fileType !== FileType.Director &&
        this.vm.selectVM.fileList[index].fileType !== FileType.PrivateSpace) {
        FileManagerPageVM.routerToFileDetail(this.vm.selectVM.fileList[index])

        this.vm.isShow = false
        return
      }

      this.vm.jumpToNextlevelDirector(index)
    }
    // 弹框操作项参数
    this.vm.operationVM.didSelectEvent = (type: FileOperationType) => {
      if (type === FileOperationType.Collect) {
        TCLogger.warn(TAG, 'collected is changed')
        return
      }

      if (type === FileOperationType.CancleCollect) {
        this.param.deleteAction(this.vm.selectVM.getAllSelected())
        this.vm.cancelCollectedAllSelected()
      } else if (type === FileOperationType.Download) {
        const selectedList: FileInfo[] = this.vm.selectVM.getAllSelected()
        this.vm.selectVM.selectedIndexes.clear()
        selectedList.forEach((item) => {
          FileTransferManagerPageVM.rootInstance.fileTransferDownloadPageVM.startDownloadFileTask(item)
        })
      }

      this.vm.isShow = false
    }
  }

  @Builder
  dealWithFileSheet() {
    OperationSelect({ vm: this.vm.operationVM })
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      HeaderView({
        title: this.title,
        clickBackBtn: () => {
          phoneRouterControl.popPage();
        }
      })

      List() {
        ListItem() {
          Row() {
            Text(this.title)
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
              .textAlign(TextAlign.Start)
              .margin({ right: $r('app.float.vp_6') })
              .wordBreak(WordBreak.BREAK_ALL)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .constraintSize({ maxWidth: '30%' })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .onClick(() => {
                phoneRouterControl.popPage();
              })
            Image($r('app.media.icon_right'))
              .objectFit(ImageFit.Cover)
              .width($r('app.float.vp_14'))
              .height($r('app.float.vp_14'))
          }.margin({ right: $r('app.float.vp_5') })
        }

        ForEach(this.vm?.levelDirectorList, (item: FileInfo, index: number) => {
          ListItem() {
            Row() {
              Text(item.name)
                .fontColor(this.vm!.levelDirectorList.length - 1 === index ? '#4B5CC4' :
                $r('sys.color.font_primary'))
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(this.vm!.levelDirectorList.length - 1 === index ? FontWeight.Medium :
                FontWeight.Regular)
                .textAlign(TextAlign.Start)
                .margin({ right: $r('app.float.vp_6') })
                .wordBreak(WordBreak.BREAK_ALL)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .constraintSize({ maxWidth: '30%' })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .onClick(() => {
                  this.vm?.changeToPrelevelDirector(index)
                })
              if (this.vm!.levelDirectorList.length - 1 !== index) {
                Image($r('app.media.icon_right'))
                  .objectFit(ImageFit.Cover)
                  .width($r('app.float.vp_14'))
                  .height($r('app.float.vp_14'))
              }
            }.margin({ right: $r('app.float.vp_5') })
          }
        }, (item: string, idx: number) => JSON.stringify(item) + idx);
      }
      .padding({ top: $r('app.float.vp_12'), left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
      .edgeEffect(EdgeEffect.Spring)
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .height($r('app.float.vp_40'))
      .width('100%')

      FileListSelectView({ vm: this.vm?.selectVM })
        .width('100%')
        .layoutWeight(1)
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .padding({ top: BarVM.instance.aiBarH })
    .backgroundColor(Color.White)
    .bindSheet($$this.vm.isShow, this.dealWithFileSheet(),
      {
        showClose: false,
        height: 88,
        enableOutsideInteractive: true,
        maskColor: Color.Transparent,
        radius: { topLeft: 0, topRight: 0 },
        preferType: SheetType.BOTTOM
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

@Builder
export function MyCollectDirectorPageBuilder(info: Object) {
  MyCollectDirectorPage({ param: info as MyCollectDirectorParam })
}

export interface MyCollectDirectorParam {
  fileinfo: FileInfo,
  deleteAction: (fileList: FileInfo[]) => void
}
