import dayjs from 'dayjs'
import { BasePickerOperation } from './BasePickerOperation'
import { getWeekday } from '../utils/Utils'


@ComponentV2
export struct BaseDatePicker {
  /**
   * 当前传入的日期值
   */
  @Param datePicker: Date = new Date();
  /**
   * 是否显示操作栏
   */
  @Param isOperationShow: boolean = true;
  /**
   * 是否显示操作栏
   */
  @Param isLunarDate: boolean = false;
  /**
   * 是否显示农历
   */
  @Param isLunar: boolean = false;
  /**
   * 操作栏是否在底部
   */
  @Param isBottom: boolean = false;
  /**
   * 是否显示时间标题
   */
  @Param isShowDateTitle: boolean = false;
  /**
   * 当前日期值
   */
  @Local datePickerLocal: Date = new Date();
  /**
   * 关闭回调
   */
  @Event cancel: () => void = () => {
  };
  /**
   * 确认选择回调
   */
  @Event confirm: (datePicker: Date) => void = () => {
  };
  /**
   * 切换选择回调
   */
  @Event onDatePickerChange: (datePicker: Date) => void = () => {
  };
  /**
   * 切换选择回调
   */
  @Event onLunarChange: (value: boolean) => void = () => {
  };

  aboutToAppear(): void {
    this.datePickerLocal = this.datePicker ?? new Date();
  }

  build() {
    Column() {
      BasePickerOperation({
        currentDate: dayjs(this.datePickerLocal).format('YYYY年MM月DD日') + getWeekday(this.datePickerLocal),
        isShowTitle: this.isShowDateTitle,
        cancel: () => {
          this.cancel();
        },
        confirm: () => {
          this.confirm(this.datePickerLocal);
        },
      });
      DatePicker({
        start: new Date('1970-1-1'),
        end: new Date('2050-1-1'),
        selected: this.datePickerLocal,
      })
        .lunar(this.isLunarDate)
        .layoutWeight(1)
        .disappearTextStyle({ color: $r('sys.color.font_tertiary'), font: { size: $r('sys.float.Subtitle_S'), weight: FontWeight.Bold } })
        .textStyle({
          color: $r('sys.color.font_primary'),
          font: { size: $r('sys.float.Subtitle_M'), weight: FontWeight.Regular },
        })
        .selectedTextStyle({
          color: $r('sys.color.font_emphasize'),
          font: { size: $r('sys.float.Title_S'), weight: FontWeight.Medium },
        })
        .onDateChange((value: Date) => {
          this.datePickerLocal = value
          this.onDatePickerChange(value)
        })
        .backgroundColor($r('sys.color.comp_background_primary'))
        .padding({
          top: 20,
          bottom: 20,
        })
    }
    .justifyContent(FlexAlign.End)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .transition(TransitionEffect.translate({ y: 500 }))
  }
}