
const TAG = 'AudioSaveHeader'

@ComponentV2
export struct AudioSaveHeader {
  @Param @Require saveHandle: ()=>void
  @Param @Require backHandle: ()=>void
  @Param @Require title: string
  @Param buttonText: string = '保存'

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

      Text(this.buttonText)
        .fontSize(14)
        .fontColor('#000000')
        .width(64)
        .height(28)
        .borderRadius(14)
        .textAlign(TextAlign.Center)
        .halfLeading(true)
        .linearGradient({
          angle: 360,
          colors: [['#01FCEA', 0.0], ['#01A8FE ', 1.0]]
        })
        .onClick(() => {
          this.saveHandle()
        })
    }.width('100%').justifyContent(FlexAlign.SpaceBetween)
  }
}
