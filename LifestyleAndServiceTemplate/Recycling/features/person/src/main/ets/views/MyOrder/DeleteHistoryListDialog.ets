@ComponentV2
export struct DeleteHistoryListDialog {
  @Param onCanceled: () => void = () => {}
  @Param onDeleted: () => void = () => {}
  private readonly logTag: string = 'DeleteHistoryListDialog'

  build() {
    Column() {
      Text('是否删除全部历史记录')
        .textAlign(TextAlign.Center)
        .fontSize(20)
        .height(56)
        .margin({
          top: 16,
          bottom: 16
        })
        .width('100%')
        .fontColor('rgba(0, 0, 0, 0.90)')

      Row() {
        Text('取消')
          .borderColor('rgba(255, 75, 75, 1)')
          .fontColor('rgba(255, 75, 75, 1)')
          .borderRadius(22)
          .borderWidth(1)
          .height('100%')
          .fontSize(16)
          .textAlign(TextAlign.Center)
          .margin({ right: 8 })
          .layoutWeight(1)
          .onClick(() => {
            this.onCanceled()
          })

        Text('确定')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontColor('rgba(255, 255, 255, 1)')
          .backgroundColor('rgba(255, 75, 75, 1)')
          .borderRadius(22)
          .onClick(() => {
            this.onDeleted()
          })
          .fontSize(16)
          .height('100%')
      }
      .padding({ left: 16, right: 16 })
      .width('100%')
      .margin({ bottom: 24 })
      .height(40)
    }
    .width('100%')
    .height(152)
  }
}