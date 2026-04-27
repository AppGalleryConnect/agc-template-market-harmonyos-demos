
@ComponentV2
export struct BottomBtn {
  @Param text: ResourceStr = '';
  @Param paddingSize: Padding = {};
  @Event onAction: () => void;

  build() {
    Row() {
      Button(this.text)
        .width('100%')
        .constraintSize({ maxWidth: 448 })
        .onClick(() => {
          this.onAction?.()
        })
    }
    .width('100%')
    .padding(this.paddingSize)
    .justifyContent(FlexAlign.Center)
  }
}