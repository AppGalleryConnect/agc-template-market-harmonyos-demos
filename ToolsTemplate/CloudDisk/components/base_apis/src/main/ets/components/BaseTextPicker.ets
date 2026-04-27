import { BasePickerOperation } from './BasePickerOperation'

/**
 * @usage: 用于文本选择场景。提供文本列表选择器功能，支持从字符串数组中选择一项。
 * 关键数据结构：textList（当前传入的绑定列表字符串数组，必需参数）、select（当前选择值索引number）、
 * selected（传入默认选择值索引number）、cancel（取消回调函数）、confirm（确认回调函数，参数为选中索引number）、
 * textPickerChange（切换回调函数，参数为选中索引number）。
 * 包含if逻辑：在aboutToAppear中将selected赋值给select作为初始选中项。
 * @layout: 垂直Column布局（底部对齐）。顶部为BasePickerOperation操作栏（取消和确认按钮），
 * 下方为TextPicker文本选择器（高度240vp，绑定textList数组，初始选中select索引）。
 * 整体宽高100%，带过渡动画（向下平移500）。
 * @constraints: textList文本列表不能为空且必须为字符串数组，select和selected必须为有效索引（0到textList.length-1），
 * onChange事件会更新select值并触发textPickerChange回调，onScrollStop事件会在滚动停止时触发，
 * 确认按钮会将当前select值传递给confirm回调
 * @isGen: true
 * @fileType: component
 * @zhName: 基础文本选择器组件
 * @component: BasePickerOperation
 */

@ComponentV2
export struct BaseTextPicker {
  /**
   * 当前传入的绑定列表
   */
  @Require @Param textList: string[] = []
  /**
   * 当前选择值
   */
  @Local select: number = 1
  /**
   * 传入默认选择值
   */
  @Param selected: number = 1
  /**
   * 取消回调
   */
  @Event cancel: () => void = () => {}
  /**
   * 确认回调
   */
  @Event confirm: (value: number) => void = () => {}
  /**
   * 切换回调
   */
  @Event textPickerChange: (value: number) => void = () => {}

  aboutToAppear(): void {
    this.select = this.selected
  }

  build() {
    Column() {
      BasePickerOperation({
        cancel: () => {
          this.cancel()
        },
        confirm: () => {
          this.confirm(this.select)
        }
      })

      TextPicker({ range: this.textList, selected: this.select })
        .onChange((value: string | string[], index: number | number[]) => {
          this.select = index as number
          this.textPickerChange(this.select)
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