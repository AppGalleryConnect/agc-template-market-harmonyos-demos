@ComponentV2
export struct WorkDetailHeader {
  @Param title: string = ''
  @Param onBackClick: () => void = () => {}
  @Param onInfoClick: () => void = () => {}

  build() {
    Row() {
      // 返回按钮
      Column(){
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .width(40)
      .height(40)
      .borderRadius(20)
      .backgroundColor('#161929')
      .onClick(() => {
        this.onBackClick()
      })
      
      // 标题（居中，支持长文本省略）
      Text(this.title)
        .fontSize(18)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .margin({ left: 12, right: 12 })
      
      // 信息按钮
      Image($r('app.media.icon_info'))
        .width(24)
        .height(24)
        .fillColor(Color.White)
        .onClick(() => {
          this.onInfoClick()
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }
}