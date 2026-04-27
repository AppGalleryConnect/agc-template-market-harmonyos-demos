@ComponentV2
export struct UserItem {
  @Param title: string = ''
  @Param image: ResourceStr = ''
  @Param url: string = ''
  @Param isLine: boolean = true
  @Param @Once messageNum: number = 0

  build() {
    Row() {
      if (this.image) {
        Image(this.image)
          .size({ width: 24, height: 24 })
          .fillColor($r('sys.color.font_primary'))
          .draggable(false)
          .margin({ right: 16 })
      }
      Row() {
        Text(this.title)
          .fontSize($r('sys.float.Subtitle_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))

        Blank()
        if (this.messageNum > 0) {
          Text(this.messageNum > 99 ? '99+' : this.messageNum.toString())
            .textAlign(TextAlign.Center)
            .backgroundColor($r('sys.color.warning'))
            .borderRadius(8)
            .size({ width: 30, height: 16 })
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize(10)
            .fontWeight(400)
            .margin({ right: 4 })
        }
        Image($r('app.media.iconRight'))
          .size({ width: 18, height: 18 })
      }
      .layoutWeight(1)
    }
    .padding({
      top: 12,
      bottom: 12,
      left: 8,
      right: 8,
    })
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .alignItems(VerticalAlign.Center)
  }
}