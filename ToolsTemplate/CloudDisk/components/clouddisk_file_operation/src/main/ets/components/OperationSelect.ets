import { Constants } from 'common'
import { Share } from 'module_share';
import { FileOperationModel, FileOperationType } from '../model/FileOperationModel';
import { OperationSelectVM } from '../viewmodel/OperationSelectVM';
import { NewFolderInputSelect } from './NewFolderInputSelect';
import { promptAction } from '@kit.ArkUI';
import { FileListSelectViewVM } from 'clouddisk_file_select';

/**
 * @usage: 用于文件操作功能选择场景，提供分享、收藏、重命名、下载、删除等文件操作入口。
 * 关键数据结构：FileOperationModel（操作模型，包含name名称、iconNormal普通图标、iconSelected选中图标、
 * operationType操作类型）、FileOperationType（操作类型枚举，包含Share分享、Collect收藏、Rename重命名等）、
 * OperationSelectVM（视图模型，包含operationList操作列表、fileList文件列表、isCollected收藏状态、
 * shareParams分享参数）。包含if逻辑：根据operationType显示不同的操作按钮（分享使用Share组件，
 * 收藏根据isCollected显示不同图标，重命名打开输入对话框）。
 * @layout: 网格布局。使用GridRow和GridCol组件排列操作按钮，根据操作数量自适应列数。每个按钮垂直布局（顶部图标24x24、底部文字10号字体），居中对齐。
 * @constraints: vm.operationList操作列表不能为空，FileOperationType操作类型不允许修改为非法值，
 * vm.shareParams分享参数必须包含完整信息（title、id、type、createTime、coverUrl、isVideo），
 * vm.fileList文件列表在重命名操作时必须只包含1个文件
 * @isGen: true
 * @fileType: component
 * @domain: 云存储
 * @zhName: 文件操作选择组件
 * @component: Share,NewFolderInputSelect
 * @image: screenshot/screenshot01.jpg
 */
@ComponentV2
export struct OperationSelect {
  @Param vm: OperationSelectVM = OperationSelectVM.defaultInstance();
  @Param bgColor: Color | string | Resource = $r('app.color.bgColor');

  @Builder
  shareCommentBuilder(item: FileOperationModel) {
    Column() {
      Image(item.iconNormal)
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text(item.name)
        .margin({ top: 4 })
        .fontSize(10)
    }
    .width(Constants.FULL_SIZE)
    .height(48)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  inputCustomDialog() {

    NewFolderInputSelect({
      // 此处fileList元素必定为1个
      originName: this.vm.fileList[0].removeFileExtension(),
      imageSrc: FileListSelectViewVM.getImageSource(this.vm.fileList[0].fileType),
      closeWithResult: (text?: string) => {
        if (text !== undefined && text !== this.vm.fileList[0].name) {
          this.vm.changeFileName(text)
          this.vm.didSelectEvent(FileOperationType.Rename)
        }
        promptAction.closeCustomDialog(this.vm.closeDialogId)
      }
    })
  }

  build() {
    Column() {
      GridRow({ columns: this.vm.operationList.length <= 5 ? this.vm.operationList.length : 4 }) {
        ForEach(this.vm.contentList, (item: FileOperationModel) => {
          GridCol({ span: 1 }) {
            if (item.operationType === FileOperationType.Share) {
              Column() {
                Share({
                  qrCodeInfo: this.vm.shareParams,
                  shareRenderBuilder: () => {
                    this.shareCommentBuilder(item)
                  },
                })
              }
            } else {
              Column() {
                Image(((item.operationType === FileOperationType.Collect) && this.vm.isCollected) ? item.iconSelected :
                  item.iconNormal)
                  .width(24)
                  .height(24)
                  .objectFit(ImageFit.Contain)
                Text(item.name)
                  .margin({ top: 4 })
                  .fontSize(10)
              }
              .width(Constants.FULL_SIZE)
              .height(48)
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                switch (item.operationType) {
                  case FileOperationType.Collect: {
                    // 收藏操作
                    this.vm.collectSwitched()
                    this.vm.didSelectEvent(item.operationType)
                  }
                    break
                  case FileOperationType.Rename: {
                    // 重命名操作
                    this.openRenameDialog()
                  }
                    break
                  default: {
                    this.vm.didSelectEvent(item.operationType)
                  }
                    break
                }


              })
            }
          }
          .width(Constants.FULL_SIZE)
        }, (item: FileOperationModel, idx: number) => JSON.stringify(item) + idx)
      }
    }
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .backgroundColor(this.bgColor)
    .padding({ bottom: 28, top: 12 })
    .justifyContent(FlexAlign.Center)
  }

  // 打开重命名对话框
  private openRenameDialog() {
    promptAction.openCustomDialog({
      builder: () => {
        this.inputCustomDialog()
      },
      alignment: DialogAlignment.Center,
      width: '90%'
    })
      .then((id) => {
        this.vm.closeDialogId = id
      })
  }
}
