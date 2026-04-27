import dayjs from 'dayjs'
import { BasePickerOperation } from './BasePickerOperation'
import { getWeekday } from '../utils/Utils'

/**
 * @usage: 用于日期选择场景。提供日期选择器功能，支持公历和农历切换、操作栏显示控制、日期范围限制等。
 * 关键数据结构：datePicker（当前传入的日期Date对象）、datePickerLocal（当前日期值Date对象）、
 * isOperationShow（是否显示操作栏布尔值）、isLunarDate（是否显示农历布尔值）、isLunar（是否显示农历开关布尔值）、
 * isBottom（操作栏是否在底部布尔值）、isShowDateTitle（是否显示时间标题布尔值）、
 * cancel（关闭回调函数）、confirm（确认选择回调函数，参数为Date）、onDatePickerChange（切换选择回调函数，参数为Date）、
 * onLunarChange（切换农历回调函数，参数为布尔值）。包含if逻辑：根据isOperationShow和isBottom判断操作栏显示位置，
 * 根据isLunar判断是否显示农历切换开关。
 * @layout: 垂直布局。顶部可选显示日期标题（格式：YYYY年MM月DD日+星期，字号20加粗），
 * 第二行为BasePickerOperation操作栏（取消和确认按钮，可选显示在顶部或底部），
 * 中间为DatePicker日期选择器（起始日期1970-1-1，结束日期2100-1-1，支持农历显示，自定义文字样式），
 * 底部可选显示农历切换开关（Checkbox 16x16，文字"显示农历"）。整体白色背景，带过渡动画（向下平移500）。
 * @constraints: datePicker日期值必须有效，日期范围限制在1970-2100年不可修改，
 * datePickerLocal在aboutToAppear中初始化为datePicker或当前日期，
 * 日期格式化使用dayjs库（格式：YYYY年MM月DD日），星期计算使用getWeekday工具函数
 * @isGen: true
 * @fileType: component
 * @zhName: 基础日期选择器组件
 * @component: BasePickerOperation
 */

@ComponentV2
export struct BaseDatePicker {
  /**
   * 当前传入的日期值
   */
  @Param datePicker: Date = new Date()
  /**
   * 是否显示操作栏
   */
  @Param isOperationShow: boolean = true
  /**
   * 是否显示操作栏
   */
  @Param isLunarDate: boolean = false
  /**
   * 是否显示农历
   */
  @Param isLunar: boolean = false
  /**
   * 操作栏是否在底部
   */
  @Param isBottom: boolean = false
  /**
   * 是否显示时间标题
   */
  @Param isShowDateTitle: boolean = false
  /**
   * 当前日期值
   */
  @Local datePickerLocal: Date = new Date()
  /**
   * 关闭回调
   */
  @Event cancel: () => void = () => {}
  /**
   * 确认选择回调
   */
  @Event confirm: (datePicker: Date) => void = () => {}
  /**
   * 切换选择回调
   */
  @Event onDatePickerChange: (datePicker: Date) => void = () => {}
  /**
   * 切换选择回调
   */
  @Event onLunarChange: (value: boolean) => void = () => {}

  aboutToAppear(): void {
    this.datePickerLocal = this.datePicker ?? new Date()
  }

  build() {
    Column() {
      Row(){
        Text(dayjs(this.datePickerLocal).format('YYYY年MM月DD日') + getWeekday(this.datePickerLocal)).fontWeight(FontWeight.Bold)
          .fontSize(20)
      }
      .margin({top:16,bottom:16})
      .visibility(this.isOperationShow && this.isBottom ? Visibility.Visible : Visibility.None)
      BasePickerOperation({
        currentDate: dayjs(this.datePickerLocal).format('YYYY年MM月DD日') + getWeekday(this.datePickerLocal),
        isShowTitle: this.isShowDateTitle,
        cancel: () => {
          this.cancel()
        },
        confirm: () => {
          this.confirm(this.datePickerLocal)
        },
      })
        .visibility(this.isOperationShow && !this.isBottom ? Visibility.Visible : Visibility.None)
      DatePicker({
        start: new Date('1970-1-1'),
        end: new Date('2100-1-1'),
        selected: this.datePickerLocal,
      })
        .lunar(this.isLunarDate)
        .disappearTextStyle({ color: $r('sys.color.font_primary'), font: { size: $r('sys.float.Subtitle_S'), weight: FontWeight.Bold } })
        .textStyle({ color: $r('sys.color.font_primary'), font: { size: $r('sys.float.Subtitle_M'), weight: FontWeight.Normal } })
        .selectedTextStyle({
          color: $r('sys.color.font_emphasize'),
          font: { size: $r('sys.float.Title_S'), weight: FontWeight.Medium },
        })
        .onDateChange((value: Date) => {
          this.datePickerLocal = value
          this.onDatePickerChange(value)
        })
        .backgroundColor(Color.White)
        .padding({
          top: 20,
          bottom: 20,
        })
      Row() {
        Toggle({ type: ToggleType.Checkbox, isOn: this.isLunarDate })
          .size({ width: 16, height: 16 })
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .onChange((isOn: boolean) => {
            this.onLunarChange(isOn)
          })
        Text('显示农历')
      }
      .padding({ left: 24 })
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .visibility(this.isLunar ? Visibility.Visible : Visibility.None)
      BasePickerOperation({
        currentDate: dayjs(this.datePickerLocal).format('YYYY年MM月DD日') + getWeekday(this.datePickerLocal),
        isShowTitle: false,
        isBottom:true,
        cancel: () => {
          this.cancel()
        },
        confirm: () => {
          this.confirm(this.datePickerLocal)
        },
      })
        .visibility(this.isOperationShow && this.isBottom ? Visibility.Visible : Visibility.None)
    }
    .justifyContent(FlexAlign.End)
    .transition(TransitionEffect.translate({ y: 500 }))
  }
}