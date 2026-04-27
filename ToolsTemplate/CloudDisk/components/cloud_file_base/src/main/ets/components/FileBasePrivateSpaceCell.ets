import { FileBaseInfo } from '../model/FileBaseInfo';

// 隐私空间cell
@ComponentV2
export struct FileBasePrivateSpaceCell {
  @Param @Require fileInfo: FileBaseInfo;

  build() {
    Column(){
      Row() {
        Image($r('app.media.base_privatespace_icon'))
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
      Row() {
        Text(this.fileInfo.updateTime === '' ? this.fileInfo.createTime :
          this.fileInfo.usefullTime + '  ' + this.fileInfo.fileSize)
          .fontSize(11)
          .fontColor('#9DA3AA')
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .width('100%')
    }
    .width('100%')
  }
}
