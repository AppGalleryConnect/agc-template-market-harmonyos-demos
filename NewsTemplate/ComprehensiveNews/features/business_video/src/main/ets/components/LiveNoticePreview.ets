
@ComponentV2
export struct LiveNoticePreview {
  @Param swiperData: string[] = [];
  private swiperController: SwiperController = new SwiperController()

  build() {
    Row({ space: 8 }) {
      Image($r('app.media.ic_notice'))
        .width(20)
        .height(15)
        .fillColor($r('sys.color.font_primary'))
      Swiper(this.swiperController) {
        ForEach(this.swiperData, (item: string) => {
          Row() {
            Text(item)
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .lineHeight(20)
              .maxLines(1)
              .textOverflow({overflow: TextOverflow.Ellipsis})
          }
        }, (item: string, index: number) => item + index)
      }
      .vertical(true)
      .indicator(false)
      .loop(true)
      .layoutWeight(1)
      .height(20)
      .autoPlay(true)
      .disableSwipe(true)
    }
    .width('100%')
    .padding(12)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_primary'))
  }
}