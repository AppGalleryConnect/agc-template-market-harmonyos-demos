import { MessageItem } from '../model/model';

@ComponentV2
export struct MessageDetail {
 @Param @Require message: MessageItem;
  build() {
    Column() {
      Text(this.message?this.message.title:'')
        .fontColor('rgba(0,0,0,0.9)')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .lineHeight(24)
        .margin({
          bottom:4,
          top:16
        })
        .width('100%')
      Text(this.message?this.message.time:'')
        .fontSize(12)
        .fontColor('rgba(0,0,0,0.4)')
        .fontWeight(FontWeight.Regular)
        .margin({
          bottom:24
        })
        .width('100%')
      Text(this.message?this.message.content:'')
        .width('100%')
    }
    .width('100%')
  }
}