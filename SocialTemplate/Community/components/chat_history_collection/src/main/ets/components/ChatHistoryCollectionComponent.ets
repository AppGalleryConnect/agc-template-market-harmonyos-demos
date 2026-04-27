import { AppStorageV2 } from '@kit.ArkUI';
import { ChatBreakpoint, ChatContentSingleModel, ChatTypeEnum } from 'chat_base';
import { MsgCollectItem } from './MsgCollectItem';
import { MsgCollectLocationItem } from './MsgCollectLocationItem';
import { ChatMsgCollectModel } from '../viewmodel/ChatMsgCollectModel';

@ComponentV2
export struct ChatHistoryCollectionComponent {
  @Param onChatBubbleClick: (chatVM: ChatContentSingleModel) => void = (_chatVM: ChatContentSingleModel) => {
  };
  @Local chatMsgCollectVM: ChatMsgCollectModel = new ChatMsgCollectModel();
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;

  build() {
    List() {
      if (this.chatMsgCollectVM.msgCollectList?.length > 0) {
        Repeat<ChatContentSingleModel>(this.chatMsgCollectVM.msgCollectList)
          .each((ri: RepeatItem<ChatContentSingleModel>) => {
            ListItem() {
              if (ChatTypeEnum.CHAT_TYPE_LOCATION === ri.item.chatType) {
                MsgCollectLocationItem({ collectMsg: ri.item, onChatBubbleClick: this.onChatBubbleClick });
              } else {
                MsgCollectItem({ collectMsg: ri.item, onChatBubbleClick: this.onChatBubbleClick });
              }
            }
          })
          .key((item: ChatContentSingleModel): string => item.chatId)
          .virtualScroll()
      } else {
        ListItem() {
          Column() {
            Text($r('app.string.empty_text'))
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_tertiary'))
              .lineHeight($r('app.float.vp_14'))
              .margin({
                top: $r('app.float.vp_18')
              })
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .width('100%')
          .height('100%')
          .layoutWeight(1)
        }
        .width('100%')
        .height('auto')
        .layoutWeight(1)
      }
    }
    .cachedCount(2)
    .layoutWeight(1)
    .width('100%')
    .height('auto')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .padding({
      left: this.chatBreakpoint.pagePadding,
      right: this.chatBreakpoint.pagePadding,
      bottom: this.chatBreakpoint.bottomValue,
      top: $r('app.float.vp_12')
    })
  }
}
