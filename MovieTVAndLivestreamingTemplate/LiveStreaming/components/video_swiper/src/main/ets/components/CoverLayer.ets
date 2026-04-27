@ComponentV2
export struct CoverLayer {

  @Param @Require isPlaying: boolean
  @Param @Require preparedFlag: boolean
  @Param @Require curIndex: number
  @Param @Require index: number
  @Param @Require isLoading: boolean
  @Param @Require previewUri: ResourceStr
  @Param @Require xComponentWidth: number | string
  @Param @Require xComponentHeight: number | string

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.curIndex === this.index && !this.isPlaying && this.preparedFlag && !this.isLoading) {
        Image($r('app.media.ic_paused'))
          .width(60)
          .height(60)
          .zIndex(2)
      }
      if (this.curIndex === this.index && !this.preparedFlag) {
        Column() {
          LoadingProgress()
            .size({ width:40, height:40 })
            .color($r('sys.color.icon_on_primary'));
          Text('加载中...')
            .fontSize(14)
            .fontColor(Color.White);
        }
        .zIndex(3);
      }
      if (!this.isPlaying && this.isLoading) {
        Image(this.previewUri)
          .zIndex(2)
          .width(this.xComponentWidth)
          .height(this.xComponentHeight)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(2)
  }
}