@ComponentV2
export struct CommonEmptyState {
  build() {
    Column() {
      Text('暂无数据')
    }
    .width($r('app.string.width_percent_full'))
  }
}