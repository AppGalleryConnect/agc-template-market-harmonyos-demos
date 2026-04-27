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
          .fontColor($r('sys.color.font_tertiary'))
          .fontSize($r('sys.float.Title_S'))
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
          .fontColor($r('sys.color.font_tertiary'))
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
      }
      .onClick(() => {
        this.confirm()
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .padding({
      left: 28,
      right: 28,
      top: this.isBottom ? 24 : 16,
      bottom: this.isBottom ? 24 : 16,
    })
  }
}