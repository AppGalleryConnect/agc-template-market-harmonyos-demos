@Builder
export function AttractionDetailBuilder() {
  AttractionDetail();
}

@ComponentV2
export struct AttractionDetail {
  build() {
    NavDestination() {
      Column() {
        Text('景区详情示例页面')
      }
    }.title('景区详情示例页面')
  }
}