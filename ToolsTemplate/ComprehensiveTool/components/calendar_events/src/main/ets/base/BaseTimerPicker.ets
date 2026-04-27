import dayjs from 'dayjs';
import { BasePickerOperation } from './BasePickerOperation';

@ComponentV2
export struct BaseTimerPicker {
  @Param selectedTime: Date = new Date();
  @Local currentSelectedTime: TimePickerResult | null = null;
  @Event onSelectTimeChange: (value: TimePickerResult) => void = () => {}
  @Event cancel: () => void = () => {}
  @Event confirm: (time: TimePickerResult) => void = () => {}

  aboutToAppear(): void {
    this.currentSelectedTime = {
      hour: dayjs(this.selectedTime).hour(),
      minute: dayjs(this.selectedTime).minute(),
      second: dayjs(this.selectedTime).second(),
    }
  }

  build() {
    Column() {
      TimePicker({
        selected: this.selectedTime,
      })
        .useMilitaryTime(true)
        .onChange((value: TimePickerResult) => {
          if (value.hour >= 0) {
            this.currentSelectedTime = value
            console.info('select current date is: ' + JSON.stringify(value));
          }
        })
        .disappearTextStyle({ color: Color.Black, font: { size: 15, weight: FontWeight.Regular } })
        .textStyle({ color: Color.Black, font: { size: 16, weight: FontWeight.Regular } })
        .selectedTextStyle({ color: '#C4272B', font: { size: 20, weight: FontWeight.Medium } })
      BasePickerOperation({
        cancel: () => {
          this.cancel()
        },
        confirm: () => {
          this.confirm(this.currentSelectedTime as TimePickerResult)
        },
      })
    }.width('100%')
  }
}