/**
 * @usage: 音频编辑功能卡片组件,用于音频编辑首页展示各种音频处理功能的入口卡片,
 * 如音频合成、音频调节等。展示功能标题、图标和标签,支持渐变背景和点击跳转。
 * @layout: 采用Column垂直布局,顶部为Row横向排列的标题和图标,底部为功能标签。
 * 整个卡片应用linearGradient渐变背景,圆角设计。
 * @constraints: 必须提供title、iconSrc、tag、angle、colors和turnPage参数。
 * @domain: 音频编辑
 * @zhName: 音频编辑功能卡片
 * @isGen: true
 * @fileType: component
 * @image: 
 */
@Component
export struct AudioEditWidget {
  title: string = ''
  iconSrc: ResourceStr | string = ''
  tag: string = ''
  angle: number = 0
  colors: [ResourceColor, number][] = []
  turnPage: () => void = () => {
  }

  build() {
    Column() {
      Row() {
        Text(this.title).fontSize(16).fontColor(Color.White)
        Image(this.iconSrc).width(29).height(28)
      }.justifyContent(FlexAlign.SpaceBetween).width('100%')

      Row() {
        Text(this.tag)
          .width(54)
          .height(20)
          .borderRadius(4)
          .border({ width: 1, color: Color.White })
          .fontColor(Color.White)
          .fontSize(10)
          .textAlign(TextAlign.Center)
      }.width('100%')
    }
    .onClick(() => {
      this.turnPage()
    })
    .width('100%')
    .height(80)
    .borderRadius(16)
    .padding({
      left: 10,
      top: 6,
      right: 8,
      bottom: 11
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .linearGradient({
      angle: this.angle, // 渐变方向
      colors: this.colors
    })
  }
}