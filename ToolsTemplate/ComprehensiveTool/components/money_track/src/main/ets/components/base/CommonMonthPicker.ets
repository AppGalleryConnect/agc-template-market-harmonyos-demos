import dayjs from 'dayjs';
import { MoneyTrackButton, CustomButtonType } from './CommonButton';

export const MONTH_LIST: string[] = [
  '01月',
  '02月',
  '03月',
  '04月',
  '05月',
  '06月',
  '07月',
  '08月',
  '09月',
  '10月',
  '11月',
  '12月',
];


@ComponentV2
export struct CommonMonthPicker {
  @Param
  initMonth: string = '';
  @Local
  value: [string, string] = ['', ''];
  @Event
  handleConfirm: (dateStr: string) => void;
  @Event
  handleCancel: () => void;

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
  get selectedMonth() {
    const year = this.value[0].split('年')[0];
    const month = this.value[1].split('月')[0];
    return `${year}-${month}`;
  }

  aboutToAppear(): void {
    if (this.initMonth) {
      let temp = this.initMonth.split('-');
      this.value[0] = temp[0] + '年';
      this.value[1] = temp[1] + '月';
    } else {
      const cur = dayjs();
      this.value[0] = cur.format('YYYY年');
      this.value[1] = cur.format('MM月');
    }
  }

  build() {
    Column() {
      TextPicker({ range: this.pickerGroup, value: this.value })
        .onChange((value: string | string[]) => {
          this.value[0] = value[0];
          this.value[1] = value[1];
        })
        .disappearTextStyle({
          font: { size: $r('app.string.font_size_14'), weight: FontWeight.Regular },
        })
        .textStyle({
          color: $r('app.color.font_color_level1'),
          font: { size: $r('app.string.font_size_16'), weight: FontWeight.Regular },
        })
        .selectedTextStyle({
          color: $r('app.color.font_color_level1'),
          font: {
            size: $r('app.string.font_size_20'),
            weight: FontWeight.Medium,
          },
        })
        .canLoop(false)
        .width('100%');
      Blank();
      Flex() {
        MoneyTrackButton({
          title: '取消',
          buttonType: CustomButtonType.SECONDARY,
          handleClick: () => {
            this.handleCancel?.();
          },
        });
        Blank().width(16);
        MoneyTrackButton({
          title: '确定',
          buttonType: CustomButtonType.PRIMARY,
          handleClick: () => {
            this.handleConfirm?.(this.selectedMonth);
          },
        });
      }
      .margin({ bottom: $r('app.string.space_l') })
    }
    .height($r('app.string.height_percent_full'))
    .width($r('app.string.width_percent_full'))
    .padding($r('app.string.space_l'));
  }
}