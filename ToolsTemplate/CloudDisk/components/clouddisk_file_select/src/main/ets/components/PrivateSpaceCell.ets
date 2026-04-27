import { FileInfo } from 'common';

/**
 * @usage: 用于隐私空间入口展示场景（列表样式）。显示隐私空间图标和名称。
 * 关键数据结构：FileInfo（文件信息，包含name名称）。
 * @layout: 横向布局。左侧为隐私空间图标（40x40），右侧为隐私空间名称（左对齐）。整体高度64，左对齐。
 * @constraints: fileInfo文件信息不能为空，name名称必须有效
 * @isGen: true
 * @fileType: component
 * @zhName: 隐私空间单元格组件
 */
@ComponentV2
export struct PrivateSpaceCell {
  @Param @Require fileInfo: FileInfo;

  build() {
    Row() {
      Image($r('app.media.privatespace_icon'))
        .width(40)
        .height(40)
        .objectFit(ImageFit.Contain)

      Text(this.fileInfo.name)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.Black)
        .margin({ left: 12 })
    }
    .width('100%')
    .height(64)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
}
