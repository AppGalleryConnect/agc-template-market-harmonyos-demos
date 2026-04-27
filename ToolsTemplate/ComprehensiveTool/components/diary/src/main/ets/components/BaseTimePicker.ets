import dayjs from 'dayjs';
import { dateTimePickerBuilderParams } from '../commons/Interface';
import { DateUtil } from '../utils/DateUtil';

@Builder
export function baseTimePickerBuilder(param: dateTimePickerBuilderParams) {
  BaseTimePicker({
    date: param.date,
    change: param.change
  })
}


@ComponentV2
export struct BaseTimePicker {
  @Param date: string = '';
  @Event change: (time: TimePickerResult) => void = (time: TimePickerResult) => {}
  @Local selectedTime: Date = new Date(this.date);
  @Local currentTime: string = '';

  aboutToAppear(): void {
    this.currentTime = dayjs(this.selectedTime).format('HH:mm');
  }

  build() {
    Column({ space: 16 }) {
      Text(this.currentTime)
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .lineHeight(27)

      TimePicker({
        selected: this.selectedTime,
      })
        .useMilitaryTime(true)
        .margin({left: 32, right: 32 })
        .onChange((value: TimePickerResult) => {
          if (value.hour >= 0) {
            this.currentTime = DateUtil.dateTimeFormat(value);
            this.change?.(value)
          }
        })
        .disappearTextStyle({ color: Color.Black, font: { size: 15, weight: FontWeight.Regular } })
        .textStyle({ color: Color.Black, font: { size: 16, weight: FontWeight.Regular } })
        .selectedTextStyle({
          color: $r('app.color.diary_primary_color'),
          font: { size: 20, weight: FontWeight.Medium }
        })
    }
    .width('100%')
    .layoutWeight(1)
    .padding({
      left: 12,
      right: 12,
      top: 24,
    })
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_primary'))
  }
}