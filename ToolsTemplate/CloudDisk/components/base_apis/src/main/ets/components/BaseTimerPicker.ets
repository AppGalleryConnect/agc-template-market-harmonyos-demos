import dayjs from 'dayjs';
import { BasePickerOperation } from './BasePickerOperation';

/**
 * @usage: 用于时间选择场景。提供时间选择器功能，支持小时、分钟、秒的选择，使用24小时制。
 * 关键数据结构：selectedTime（选中时间Date对象）、currentSelectedTime（当前选中时间TimePickerResult对象，
 * 包含hour小时、minute分钟、second秒）、onSelectTimeChange（选择时间变化回调函数，参数为TimePickerResult）、
 * cancel（取消回调函数）、confirm（确认回调函数，参数为TimePickerResult）。
 * 包含if逻辑：在onChange事件中判断hour是否大于等于0来验证时间有效性。
 * @layout: 垂直Column布局。顶部为TimePicker时间选择器（使用24小时制，自定义文字样式：消失状态黑色15号常规字体、
 * 正常状态黑色16号常规字体、选中状态红色#C4272B 20号中等字重），底部为BasePickerOperation操作栏（取消和确认按钮）。
 * 整体宽度100%。
 * @constraints: selectedTime时间值必须有效，currentSelectedTime在aboutToAppear中初始化为selectedTime的时分秒，
 * 使用dayjs库提取时间（hour()、minute()、second()方法），时间选择器使用24小时制不可修改，
 * onChange事件会更新currentSelectedTime并触发onSelectTimeChange回调，确认按钮会将currentSelectedTime传递给confirm回调
 * @isGen: true
 * @fileType: component
 * @zhName: 基础时间选择器组件
 * @component: BasePickerOperation
 */

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