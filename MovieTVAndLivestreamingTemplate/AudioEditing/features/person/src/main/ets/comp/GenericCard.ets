@ComponentV2
export struct GenericCard {
  @BuilderParam content: () => void

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .margin({ top: 8 })
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }
}