
@Extend(Text)
function textStyle() {
  .fontColor(Color.Red)
  .fontSize(18)
  .fontColor($r('sys.color.font_primary'))
  .fontWeight(500)
  .lineHeight(24)
}

@Extend(TextInput)
function textInputStyle() {
  .type(InputType.Password)
  .height(40)
  .maxLength(6)
}

// 输入组件
@ComponentV2
export struct InputField {
  @Param label: string = '';
  @Param value: string = '';
  @Param placeholder: string = '';
  @Event $value: (val: string) => void = (val: string) => {}

  build() {
    Column({ space: 8 }) {
      Text(this.label).textStyle()

      TextInput({ text: this.value, placeholder: this.placeholder })
        .textInputStyle()
        .passwordIcon({
          onIconSrc: $r('app.media.ic_eye_on'),
          offIconSrc: $r('app.media.ic_eye_off')
        })
        .inputFilter('[0-9a-z]', (e) => {})
        .onChange((value: string) => {
          this.$value(value)
        })
    }
    .alignItems(HorizontalAlign.Start)
  }
}