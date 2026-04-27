@ComponentV2
export struct GenericCard {
  @BuilderParam content: () => void

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .margin({ top: $r('app.float.vp_8'), bottom: $r('app.float.vp_6') })
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }
}