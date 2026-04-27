import { FileBaseCheckViewModel } from 'cloud_file_base';
import { FileInfo } from 'common';
import { FileListSelectViewFrom, FileListSelectViewVM } from '../viewmodel/FileListSelectViewVM';

/**
 * @usage: 用于文件列表展示场景（列表样式）。显示文件信息，包括图标、名称、大小、创建时间、
 * 过期时间和选择状态。关键数据结构：FileInfo（文件信息，包含name名称、fileType文件类型、
 * fileSize文件大小、createTime创建时间、isCollected收藏状态、checkExpireTime过期时间方法、
 * checkExpireTimeColor过期时间颜色方法）、isSelected（是否选中布尔值）、checkAction（选择回调函数）。
 * 包含if逻辑：根据isCollected判断是否显示收藏图标，根据fileSize判断是否显示文件大小，
 * 根据isSelected显示不同的选择图标。
 * @layout: 横向布局。左侧为文件图标（40x40），中间为文件信息列（文件名和时间/大小垂直排列，左对齐），
 * 右侧为选择图标（36x48，已选中显示蓝色对勾，未选中显示灰色圆圈）。整体高度64，左对齐。
 * @constraints: fileInfo文件信息不能为空，checkAction回调函数必须正确处理选择操作
 * @isGen: true
 * @fileType: component
 * @zhName: 文件信息单元格组件（列表样式）
 */
@ComponentV2
export struct FileInfoCell {
  @Param @Require fileInfo: FileInfo;
  @Require @Param vm: FileListSelectViewVM
  @Param isSelected: boolean = false
  @Event checkAction: () => void = () => {
  }

  @Computed
  get expireTime() {
    return this.vm.rightbottomText(this.fileInfo)
  }

  @Computed
  get expireTimeColor() {
    return this.vm.rightbottomTextColor(this.fileInfo)
  }

  build() {
    Row() {
      Image(FileBaseCheckViewModel.getImageSource(this.fileInfo.fileType, this.fileInfo.name,
        this.vm.isListVisibleGridMode, this.fileInfo.thumbnailUrl))
        .width(40)
        .height(40)
        .objectFit(ImageFit.Contain)

      Column() {
        Row() {
          Text(this.fileInfo.name)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.Black)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)

          Image($r('app.media.icon_collect'))
            .width(16)
            .height(16)
            .objectFit(ImageFit.Contain)
            .margin({ left: 6 })
            .visibility(this.fileInfo.isCollected ? Visibility.Visible : Visibility.Hidden)
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)

        Row() {
          Text() {
            Span(this.vm.listFrom === FileListSelectViewFrom.RECYCLEBIN ? this.fileInfo.checkFileDeleteTime() :
            this.fileInfo.createTime)
            Span(this.fileInfo.fileSize === '0B' ? '' : '  ' + this.fileInfo.fileSize)
          }
          .fontSize(11)
          .fontColor('#9DA3AA')

          Text(this.expireTime)
            .fontSize(11)
            .fontColor(this.expireTimeColor)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .width('100%')
      }
      .layoutWeight(1)
      .height(40)
      .padding({ left: 12 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)

      Image(this.isSelected ? $r('app.media.file_selected_icon') : $r('app.media.file_unselected_icon'))
        .width(36)
        .height(48)
        .padding({ left: 12, top: 12, bottom: 12 })
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          this.checkAction()
        })
    }
    .width('100%')
    .height(64)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
}
