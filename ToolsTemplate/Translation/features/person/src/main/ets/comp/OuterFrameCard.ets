/**
 * @usage: 外框卡片组件，提供统一的卡片容器样式。用于包裹列表或其他内容。
 * 主要数据结构包括content（内容构建器）。
 * @layout: 组件采用Column垂直布局，通过BuilderParam接收子内容。白色背景圆角卡片样式。
 * @constraints: 无
 * @isGen: true
 * @domain: 翻译工具
 * @zhName: 外框卡片组件
 * @fileType: component
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
    .padding({ left: 12, right: 12 })
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
  }
}