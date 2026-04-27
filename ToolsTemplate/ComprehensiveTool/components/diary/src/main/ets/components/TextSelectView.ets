import { TEXT_PICKER_LABEL } from '../commons/Enum'

@ComponentV2
export struct TextSelectView {
  @Param value: ResourceStr = ''
  @Param icon: string = ''
  @Param type: string = ''
  @Param showFlag?: boolean = false;
  @Param paddingLeft: number = 16
  @Param paddingTop: number = 8
  @Event clickAction: () => void = () => {}

  @Computed
  get textLabel() {
    if (this.value) {
      return this.value;
    }
    if (this.showFlag) {
      return '无'
    }
    return TEXT_PICKER_LABEL[this.type];
  }

  build() {
    Row({ space: 8 }) {
      if (!this.value) {
        SymbolGlyph($r(this.icon))
          .fontColor([$r('sys.color.font_primary')])
          .fontSize(24)
      }

      if (this.value && this.type === 'weather') {
        this.weatherView()
      }

      if (this.value && this.type === 'mood') {
        Image($r(this.icon))
          .width(24)
          .draggable(false)
      }

      Text(this.textLabel)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Regular)
    }
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .padding({
      left: this.paddingLeft,
      right: this.paddingLeft,
      top: this.paddingTop,
      bottom: this.paddingTop
    })
    .borderRadius(50)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.clickAction?.()
    })
  }

  @Builder
  weatherView() {
    Row() {
      SymbolGlyph($r(this.icon))
        .fontColor([$r('sys.color.white')])
        .fontSize(12)
    }
    .width(24)
    .height(24)
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .linearGradient({
      direction: GradientDirection.Top,
      colors: [['#E63C60', 0.0], ['#FFC2CF', 1]]
    })
  }
}