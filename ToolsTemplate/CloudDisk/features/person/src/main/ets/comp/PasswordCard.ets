@ComponentV2
export struct PasswordCard {
  @BuilderParam content: () => void

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .borderRadius(16)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }
}