@ComponentV2
export struct RowData {
  @Require @Param title: string
  @Require @Param data: string

  build() {
    Row() {
      Row() {
        Text(this.title)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('50%')
      .height('100%')

      Row() {
        Text(this.data)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor('#0A59F7')
      }
      .width('50%')
      .height('100%')
    }
    .width('100%')
    .height(40)
    .padding({ left: 12, right: 12 })
    .backgroundColor('rgba(0, 0, 0, 0.05)')
    .margin({ bottom: 12 })
    .borderRadius(8)
  }
}