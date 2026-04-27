/**
 * @usage: 用于选择器操作栏场景。提供取消和确认按钮的通用操作栏，支持显示当前选择值和位置控制。
 * 关键数据结构：currentDate（当前日期字符串）、isShowTitle（是否显示标题布尔值）、
 * isBottom（是否在底部布尔值）、cancel（取消回调函数）、confirm（确认回调函数）。
 * 包含if逻辑：根据isShowTitle判断是否显示中间的日期标题。
 * @layout: 横向Row布局（SpaceBetween对齐）。左侧为"取消"按钮Row（字号Body_L、加粗、font_primary颜色），
 * 中间为当前日期标题Row（字号20、加粗，可选显示），右侧为"确认"按钮Row（字号Body_L、加粗、红色#FFE94949）。
 * 整体白色背景，宽度100%，左右内边距32vp，上下内边距根据isBottom动态调整（底部24vp，顶部16vp）。
 * @constraints: cancel和confirm回调函数必须正确处理操作逻辑，
 * 内边距根据isBottom参数动态调整（底部时上下24vp，顶部时上下16vp），左右内边距固定32vp
 * @isGen: true
 * @fileType: component
 * @zhName: 基础选择器操作栏组件
 */

@ComponentV2
export struct BasePickerOperation {
  @Param currentDate: string = ''
  @Param isShowTitle: boolean = false
  @Param isBottom: boolean = false
  @Event cancel: () => void = () => {
  }
  @Event confirm: () => void = () => {
  }

  build() {
    Row() {
      Row() {
        Text('取消')
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Bold)
      }
      .onClick(() => {
        this.cancel()
      })

      Row() {
        Text(this.currentDate).fontWeight(FontWeight.Bold)
          .fontSize(20)
      }
      .visibility(this.isShowTitle ? Visibility.Visible : Visibility.None)

      Row() {
        Text('确认')
          .fontColor('#FFE94949')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Bold)
      }
      .onClick(() => {
        this.confirm()
      })
    }
    .width('100%')
    .padding({
      left: 20,
      right: 20,
      top: 10,
      bottom: 10,
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
    .padding({
      left: 32,
      right: 32,
      top: this.isBottom ? 24 : 16,
      bottom: this.isBottom ? 24 : 16,
    })
  }
}