@ComponentV2
export struct NavHeaderBar {
  windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77

  build() {
    Column() {
      Row() {
        Text('我的')
          .fontColor($r('sys.color.font_primary'))
          .fontSize(24)
          .width('100%')
          .fontWeight(FontWeight.Bold)
      }
      .height(36)
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      bottom: 8,
    })
    .width('100%')
    .margin({top: 10})
    .backgroundColor('#F1F3F5')
  }
}