import { ChatContentSingleModel, ChatConversationType } from 'chat_base';
import { ChatContentRow } from './ChatContentRow';

@ComponentV2
export struct ChatBaseRow {
  @BuilderParam childBuilder: (pageId?: string) => void = this.defaultBuilder;
  @Param @Require chatVM: ChatContentSingleModel;
  @Param @Require onChatAvatarClick: (chatVM: ChatContentSingleModel) => void;

  @Builder
  defaultBuilder(_pageId?: string) {
    // 兜底布局
    Text('无内容页面')
  }

  @Builder
  avatarBuilder() {
    Image(this.chatVM.avatarUrl.startsWith('http') ? this.chatVM.avatarUrl : $r('app.media.' + this.chatVM.avatarUrl))
      .width($r('app.float.vp_36'))
      .height($r('app.float.vp_36'))
      .objectFit(ImageFit.Auto)
      .borderRadius($r('sys.float.corner_radius_level5'))
      .onClick(() => {
        this.onChatAvatarClick?.(this.chatVM);
      })
  }

  build() {
    Row() {
      Row() {
        if (this.chatVM.isOwner) {
          ChatContentRow({
            childBuilder: this.childBuilder,
            chatVM: this.chatVM
          });

          Blank().width($r('app.float.vp_8'))
          this.avatarBuilder();
        } else {
          this.avatarBuilder();
          Blank().width($r('app.float.vp_8'))

          Column() {
            if (this.chatVM.conversationType === ChatConversationType.CHAT_GROUP) {
              Text(this.groupChatSender)
                .fontSize($r('sys.float.Body_S'))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('app.color.color_66000000'))
                .lineHeight($r('app.float.vp_18'))
                .maxLines(1)
              Blank()
                .height($r('app.float.vp_4'))
            }

            ChatContentRow({
              childBuilder: this.childBuilder,
              chatVM: this.chatVM
            });
          }
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)
        }
      }
      .justifyContent(this.chatVM.isOwner ? FlexAlign.End : FlexAlign.Start)
      .alignItems(VerticalAlign.Top)
      .width('100%')
    }
    .justifyContent(this.chatVM.isOwner ? FlexAlign.End : FlexAlign.Start)
    .width('100%')
  }

  @Computed
  get groupChatSender() {
    if (this.chatVM.conversationType === ChatConversationType.CHAT_GROUP) {
      if (this.chatVM.friendRemark.length > 0) {
        return this.chatVM.friendRemark;
      } else {
        return this.chatVM.nickName;
      }
    }

    return '';
  }
}