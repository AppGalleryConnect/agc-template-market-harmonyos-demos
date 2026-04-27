/**
 * @usage: 用于选择行展示场景。提供标题和选择状态图标的横向布局，适用于单选列表项。
 * 关键数据结构：title（标题字符串或资源）、isSelect（是否选中布尔值）。
 * 包含if逻辑：根据isSelect显示不同的选择图标（选中显示蓝色对勾，未选中显示灰色圆圈）。
 * @layout: 横向布局。左侧为标题文字（左对齐），右侧为选择状态图标（20x20）。整体高度48，
 * 两端对齐，垂直居中。
 * @constraints: title标题不能为空
 * @isGen: true
 * @fileType: component
 * @zhName: 选择行类型组件
 */
@ComponentV2
export  struct RowType {
  @Param title: string | Resource = ''
  @Param isSelect: boolean = false

  build() {
    Row() {
      Text(this.title)
        .font({
          size: 14,
          weight: 400
        })
        .fontColor(Color.Black)
        .textAlign(TextAlign.Start)
      Blank()
      Image(this.isSelect ? $r('app.media.code_select') : $r('app.media.not_select'))
        .height(20)
        .width(20)
    }
    .width('100%')
    .height(48)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }
}