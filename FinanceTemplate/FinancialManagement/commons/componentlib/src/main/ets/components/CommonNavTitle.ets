@ComponentV2
export struct CommonNavTitle {
  @Param title: string = ''

  build() {
    Row() {
      Text(this.title)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .height(32)
    .margin({ top: 12, bottom: 12 })
  }
}