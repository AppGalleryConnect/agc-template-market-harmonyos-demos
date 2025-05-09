@Component
export struct CommonBlank {
  build() {
    Column() {
      Text('空空如也~').fontSize(12).margin({ top: 16, bottom: 16 })
    }.width('100%').alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
  }
}