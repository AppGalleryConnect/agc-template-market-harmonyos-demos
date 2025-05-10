import { TextStyleModifier } from '../style/CommonStyle'
import { PickerOperation } from './PickerOperation'


@ComponentV2
export struct DatePickerDialog {
  @Param datePicker: Date = new Date()
  @Local datePickerLocal: Date = new Date()
  @Event cancel: () => void = () => {
  }
  @Event confirm: (datePicker: Date) => void = () => {
  }
  @Event datePickerChange: (datePicker: Date) => void = () => {
  }

  aboutToAppear(): void {
    this.datePickerLocal = this.datePicker ?? new Date()
  }

  build() {
    Column() {
      PickerOperation({
        cancel: () => {
          this.cancel()
        },
        confirm: () => {
          this.confirm(this.datePickerLocal)
        }
      })
      DatePicker({
        start: new Date('1970-1-1'),
        end: new Date('2100-1-1'),
        selected: this.datePickerLocal,
      })
        .disappearTextStyle({ color: Color.Gray, font: { size: $r('sys.float.Body_M'), weight: FontWeight.Bold } })
        .textStyle({ color: '#ff182431', font: { size: $r('sys.float.Body_M'), weight: FontWeight.Normal } })
        .selectedTextStyle({
          color: $r('app.color.font_color_black'),
          font: { size: $r('sys.float.Body_L'), weight: FontWeight.Regular },
        })
        .onDateChange((value: Date) => {
          this.datePickerLocal = value
          console.info('select current date is: ' + value.toString())
        })
        .backgroundColor(Color.White)
        .padding({
          top: 20,
          bottom: 20,
        })
    }
    .justifyContent(FlexAlign.End)
    .width('100%')
    .height('100%')
    .transition(TransitionEffect.translate({ y: 500 }))
  }
}