import { BasePickerOperation } from './BasePickerOperation'

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
        })
        .onScrollStop((value: string | string[], index: number | number[]) => {
        })
        .height(240)
    }
    .justifyContent(FlexAlign.End)
    .width('100%')
    .height('100%')
    .transition(TransitionEffect.translate({ y: 500 }))
  }
}