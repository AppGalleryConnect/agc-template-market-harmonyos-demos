@ComponentV2
export struct CommonButton {
  @Param cancelFunc: Function = () => {
  }
  @Param saveButton: Function = () => {
  }

  build() {
    Row() {
      Row() {
        Button('取消')
          .width('100%')
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
      .width('calc(50% - 6vp)')
      .margin({ right: 12 })
      .onClick(() => {
        this.cancelFunc()
      })

      Row() {
        Button('确认')
          .width('100%')
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor('#0A59F7')
      }
      .width('calc(50% - 6vp)')
      .onClick(() => {
        this.saveButton()
      })
    }
    .margin({ top: 28 })
  }
}