import { FileBaseInfo } from '../model/FileBaseInfo';

// 文件目录列表
@ComponentV2
export struct FileBaseDirectorCell {
  @Param @Require fileInfo: FileBaseInfo;

  build() {
    Row() {
      Image($r('app.media.base_director_icon'))
        .objectFit(ImageFit.Contain)
        .width(40)
        .height(40)

      Column() {
        Row() {
          Text(this.fileInfo.name)
            .fontSize(14)
            .fontColor(Color.Black)
            .fontWeight(FontWeight.Medium)


          Image($r('app.media.base_collect_icon'))
            .width(16)
            .height(16)
            .margin({ left: 6 })
            .objectFit(ImageFit.Contain)
            .visibility(this.fileInfo.isCollected ? Visibility.Visible : Visibility.Hidden)
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)

        Text(this.fileInfo.createTime)
          .fontColor('#9DA3AA')
          .fontSize(11)
      }
      .height(40)
      .layoutWeight(1)
      .padding({ left: 12, right: 12 })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(64)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
}
