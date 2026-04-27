/**
 * @usage: 用于个人中心各页面的顶部导航栏。组件包含关键数据结构：title（标题文本）、
 * onClickBack（返回按钮回调函数）。提供统一的页面头部导航体验，包含返回按钮和页面标题。
 * @layout: 组件采用Row横向布局。左侧为返回按钮（圆形背景，内含向左箭头图标），右侧为标题文本。
 * 返回按钮左对齐，标题文本紧跟在返回按钮右侧。
 * @constraints:
 * @fileType: component
 * @isGen: true
 * @component:
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
 