import { AppStorageV2 } from '@kit.ArkUI';
import { ChatBreakpoint, ChatContentSingleModel } from 'chat_base';
import { ChatBaseRow } from './ChatBaseRow';

/**
 * 图片消息
 */
@ComponentV2
export struct ChatImageRow {
  @Param @Require chatVM: ChatContentSingleModel;
  @Param @Require onChatAvatarClick: (chatVM: ChatContentSingleModel) => void;
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Param onChatBubbleClick: (chatVM: ChatContentSingleModel) => void =
    (_chatVM: ChatContentSingleModel) => {
    }

  @Builder
  render() {
    Image(this.chatVM.imageInfo![0].url)
      .draggable(false)
      .objectFit(ImageFit.Cover)
      .width(this.imageChatMaxWidth)
      .height($r('app.float.vp_120'))
      .onClick(() => this.onChatBubbleClick(this.chatVM))
  }

  build() {
    ChatBaseRow({
      childBuilder: () => {
        this.render();
      },
      chatVM: this.chatVM,
      onChatAvatarClick: this.onChatAvatarClick
    })
  }

  @Computed
  get imageChatMaxWidth() {
    let imageSingle = this.chatBreakpoint.getColumnWidth(this.getUIContext());
    //头像 36 + 头像和消息间隙 8
    return imageSingle * 3.5 + 36 - 44;
  }
}