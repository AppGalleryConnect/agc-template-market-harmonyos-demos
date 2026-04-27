@ComponentV2
export struct RowData {
  @Require @Param title: string
  @Require @Param data: string
  @Param color: ResourceColor = '#0A59F7'

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
          .fontColor(this.color)
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