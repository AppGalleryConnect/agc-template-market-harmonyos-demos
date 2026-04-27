@ComponentV2
export struct BottomTips {
  @Param exportStatus: string = ''
  @Param tipText: string = ''
  @Param saveResult: boolean = false

  build() {
    Column() {
      if (this.saveResult && this.exportStatus === 'unFinish') {
        Text(this.tipText + '失败')
          .fontColor('#FF4B4B')
          .tipsTextStyle()
      } else if (this.saveResult && this.exportStatus === 'finish') {
        Text(this.tipText + '已成功')
          .fontColor('#FFFFFF')
          .tipsTextStyle()
      } else if (this.saveResult && this.exportStatus === 'cancel') {
        Text(this.tipText + '已取消')
          .fontColor('#FFFFFF')
          .tipsTextStyle()
      }
    }
    .margin({
      bottom: 30
    })
  }
}

@Extend(Text)
function tipsTextStyle() {
  .fontSize(14)
  .fontColor('#FFFFFF')
  .backgroundColor('#202E3E')
  .borderRadius(18)
  .padding({
    top: 9,
    bottom: 8,
    left: 16,
    right: 15
  })
}