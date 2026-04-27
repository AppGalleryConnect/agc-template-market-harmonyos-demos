import dayjs from 'dayjs';
import { WEEK_MAP } from '../commons/Constant';
import { dateTimePickerBuilderParams } from '../commons/Interface';

@Builder
export function baseDatePickerBuilder(param: dateTimePickerBuilderParams) {
  BaseDatePicker({
    date: param.date,
    change: param.change
  })
}


@ComponentV2
export struct BaseDatePicker {
  @Param date: string = '';
  @Event change: (dateStr: string) => void = (dateStr: string) => {}
  @Local selectedDate: Date = new Date(this.date);

  @Computed
  get dateText() {
    let date = dayjs(this.selectedDate).format('YYYY年MM月DD日');
    let day = dayjs(this.selectedDate).day();
    return date + ' ' + WEEK_MAP[day];
  }

  build() {
    Column({ space: 16 }) {

      Text(this.dateText)
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .lineHeight(27)

      DatePicker({
        start: new Date('1970-1-1'),
        end: new Date(dayjs().format('YYYY-MM-DD')),
        selected: this.selectedDate,
      })
        .margin({left: 32, right: 32 })
        .disappearTextStyle({
          font: { size: $r('sys.float.Subtitle_S'), weight: FontWeight.Regular },
        })
        .textStyle({
          color: $r('sys.color.font_primary'),
          font: { size: $r('sys.float.Subtitle_M'), weight: FontWeight.Regular },
        })
        .selectedTextStyle({
          color: $r('app.color.diary_primary_color'),
          font: { size: $r('sys.float.Title_S'), weight: FontWeight.Medium }
        })
        .onDateChange((value: Date) => {
          this.selectedDate = value;
          let dateStr = dayjs(this.selectedDate).format('YYYY-MM-DD');
          this.change?.(dateStr)
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