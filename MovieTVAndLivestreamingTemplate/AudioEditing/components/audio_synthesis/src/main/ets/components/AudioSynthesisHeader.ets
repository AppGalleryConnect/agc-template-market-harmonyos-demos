@ComponentV2
export struct AudioSynthesisHeader {
  @Param @Require backHandle: ()=>void
  @Param @Require title: string

  build() {
    Row() {
      Row() {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontColor([$r('sys.color.icon_on_primary')])
            .fontSize(24)
        }
        .backgroundColor(Color.Transparent)
        .width(40)
        .height(40)
        .onClick(() => {
          this.backHandle()
        })

        Text(this.title).fontSize(20).fontColor(Color.White).margin({ left: 8 })
      }.layoutWeight(1)
    }.width('100%').justifyContent(FlexAlign.SpaceBetween)
  }
}
