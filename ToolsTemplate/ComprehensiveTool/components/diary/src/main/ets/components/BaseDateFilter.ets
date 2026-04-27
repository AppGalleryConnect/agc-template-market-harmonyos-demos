import dayjs from 'dayjs';
import { dateTimePickerBuilderParams } from '../commons/Interface';

export const MONTH_LIST: string[] = [
  '01月', '02月', '03月', '04月', '05月', '06月',
  '07月', '08月', '09月', '10月', '11月', '12月',
];

@Builder
export function diaryDateFilterBuilder(param: dateTimePickerBuilderParams) {
  BaseDateFilter({
    date: param.date,
    change: param.change
  })
}

@ComponentV2
export struct BaseDateFilter {
  @Param date: string = '';
  @Event change: (dateStr: string) => void = (dateStr: string) => {}
  @Local value: [string, string] = ['', ''];
  @Local selectedDate: Date = new Date(this.date);
  @Local isSelectAll: boolean = true;
  @Local isSelectMonth: boolean = false;

  @Computed
  get pickerGroup() {
    const curYear = new Date().getFullYear();
    const yearList: string[] = [];
    for (let i = 0; i <= curYear - 1970; i++) {
      yearList.push(`${1970 + i}年`);
    }
    return [yearList, MONTH_LIST];
  }

  @Computed
  get selectedDateStr() {
    const year = this.value[0].split('年')[0];
    const month = this.value[1].split('月')[0];
    return `${year}-${month}`;
  }

  aboutToAppear(): void {
    if (this.date) {
      let temp = this.date.split('-');
      this.value[0] = temp[0] + '年';
      this.value[1] = temp[1] + '月';
      this.isSelectAll = false;
      this.isSelectMonth = true;
    } else {
      const cur = dayjs();
      this.value[0] = cur.format('YYYY年');
      this.value[1] = cur.format('MM月');
      this.isSelectAll = true;
      this.isSelectMonth = false;
    }
  }

  build() {
    Column({ space: 16 }) {
      RadioView({
        label: '全部（按时间排序）',
        radioValue: 'all',
        isChecked: this.isSelectAll,
        onChange: (isChecked: boolean) => {
          this.isSelectAll = isChecked;
          if (this.isSelectAll) {
            this.change?.('')
          }
        }
      })

      RadioView({
        label: '月份选择',
        radioValue: 'month',
        isChecked: this.isSelectMonth,
        onChange: (isChecked: boolean) => {
          this.isSelectMonth = isChecked;
          if (this.isSelectMonth) {
            this.change?.(this.selectedDateStr)
          }
        }
      })

      this.monthPicker()
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


  @Builder
  monthPicker() {
    TextPicker({ range: this.pickerGroup, value: this.value })
      .onChange((value: string | string[]) => {
        this.value[0] = value[0];
        this.value[1] = value[1];

        if (this.isSelectMonth) {
          const year = this.value[0].split('年')[0];
          const month = this.value[1].split('月')[0];
          this.change?.(`${year}-${month}`)
        }
      })
      .disappearTextStyle({
        font: { size: 14, weight: FontWeight.Regular },
      })
      .textStyle({
        color: $r('sys.color.font_primary'),
        font: { size: 16, weight: FontWeight.Regular },
      })
      .selectedTextStyle({
        color: $r('app.color.diary_primary_color'),
        font: {
          size: 20,
          weight: FontWeight.Medium,
        },
      })
      .canLoop(false)
      .width('100%')
      .enabled(this.isSelectMonth)
      .opacity(1)
  }
}


@ComponentV2
struct RadioView {
  @Param label: string = ''
  @Param radioValue: string = ''
  @Param isChecked: boolean = true;
  @Event onChange: (isChecked: boolean) => void = (isChecked: boolean) => {}

  build() {
    Row() {
      Text(this.label)
        .fontSize(16)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(500)
        .lineHeight(21)

      Radio({ value: this.radioValue, group: 'radioGroup', indicatorType:RadioIndicatorType.TICK })
        .checked(this.isChecked)
        .height(20)
        .width(20)
        .onChange((isChecked: boolean) => {
          this.onChange?.(isChecked)
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)

  }
}