import { BaseTextStyleModifier } from 'base_apis'

/**
 * @usage: 用于VIP页面导航标题场景。提供带返回功能的导航标题栏。
 * 关键数据结构：title（标题字符串或资源）、routerModule（导航路由栈NavPathStack）、
 * bg（背景颜色或资源）。
 * @layout: 横向布局。包含标题文字（左对齐），点击整行返回上一页。高度102，包含顶部安全区域。
 * @constraints: title标题不能为空，routerModule导航路由栈必须正确初始化，bg背景色可选
 * @isGen: true
 * @fileType: component
 * @zhName: VIP导航标题组件
 */
@ComponentV2
export struct VipNavTitle {
  @Param title: ResourceStr = ''
  @Param routerModule: NavPathStack = new NavPathStack()
  @Param bg: ResourceStr | Color = ''

  build() {
    Row({ space: 8 }) {
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
          .fontWeight(FontWeight.Normal)
      }
      .width(40)
      .height(40)
      .type(ButtonType.Circle)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.routerModule.pop()
      })

      Text(this.title)
        .attributeModifier(new BaseTextStyleModifier(`font_primary/Title_S/Bold`))
        .padding({ left: 8 })
    }
    .height(100)
    .width('100%')
    .backgroundColor(this.bg)
    .padding({ top: 40, left: 16, right: 16 })
  }
}