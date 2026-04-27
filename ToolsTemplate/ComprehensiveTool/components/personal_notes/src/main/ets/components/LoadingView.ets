
@Builder
export function loadingViewBuilder(){
  LoadingView()
}

@ComponentV2
struct LoadingView {

  build() {
    Column() {
      Column({ space: 12 }) {
        LoadingProgress()
          .width(72)
          .height(72)
          .color($r('sys.color.icon_secondary'))
        Text('正在加载')
          .fontColor($r('sys.color.font_secondary'))
          .textAlign(TextAlign.Center)
          .fontSize(16)
      }
      .width(150)
      .aspectRatio(1)
      .justifyContent(FlexAlign.Center)
      .borderRadius(12)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}