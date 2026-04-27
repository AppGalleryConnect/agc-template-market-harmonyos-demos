import { MessageItem } from '../model/model';
import { MessageManagerService } from '../model/MessageMangerService'
import { MessageCard } from './MessageCard';

@ComponentV2
export struct MessageList {
  @Param @Require list: MessageItem[];
  messageManagerService: MessageManagerService = MessageManagerService.instance;
  private scroller: ListScroller = new ListScroller();
  @Event itemClick: (item: MessageItem) => void = () => {
  };

  @Builder
  itemEnd(item: MessageItem) {
    Row() {
      if (!item.hasRead) {
        Text('标为已读')
          .height('100%')
          .backgroundColor('#376BFC')
          .fontSize(14)
          .fontColor(Color.White)
          .padding({
            left: 12,
            right: 12
          })
          .onClick(() => {
            this.messageManagerService.setReadById(item.id);
            this.scroller.closeAllSwipeActions()
          })
      }

      Text('删除')
        .height('100%')
        .backgroundColor('#E84026')
        .fontSize(14)
        .fontColor(Color.White)
        .padding({
          left: 18,
          right: 18
        })
        .onClick(() => {
          this.messageManagerService.deleteById(item.id)
        })
    }
    .margin({
      left: 8
    })
  }

  build() {
    if (this.list.length === 0) {
      Column() {
        Image($r('app.media.no_data'))
          .width(120)
          .height(120)

        Text('暂无消息')
          .fontSize(14)
          .fontColor('rgba(0,0,0,0.6)')
      }
      .width('100%')
      .margin({ top: 90 })
      .alignItems(HorizontalAlign.Center)

    } else {
      List({ scroller: this.scroller }) {
        ForEach(this.list, (item: MessageItem) => {
          ListItem() {
            MessageCard({
              messageItem: item,
              itemClick: () => {
                this.itemClick(item)
              }
            })
          }
          .height(64)
          .swipeAction({
            end: {
              builder: () => {
                this.itemEnd(item)
              }
            }
          })
        }, (item: string) => JSON.stringify(item))
      }
      .width('100%')
      .height('100%')
      .padding(8)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .divider({
        strokeWidth: 0.5,
        color: 'rgba(0,0,0,0.2)'
      })
    }
  }
}