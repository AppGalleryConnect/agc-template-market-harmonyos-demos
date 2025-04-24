@ComponentV2
export struct SwiperComponent {
  private swiperController: SwiperController = new SwiperController()

  build() {
    Swiper(this.swiperController) {
      Image($r('app.media.swiperImage'))
        .objectFit(ImageFit.Contain)
      Image($r('app.media.swiperImage'))
        .objectFit(ImageFit.Contain)
      Image($r('app.media.swiperImage'))
        .objectFit(ImageFit.Contain)
    }
    .borderRadius(20)
    .autoPlay(true)
  }
}