import { CMChatConversation } from 'instant_messaging';

@ComponentV2
export struct MessageSwipeRow {
  @Param @Require messageVM: CMChatConversation;
  @Event onDeleteClick: () => void = () => {
  }
  @Event onTopClick: () => void = () => {
  }

  build() {
    Row() {
      Row() {
        Image($r('app.media.message_delete_icon'))
          .width($r('app.float.vp_24'))
          .height($r('app.float.vp_24'))
          .objectFit(ImageFit.Fill)
      }
      .width($r('app.float.vp_72'))
      .height($r('app.float.vp_72'))
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#E84026')
      .onClick(() => this.onDeleteClick())

      Row() {
        if (this.messageVM.isPinned) {
          Text('取消\n置顶')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('app.color.color_99000000'))
            .fontWeight(FontWeight.Regular)
            .lineHeight($r('app.float.vp_20'))
            .maxLines(2)
        } else {
          Image($r('app.media.message_top_icon'))
            .width($r('app.float.vp_24'))
            .height($r('app.float.vp_24'))
            .objectFit(ImageFit.Fill)
        }
      }
      .width($r('app.float.vp_72'))
      .height($r('app.float.vp_72'))
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.color_F1F3F5'))
      .onClick(() => this.onTopClick())
    }
    .width($r('app.float.vp_144'))
    .height($r('app.float.vp_72'))
  }
}