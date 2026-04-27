/**
 * @usage: 外层卡片容器组件,用于个人中心页面包裹功能列表,提供统一的圆角和内边距样式。
 * 为内容提供统一的卡片样式包装,通过@BuilderParam接收自定义内容。
 * @layout: 采用Column垂直布局,内部渲染传入的content内容。应用圆角和左右内边距。
 * @constraints: 必须提供content参数(通过@BuilderParam传入)。
 * @domain: 音频编辑
 * @zhName: 外层卡片容器
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
    .padding({ left: 12, right: 12 })
    .borderRadius(16)
  }
}