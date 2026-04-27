@ComponentV2
export struct UserItem {
  @Param title: string = ''
  @Param image: ResourceStr = ''
  @Param url: string = ''
  @Param isLine: boolean = true
  @Param @Once messageNum: number = 0

  build() {
    Row() {
      Row() {
        Text(this.title)
          .fontSize(16)
          .fontColor('rgba(0, 0, 0, 1)')
          .fontWeight(FontWeight.Normal)

        Blank()

        Image($r('app.media.ic_right_enter')).width(13).height(25)
      }
      .layoutWeight(1)

    }
    .height(56)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .alignItems(VerticalAlign.Center)
  }
}