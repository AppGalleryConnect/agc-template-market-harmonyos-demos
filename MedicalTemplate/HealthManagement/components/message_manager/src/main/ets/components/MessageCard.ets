import { MessageItem } from '../model/model';
import { MessageManagerService } from '../model/MessageMangerService'

@ComponentV2
export struct MessageCard {
  @Param @Require messageItem: MessageItem;
  @Event itemClick: () => void = () => {
  };
  messageManagerService: MessageManagerService = MessageManagerService.instance;

  build() {
    Column({ space: 2 }) {
      Row() {
        Text(this.messageItem.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('rgba(0,0,0,0.9)')
        Blank()
        Text(this.messageItem.time)
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
          .fontColor('rgba(0,0,0,0.4)')
      }
      .width('100%')
      .height(21)
      .alignItems(VerticalAlign.Center)

      Row() {
        Text(this.messageItem.content)
          .fontSize(12)
          .fontColor('rgba(0,0,0,0.4)')
          .layoutWeight(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
        Blank()
        if (!this.messageItem.hasRead) {
          Text()
            .width(6)
            .height(6)
            .borderRadius('50%')
            .backgroundColor('#E84026')
            .margin({
              left: 8
            })
        }
      }
      .width('100%')
    }
    .width('100%')
    .onClick(() => {
      this.itemClick();
      this.messageManagerService.setReadById(this.messageItem.id)
    })
  }
}