/**
 * 评论输入栏组件
 */
@ComponentV2
export struct CommentInputBar {
  @Param commentText: string = ''
  @Param isCommentInputFocused: boolean = false
  @Param onTextChange: (value: string) => void = () => {}
  @Param onFocusCallback: () => void = () => {}
  @Param onBlurCallback: () => void = () => {}
  @Param onSubmit: () => void = () => {}
  @Param inputBackgroundColor: ResourceColor = '#F5F5F5'
  @Param showWrapper: boolean = true  // 是否显示外层 Row 包装

  build() {
    if (this.showWrapper) {
      Row() {
        this.renderInput()
      }
      .width('100%')
      .height(60)
      .alignItems(VerticalAlign.Center)
    } else {
      this.renderInput()
    }
  }

  @Builder
  renderInput() {
    TextInput({
      placeholder: '写评论',
      text: this.commentText
    })
      .layoutWeight(1)
      .height(40)
      .backgroundColor(this.inputBackgroundColor)
      .borderRadius(20)
      .padding({ left: 16, right: 16 })
      .onChange((value: string) => {
        this.onTextChange(value)
      })
      .onFocus(() => {
        this.onFocusCallback()
      })
      .onBlur(() => {
        this.onBlurCallback()
      })
      .onSubmit(() => {
        this.onSubmit()
      })
  }
}
