@Builder
export function titleBuilder(title: string, width: number = 64) {
  Row() {
    Text(title)
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'))
  }
  .width(width)
  .margin({ right: 12 })
}

@ComponentV2
export struct InputRow {
  @Param title: string = ''
  @Param titleWidth: number = 64
  @Param text: string = ''
  @Param type: string = '元'
  @Param placeholder: string = ''
  @Param func: Function = () => {
  }

  build() {
    Row() {
      titleBuilder(this.title, this.titleWidth)
      TextInput({ text: this.text, placeholder: this.placeholder })
        .layoutWeight(1)
        .backgroundColor('#F1F3F5')
        .borderRadius(8)
        .padding({ left: 12, right: 12 })
        .margin({ right: 12 })
        .type(InputType.NUMBER_DECIMAL)
        .enabled(this.title === '合计本金' ? false : true)
        .onChange((value) => {
          this.func(value)
        })
      Text(this.type)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
    }
    .width('100%')
    .height(40)
    .margin({ bottom: 16 })
  }
}