/**
 * @usage: 用于页面顶部导航栏场景。提供返回按钮和标题展示。
 * 关键数据结构：title（标题字符串或资源）、onClickBack（返回按钮点击回调函数）。
 * @layout: 横向布局。左侧为返回按钮（圆形背景40x40，内含返回图标24x24），右侧为标题文字（左对齐）。
 * @constraints: title标题不能为空，onClickBack回调函数必须正确处理返回操作
 * @isGen: true
 * @fileType: component
 * @zhName: 顶部导航栏组件
 */
@ComponentV2
export struct TopBar {
  @Param title: string | Resource = '';
  @Param onClickBack: () => void = () => {
  }

  build() {
    Row() {
      Row() {
        Image($r('app.media.chevron_backward'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.onClickBack()
          })
      }
      .width(40)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .padding(8)
      .borderRadius(40)

      Text(this.title)
        .fontSize(20)
        .fontWeight(700)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: 8 })
    }
  }
}
 