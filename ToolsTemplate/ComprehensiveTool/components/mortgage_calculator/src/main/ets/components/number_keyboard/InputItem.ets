@Extend(Button)
function inputButton(backgroundColor: ResourceColor, fontColor: ResourceColor) {
  .type(ButtonType.Normal)
  .fontSize(16)
  .width('100%')
  .height('100%')
  .backgroundColor(backgroundColor)
  .fontColor(fontColor)
  .borderRadius(8)
}

type ButtonType = 'primary' | 'default';

@ComponentV2
export struct InputItem {
  @Param value: string = ''
  @Param type: ButtonType = 'default'

  getFontColor() {
    return this.type === 'primary' ? '#fff' : '#343434'
  }

  getBackgroundColor() {
    return this.type === 'primary' ? '#2f72f5' : '#fff'
  }

  build() {
    if (this.value === 'Del') {
      Button() {
        Image($r('app.media.del')).width(20)
      }
      .inputButton(this.getBackgroundColor(), this.getFontColor())
    } else {
      Button(this.value)
        .inputButton(this.getBackgroundColor(), this.getFontColor())
    }

  }
}