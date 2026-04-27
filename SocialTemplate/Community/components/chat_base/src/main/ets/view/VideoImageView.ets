@ComponentV2
export struct VideoImageView {
  @Param @Require videpImage: string
  @Param viewSize: Resource | undefined = undefined

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Image(this.videpImage)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .draggable(false)
      }
      .width('100%')
      .height('100%')

      Column() {
        Image($r('app.media.video_stop'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .draggable(false)
      }
      .width($r('app.float.video_stop_width_22vp'))
      .height($r('app.float.video_stop_height_22vp'))
      .borderRadius($r('app.float.video_stop_borderRadius_360'))
    }
    .width(this.viewSize ?? '100%')
    .height(this.viewSize ?? '100%')
  }
}