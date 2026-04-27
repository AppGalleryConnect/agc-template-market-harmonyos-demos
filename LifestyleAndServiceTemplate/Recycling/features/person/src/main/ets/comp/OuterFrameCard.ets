@ComponentV2
export struct OuterFrameCard {
  @BuilderParam content: () => void

  build() {
    Column() {
      if (this.content) {
        this.content()
      }
    }
    .size({ width: '100%' })
    .padding({ left: 12, right: 12 })
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
  }
}