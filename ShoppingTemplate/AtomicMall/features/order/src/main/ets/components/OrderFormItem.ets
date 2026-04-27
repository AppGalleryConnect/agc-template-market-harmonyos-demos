@ComponentV2
export struct OrderFormItem {
  @BuilderParam
  customContent: () => void = this.buildDefault
  @Param
  label: string = ''
  @Param
  labelColor: ResourceColor = $r('app.color.font_color_level2')
  @Param
  content: string = ''

  build() {
    Row() {
      Text(this.label)
        .fontSize($r('app.float.font_size_12'))
        .fontColor(this.labelColor)
        .constraintSize({ minWidth: 72 })
      Row() {
        this.customContent()
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)
    }
    .width($r('app.string.size_percent_full'))
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  buildDefault() {
    Text(this.content)
      .fontColor($r('app.color.font_color_level1'))
      .fontSize($r('app.float.font_size_12'))
  }
}
