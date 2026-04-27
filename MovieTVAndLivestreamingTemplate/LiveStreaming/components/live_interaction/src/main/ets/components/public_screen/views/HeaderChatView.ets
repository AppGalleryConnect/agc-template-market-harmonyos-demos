@ComponentV2
export struct HeaderChatView {
  @Param leftIcon: string | Resource | null = null
  @Param rightIcon: string | Resource | null = null
  @Param @Require content: string

  build() {
    Text() {
      Span(this.content)
    }
    .fontSize(14)
    .fontWeight(500)
  }
}

@Preview
@ComponentV2
export struct HeaderChatViewPreview {
  @Param @Require content: string =
    '每天下午2-10点直播'

  build() {
    Row(){
      HeaderChatView({content:this.content})
    }
  }
}
