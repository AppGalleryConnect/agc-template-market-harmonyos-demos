/**
 * @usage: 用于设置行展示场景。提供标题、副标题、开关或箭头的横向布局，适用于设置列表项。
 * 关键数据结构：title（标题字符串或资源）、smallTitle（副标题字符串或资源）、
 * isSwitch（是否显示开关布尔值）、isOpen（开关状态布尔值）、blockSwitchResult（开关切换回调函数，
 * 参数为开关状态）、blockSelectRight（右侧点击回调函数）。
 * 包含if逻辑：根据isSwitch判断显示开关或右箭头图标。
 * @layout: 横向布局。左侧为标题文字（左对齐），中间为副标题文字（蓝色），
 * 右侧为开关或右箭头图标（16x16）。整体高度48，左对齐，垂直居中。
 * @constraints: title标题不能为空，isSwitch为true时blockSwitchResult回调函数必须正确处理开关状态
 * @isGen: true
 * @fileType: component
 * @zhName: 选择行组件
 */
@ComponentV2
export struct SelectRow {
  @Param title: string | Resource = ''
  @Param smallTitle: string | Resource = ''
  @Param isSwitch: boolean = false
  @Param isOpen: boolean = false
  @Event blockSwitchResult: (value: boolean) => void
  @Event blockSelectRight: () => void

  build() {
    Row({ space: 4 }) {
      Text(this.title)
        .font({
          size: 14,
          weight: 400
        })
        .fontColor(Color.Black)
        .textAlign(TextAlign.Start)
      Blank()
      Text(this.smallTitle)
        .font({
          size: 12,
          weight: 400
        })
        .fontColor('#2FAFFF')
        .textAlign(TextAlign.Start)
      if (this.isSwitch) {
        Toggle({
          type: ToggleType.Switch,
          isOn: this.isOpen
        })
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .onChange((value: boolean) => {
            if (this.blockSwitchResult) {
              this.blockSwitchResult(value)
            }
          })
      } else {
        Image($r('app.media.go_right'))
          .width(16)
          .height(16)
      }
    }
    .width('100%')
    .height(48)
    .justifyContent(FlexAlign.Start)
  }
}