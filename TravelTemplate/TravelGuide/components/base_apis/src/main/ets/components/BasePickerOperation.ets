@ComponentV2
export struct BasePickerOperation {
  @Param currentDate: string = ''
  @Param isShowTitle: boolean = false
  @Param isBottom: boolean = false
  @Event cancel: () => void = () => {
  }
  @Event confirm: () => void = () => {
  }

  build() {
    Row() {
      Row() {
        Text('取消')
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Bold)
      }
      .onClick(() => {
        this.cancel()
      })

      Row() {
        Text(this.currentDate).fontWeight(FontWeight.Bold)
          .fontSize(20)
      }
      .visibility(this.isShowTitle ? Visibility.Visible : Visibility.None)

      Row() {
        Text('确认')
          .fontColor('#FFE94949')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Bold)
      }
      .onClick(() => {
        this.confirm()
      })
    }
    .width('100%')
    .padding({
      left: 20,
      right: 20,
      top: 10,
      bottom: 10,
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
    .padding({
      left: 32,
      right: 32,
      top: this.isBottom ? 24 : 16,
      bottom: this.isBottom ? 24 : 16,
    })
  }
}