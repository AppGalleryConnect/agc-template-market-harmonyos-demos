

/**
 * @usage: 外层卡片容器组件，用于包裹内容并提供统一的卡片样式。主要数据结构包括BuilderParam（内容构建器），
 * 用于接收自定义内容。包含条件渲染逻辑判断content是否存在。
 * @layout: 垂直布局（Column），内部通过BuilderParam渲染传入的自定义内容。容器设置固定的内边距、背景色和圆角。
 * @constraints:
 * @domain: 健康医疗
 * @zhName: 外层卡片容器组件
 * @isGen: true
 * @fileType: component
 * @image:
 */
@ComponentV2
export struct OuterFrameCard {
  @BuilderParam content: () => void

  build() {
    Column() {
      if (this.content) {
        this.content()
      }
    }
    .size({ width: '100%' })
    .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_12') })
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }
}