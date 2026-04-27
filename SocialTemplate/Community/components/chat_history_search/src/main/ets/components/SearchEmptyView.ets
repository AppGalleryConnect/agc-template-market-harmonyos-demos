@ComponentV2
export struct SearchEmptyView {
  build() {
    Column() {
      Image($r('app.media.search_empty'))
        .width($r('app.float.vp_120'))
        .height($r('app.float.vp_120'))
        .objectFit(ImageFit.Contain)
      Text($r('app.string.search_empty_text'))
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_tertiary'))
        .lineHeight($r('app.float.vp_14'))
        .margin({
          top: $r('app.float.vp_18')
        })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .layoutWeight(1)
  }
}