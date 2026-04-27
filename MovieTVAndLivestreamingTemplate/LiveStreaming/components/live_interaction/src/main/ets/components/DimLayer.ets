@ComponentV2
export struct DimLayer {
  @Param @Require dimOpacity: number
  @Param @Require dimBlur: number

  build() {
    Stack()
      .width('100%')
      .height('100%')
      .opacity(this.dimOpacity)
      .backdropBlur(this.dimBlur)
  }
}