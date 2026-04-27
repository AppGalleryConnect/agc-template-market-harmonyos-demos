@ComponentV2
export struct DeleteHistoryListDialog {
  private readonly logTag: string = 'DeleteHistoryListDialog'
  @Param onDeleted: () => void = () => {}
  @Param onCanceled: () => void = () => {}

  build() {
    Column() {
      Text('是否删除全部历史记录')
        .height(56)
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontSize(20)
        .fontColor('rgba(0, 0, 0, 0.90)')
        .margin({
          top: 16,
          bottom: 16
        })

      Row() {
        Text('取消')
          .fontColor('rgba(0, 0, 0, 0.5)')
          .fontSize(16)
          .borderWidth(1)
          .borderColor('rgba(0, 0, 0, 0.2)')
          .borderRadius(22)
          .height('100%')
          .layoutWeight(1)
          .margin({ right: 8 })
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.onCanceled()
          })

        Text('确定')
          .fontColor('rgba(255, 255, 255, 1)')
          .fontSize(16)
          .borderRadius(22)
          .backgroundColor('rgba(255, 75, 75, 1)')
          .height('100%')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.onDeleted()
          })
      }
      .width('100%')
      .height(40)
      .padding({ left: 16, right: 16 })
      .margin({ bottom: 24 })
    }
    .width('100%')
    .height(152)
  }
}