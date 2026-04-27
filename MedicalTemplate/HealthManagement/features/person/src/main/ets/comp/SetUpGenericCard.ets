@ComponentV2
export struct SetUpGenericCard {
  @BuilderParam content: () => void

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .borderRadius($r('sys.float.corner_radius_level8'))
    .margin({ top: $r('app.float.vp_8') })
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }
}