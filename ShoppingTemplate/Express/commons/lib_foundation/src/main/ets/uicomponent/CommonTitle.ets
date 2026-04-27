@ComponentV2
export struct CommonTitle {
  @Param title: string = ''
  @Param func: Function = () => {
  }

  build() {
    Row() {
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
      Image($r('app.media.ic_close'))
        .width(40)
        .height(40)
        .onClick(() => {
          this.func()
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .margin({ bottom: 30 })
  }
}