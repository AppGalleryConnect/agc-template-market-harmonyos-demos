import { ChatContentSingleModel, ChatTypeEnum } from 'chat_base';
import { PromptActionClass } from '../utils/PromptActionClass';
import { promptWrap } from './PromptDialogBuilder';

@ComponentV2
export struct ChatContentRow {
  @BuilderParam childBuilder: (pageId?: string) => void = this.defaultBuilder;
  @Param @Require chatVM: ChatContentSingleModel;

  @Builder
  defaultBuilder(_pageId?: string) {
    // 兜底布局
    Text('无内容页面')
  }

  build() {
    Row() {
      if (this.chatVM.chatType === ChatTypeEnum.CHAT_TYPE_TEXT) {
        Row() {
          this.childBuilder()
        }
        .padding({
          top: $r('app.float.vp_10'),
          left: $r('app.float.vp_12'),
          bottom: $r('app.float.vp_10'),
          right: $r('app.float.vp_12')
        })
        .backgroundColor(this.chatVM.isOwner ? '#0A59F7' : Color.White)
      } else {
        this.childBuilder()
      }
    }
    .borderRadius({
      topLeft: this.chatVM.isOwner ? $r('app.float.vp_12') : $r('app.float.vp_4'),
      topRight: this.chatVM.isOwner ? $r('app.float.vp_4') : $r('app.float.vp_12'),
      bottomLeft: $r('app.float.vp_12'),
      bottomRight: $r('app.float.vp_12')
    })
    .clip(true)
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction((event: GestureEvent | undefined) => {
          if (event && PromptActionClass.getDeviceType() !== -1) {
            const frameNode: FrameNode | null = this.getUIContext().getFrameNodeByUniqueId(this.getUniqueId());
            const childFrameNode: FrameNode | null = frameNode
            const width = (childFrameNode?.getMeasuredSize().width || 0) + 'px'
            const height = (childFrameNode?.getMeasuredSize().height || 0) + 'px'
            const dx = childFrameNode?.getPositionToWindow().x || 0
            const dy = childFrameNode?.getPositionToWindow().y || 0
            PromptActionClass.setContext(this.getUIContext())
            PromptActionClass.initBuilder(width, height, dx, dy, this.chatVM, promptWrap)
            PromptActionClass.openDialog()
          }
        })
    )
  }
}