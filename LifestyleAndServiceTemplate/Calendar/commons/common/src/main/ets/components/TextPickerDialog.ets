import { TextStyleModifier } from '../style/CommonStyle'
import { PickerOperation } from './PickerOperation'


@ComponentV2
export struct TextPickerDialog {
  @Param dayList: string[] = []
  @Local select: number = 1
  @Param selected: number = 1
  @Event cancel: () => void = () => {
  }
  @Event confirm: (value: number) => void = () => {
  }
  @Event datePickerChange: (value: number) => void = () => {
  }

  aboutToAppear(): void {
    this.select = this.selected
  }

  build() {
    Column() {
      PickerOperation({
        cancel: () => {
          this.cancel()
        },
        confirm: () => {
          this.confirm(this.select)
        }
      })

      TextPicker({ range: this.dayList, selected: this.select })
        .onChange((value: string | string[], index: number | number[]) => {
          this.select = index as number
          console.info('Picker item changed, value: ' + value + ', index: ' + index)
        })
        .onScrollStop((value: string | string[], index: number | number[]) => {
          console.info('Picker scroll stopped, value: ' + value + ', index: ' + index)
        })
        .height(240)
    }
    .justifyContent(FlexAlign.End)
    .width('100%')
    .height('100%')
    .transition(TransitionEffect.translate({ y: 500 }))
  }
}