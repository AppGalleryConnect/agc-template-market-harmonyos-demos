import { SimpleChat } from './NormalChat';

@ComponentV2
export struct NormalChatView {
  @Param @Require content: string
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

  build() {
    Text() {
      if (this.like) {
        this.likeLevelImgSpanBuild()
        Span(' ')
      }
      if (this.fans) {
        this.fansImgBuilder()
        Span(' ')
      }
      if (this.pay) {
        this.payLevelImgBuilder()
        Span(' ')
      }
      Span(this.userName + '：')
        .fontColor($r('sys.color.font_on_secondary'))
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
  fansImgBuilder() {
    ContainerSpan() {
      ImageSpan($r('app.media.ic_diamond'))
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
export function normalChatViewBuilder(chat: SimpleChat) {
  NormalChatView({
    userName: chat.userName,
    content: chat.content,
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
export struct NormalChatViewPreview {
  leftIcon: string | Resource | null = null
  rightIcon: string | Resource | null = null
  content: string = '正方不占优势啊,这怎么打呀不行，要开挂才行'
  userName: string = '卡夫卡的甲虫'
  chat: SimpleChat = new SimpleChat(this.userName, this.content)
  build() {
    Column() {
      normalChatViewBuilder(this.chat)
      normalChatViewBuilder(this.chat)
      normalChatViewBuilder(this.chat)
    }.backgroundColor('rgba(0, 0, 0, 0.4)')
    .height('100%')
    .width('100%')
  }
}
