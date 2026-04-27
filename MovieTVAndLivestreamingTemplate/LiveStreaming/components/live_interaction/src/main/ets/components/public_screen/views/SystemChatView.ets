import { SimpleChat } from './NormalChat'
import { SystemChat } from './SystemChat'

@ComponentV2
export struct SystemChatView {
  @Param leftIcon: string | Resource | null = null
  @Param rightIcon: string | Resource | null = null
  @Param @Require content: string

  build() {
    Text() {
      Span('系统消息: ')
      Span(this.content)
    }
    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
    .fontColor($r('sys.color.font_on_primary'))
    .fontSize(14)
    .fontWeight(500)
    .lineHeight(19)
    .backgroundColor('rgba(0, 0, 0, 0.4)')
    .borderRadius(12)
  }
}
@Builder
export function systemChatViewBuilder(chat: SystemChat) {
  SystemChatView({
    content: chat.content,
  })
}
@Preview
@ComponentV2
export struct SystemChatViewPreview {
  @Param @Require content: string =
    '系统提示：欢迎来到华为直播间！华为视频禁止任何传播违法、违规、低俗等信息的行为，一经发现将予以封禁处理。请勿轻信以任何方式的诱导打赏、私下交易等行为，以人身或财产损失。'

  build() {
    Row(){
      SystemChatView({content:this.content})
    }
  }
}
