import { AppStorageV2 } from '@kit.ArkUI';
import { ChatBreakpoint, ChatContentSingleModel, VideoImageView } from 'chat_base';
import { ChatBaseRow } from './ChatBaseRow';

/**
 * 视频消息页面
 */
@ComponentV2
export struct ChatVideo {
  @Param @Require chatVM: ChatContentSingleModel;
  @Param @Require onChatAvatarClick: (chatVM: ChatContentSingleModel) => void;
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Param @Require onChatBubbleClick: (chatVM: ChatContentSingleModel) => void;

  @Builder
  render() {
    VideoImageView({ videpImage: this.chatVM.snapshotPath })
      .width(this.videoChatMaxWidth)
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
  get videoChatMaxWidth() {
    let videoSingle = this.chatBreakpoint.getColumnWidth(this.getUIContext());
    //头像 36 + 头像和消息间隙 8
    return videoSingle * 3.5 + 36 - 44;
  }
}