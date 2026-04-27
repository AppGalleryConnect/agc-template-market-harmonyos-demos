import { RichChat, RichEditorSpan } from './RichChat';

@ComponentV2
export struct RichChatView {
  @Param @Require content: RichEditorSpan[]
  @Param @Require userName: string
  // 点赞等级
  @Param like: boolean = false;
  @Param likeLevel: number = 0;
  // 主播粉团级别
  @Param fans: Boolean = false
  @Param fanName: string | null = null
  @Param fanLevel: number = 0
  // 打赏级别
  @Param pay: boolean = false;
  @Param payLevel: number = 0
  @Local testEmo:ResourceStr = $r('app.media.emoji_3')
  build() {
    Text() {
      if (this.like) {
        this.likeLevelImgSpanBuild()
        Span(' ')
      }
      if (this.fans) {
        this.FansImgBuilder()
        Span(' ')
      }
      if (this.pay) {
        this.payLevelImgBuilder()
        Span(' ')
      }
      Span(this.userName + '：')
        .fontColor($r('sys.color.font_on_secondary'))
      ForEach(this.content, (richEditorSpan: RichEditorSpan) => {
        if (richEditorSpan.type === 'text') {
          Span(richEditorSpan.value)
            .width(20)
        } else if (richEditorSpan.type === 'image') {
          ImageSpan(richEditorSpan.resourceValue as ResourceStr)
            .width(20)
        } else {
          Span(`${richEditorSpan.value}(`)
            .width(20)
        }
      }, (richEditorSpan: RichEditorSpan, index: number) => index + '__' + JSON.stringify(richEditorSpan))
    }
    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
    .fontColor($r('sys.color.font_on_primary'))
    .fontSize(14)
    .fontWeight(500)
    .lineHeight(19)
    .backgroundColor('rgba(0, 0, 0, 0.4)')
    .borderRadius(12)
  }

  @Builder
  likeLevelImgSpanBuild() {
    ContainerSpan() {
      ImageSpan($r('app.media.ic_activity'))
        .height(20)
        .width(20)
      Span(this.likeLevel.toString())
    }.textBackgroundStyle({ color: '#b3d862da', radius: 5 })
  }

  @Builder
  FansImgBuilder() {
    ContainerSpan() {
      ImageSpan($r('app.media.ic_vip'))
        .height(20)
        .width(20)
      Span(this.fanLevel.toString())
        .backgroundColor('')
    }.textBackgroundStyle({ color: '#b36cb8e5', radius: 5 })
  }

  @Builder
  payLevelImgBuilder() {
    ContainerSpan() {
      ImageSpan($r('app.media.ic_vip'))
        .height(20)
        .width(20)
      Span(this.payLevel.toString())
    }.textBackgroundStyle({ color: '#b362da98', radius: 5 })
  }
}

@Builder
export function richChatViewBuilder(chat: RichChat) {
  RichChatView({
    userName: chat.userName,
    content: chat.richContent,
    like: chat.like,
    likeLevel: chat.likeLevel,
    fans: chat.fans,
    fanLevel: chat.fanLevel,
    fanName: chat.fanName,
    pay: chat.pay,
    payLevel: chat.payLevel
  })
}

@Preview
@ComponentV2
export struct RichChatViewPreview {
  leftIcon: string | Resource | null = null
  rightIcon: string | Resource | null = null
  content: string = '正方不占优势啊,这怎么打呀不行，要开挂才行'
  userName: string = '卡夫卡的甲虫'
  chat: RichChat = new RichChat(this.userName,
    [{ type: 'text', value: '支持啊' }, { type: 'image', resourceValue: $r('app.media.emoji_1') },
      { type: 'text', value: '好！666！' }])

  build() {
    Column() {
      richChatViewBuilder(this.chat)
    }.backgroundColor('rgba(0, 0, 0, 0.4)')
    .height('100%')
    .width('100%')
  }
}
