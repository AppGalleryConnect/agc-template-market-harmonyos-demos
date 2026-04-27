@ComponentV2
export struct CommonSaveButton {
  @Param value: string = ''
  @Event changeValue: () => void = () => {
  }

  build() {
    Stack() {
      Row()
        .width('100%')
        .height(40)
        .borderRadius(20)
        .backgroundColor('#E4480C')
        .opacity(this.value ? 1 : 0.4)

      Row() {
        Text('保存')
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.changeValue()
      })
    }
    .position({ bottom: 0 })
  }
}