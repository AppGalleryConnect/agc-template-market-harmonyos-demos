import { FileInfo } from 'common';

/**
 * @usage: 用于文件目录展示场景（无选择功能）。显示文件夹信息，包括图标、名称、创建时间和收藏状态。
 * 关键数据结构：FileInfo（文件信息，包含name名称、createTime创建时间、isCollected收藏状态）。
 * 包含if逻辑：根据isCollected判断是否显示收藏图标。
 * @layout: 横向布局。左侧为文件夹图标（40x40），中间为文件信息列（文件名和创建时间垂直排列，左对齐），
 * 文件名右侧显示收藏图标（收藏时显示）。整体高度64，左对齐。
 * @constraints: fileInfo文件信息不能为空，name名称和createTime创建时间必须有效
 * @isGen: true
 * @fileType: component
 * @zhName: 文件目录单元格组件（无选择）
 */
@ComponentV2
export struct DirectorUnSelectCell {
  @Param @Require fileInfo: FileInfo;

  build() {
    Row() {
      Image($r('app.media.director_icon'))
        .width(40)
        .height(40)
        .objectFit(ImageFit.Contain)

      Column() {
        Row() {
          Text(this.fileInfo.name)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.Black)

          Image($r('app.media.icon_collect'))
            .width(16)
            .height(16)
            .objectFit(ImageFit.Contain)
            .margin({ left: 6 })
            .visibility(this.fileInfo.isCollected ? Visibility.Visible : Visibility.Hidden)
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)

        Text(this.fileInfo.createTime)
          .fontSize(11)
          .fontColor('#9DA3AA')
      }
      .layoutWeight(1)
      .height(40)
      .padding({ left: 12, right: 12 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(64)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
}
