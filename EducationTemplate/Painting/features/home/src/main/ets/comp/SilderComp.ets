import { Constants } from 'common'

@ComponentV2
export struct SliderComponent {
  @Param sliderName: ResourceStr = ''
  @Param sliderValue: number = 1
  @Param sliderMax: number = 20
  @Param sliderMin: number = 0.1
  @Param sliderStep: number = 1
  @Event sliderChange: (value: number) => void = (value: number) => {
  }

  build() {
    Column() {
      Text(this.sliderName)
        .fontSize(16)
        .width(Constants.FULL_SIZE)
        .textAlign(TextAlign.Start)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.mask_black'))
        .margin({ top: 12, bottom: 18 })
      Slider({
        value: this.sliderValue,
        min: this.sliderMin,
        max: this.sliderMax,
        step: this.sliderStep,
        style: SliderStyle.InSet
      })
        .selectedColor($r('sys.color.comp_background_emphasize'))
        .height(20)
        .trackBorderRadius($r('sys.float.corner_radius_level6'))
        .onChange((value) => {
          this.sliderChange(value)
        })
    }
    .width(Constants.FULL_SIZE)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
  }
}