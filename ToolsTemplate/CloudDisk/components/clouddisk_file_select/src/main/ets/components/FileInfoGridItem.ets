import { FileInfo, FileType } from 'common';
import { FileListSelectViewVM } from '../viewmodel/FileListSelectViewVM';

/**
 * @usage: 用于文件网格展示场景（宫格样式）。显示文件信息，包括图标、名称和选择状态。
 * 关键数据结构：FileInfo（文件信息，包含name名称、fileType文件类型）、isSelected（是否选中布尔值）、
 * checkAction（选择回调函数）、FileType（文件类型枚举，包含PrivateSpace隐私空间类型）。
 * 包含if逻辑：根据fileType判断是否为隐私空间（隐私空间不显示选择图标），根据isSelected显示不同的选择图标。
 * @layout: 相对布局。顶部居中为文件图标（72x72），右上角为选择图标（24x24，已选中显示蓝色对勾，
 * 未选中显示灰色圆圈），底部居中为文件名。整体高度122。
 * @constraints: fileInfo文件信息不能为空，checkAction回调函数必须正确处理选择操作，
 * 隐私空间类型文件不显示选择图标
 * @isGen: true
 * @fileType: component
 * @zhName: 文件信息网格项组件（宫格样式）
 */
@ComponentV2
export struct FileInfoGridItem {
  @Param @Require fileInfo: FileInfo;
  @Param isSelected: boolean = false
  @Event checkAction: () => void = () => {
  }

  build() {
    RelativeContainer() {
      Image(FileListSelectViewVM.getImageSourceNew(this.fileInfo.fileType, this.fileInfo.name, true))
        .width(72)
        .height(72)
        .objectFit(ImageFit.Contain)
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .margin({ top: 24 })
        .id('bigImage')

      Image(this.isSelected ? $r('app.media.file_selected_icon') : $r('app.media.file_unselected_icon'))
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
        .alignRules({
          top: { anchor: 'bigImage', align: VerticalAlign.Top },
          right: { anchor: 'bigImage', align: HorizontalAlign.End }
        })
        .visibility(this.fileInfo.fileType === FileType.PrivateSpace ? Visibility.None : Visibility.Visible)
        .margin({ top: -4, right: -4 })
        .onClick(() => {
          this.checkAction()
        })

      Text(this.fileInfo.name)
        .fontSize(11)
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Medium)
        .alignRules({
          top: { anchor: 'bigImage', align: VerticalAlign.Bottom },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .margin({ top: 4 })
    }
    .width('100%')
    .height(122)
  }
}
