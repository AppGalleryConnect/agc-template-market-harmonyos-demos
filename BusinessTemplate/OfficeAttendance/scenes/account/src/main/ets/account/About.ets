@Builder
export function aboutBuilder() {
  About();
}

@ComponentV2
struct About {
  build() {
    NavDestination() {
      Column() {
        Column() {
          Image($r('app.media.startIcon')).borderRadius(16).height(72).width(72).margin({ top: 72 })
          Text($r('app.string.office_attendance'))
            .height(22)
            .margin({ top: 8 })
            .fontColor($r('app.string.black_90'))
            .fontWeight(FontWeight.Medium)
            .fontSize(16)
        }.alignItems(HorizontalAlign.Center)

        Column() {
          Text($r('app.string.ICP')).fontColor('#3093FA').fontSize(12).fontWeight(FontWeight.Medium).height(16)
          Text($r('app.string.customer_service_telephone')).fontColor($r('app.string.black_60')).fontSize(12).height(16)
          Text($r('app.string.copy_right')).fontColor($r('app.string.black_60')).fontSize(12).height(16)
        }.alignItems(HorizontalAlign.Center).margin({ bottom: 8 })
      }.justifyContent(FlexAlign.SpaceBetween).alignItems(HorizontalAlign.Center).height('100%')
    }.title({ builder: this.titleBuilder(), height: 56 })
    .padding({ top: 36, bottom: 28 }).backgroundColor($r('app.color.about_background'))
  }

  @Builder
  titleBuilder() {
    Row() {
      Text($r('app.string.about'))
        .fontWeight(FontWeight.Bold)
        .fontColor('rgba(0,0,0,0.90)')
        .fontSize(24)
        .margin({ left: 16, top: 36 })
        .height(56)
    }
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
    .alignItems(VerticalAlign.Bottom)
  }
}