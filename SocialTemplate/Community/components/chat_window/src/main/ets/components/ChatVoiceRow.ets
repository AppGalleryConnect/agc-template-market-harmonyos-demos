import { AppStorageV2 } from '@kit.ArkUI';
import { ChatBreakpoint, ChatContentSingleModel } from 'chat_base';
import { ChatBaseRow } from './ChatBaseRow';

/**
 * 语音消息
 */
@ComponentV2
export struct ChatVoiceRow {
  @Param @Require chatVM: ChatContentSingleModel;
  @Param @Require onChatAvatarClick: (chatVM: ChatContentSingleModel) => void;
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Param onChatBubbleClick: (chatVM: ChatContentSingleModel) => void =
    (_chatVM: ChatContentSingleModel) => {
    }

  @Builder
  render() {
    Column() {
      Row() {
        Image(this.chatVM.soundStatus ? $r('app.media.voice_message_icon_active') : $r('app.media.voice_message_icon'))
          .size({ width: 24, height: 24 })

        Text(this.chatVM.soundInfo?.duration.toString() + 's')
          .fontSize($r('app.float.vp_14'))
          .fontWeight(FontWeight.Regular)
          .fontColor(Color.Black)
          .lineHeight($r('app.float.vp_22'))
          .margin({ left: $r('app.float.vp_8') })
      }
      .padding({ left: $r('app.float.vp_8') })
      .backgroundColor(Color.White)
      .borderRadius($r('app.float.vp_4'))
      .size({ width: 90, height: 38 })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)

      if (this.chatVM.speechToText.length > 0) {
        Text(this.chatVM.speechToText)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor(Color.Black)
          .lineHeight($r('app.float.vp_20'))
          .maxLines(-1)
          .backgroundColor(Color.White)
          .margin({ top: $r('app.float.vp_4') })
          .borderRadius({
            topLeft: $r('app.float.vp_4'),
            topRight: $r('app.float.vp_12'),
            bottomLeft: $r('app.float.vp_12'),
            bottomRight: $r('app.float.vp_12')
          })
          .padding({
            left: $r('app.float.vp_12'),
            right: $r('app.float.vp_12'),
            top: $r('app.float.vp_8'),
            bottom: $r('app.float.vp_8'),
          })
      }
    }
    .constraintSize({
      minWidth: 90,
      maxWidth: '100%'
    })
    .justifyContent(FlexAlign.Start)
    .alignItems(this.chatVM.isOwner ? HorizontalAlign.End : HorizontalAlign.Start)
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
}