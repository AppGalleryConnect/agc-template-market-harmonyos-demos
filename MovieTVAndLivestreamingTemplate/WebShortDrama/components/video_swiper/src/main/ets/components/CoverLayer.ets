import { AVPlayerState } from '../constant/AVPlayerState'
import { AvPlayer } from '../controller/AvPlayer'

@ComponentV2
export struct CoverLayer {
  @Param @Require avPlayer: AvPlayer
  @Param @Require curIndex: number
  @Param @Require index: number
  @Param @Require previewUri: ResourceStr
  @Param @Require xComponentWidth: number | string
  @Param @Require xComponentHeight: number | string

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.curIndex === this.index && this.avPlayer.state === AVPlayerState.PAUSED) {
        Image($r('app.media.ic_paused'))
          .width(60)
          .height(60)
          .zIndex(2)
      }
      if (this.curIndex === this.index && this.avPlayer.isBufferUpdate) {
        Column() {
          LoadingProgress()
            .size({ width:40, height:40 })
            .color(Color.White);
          Text('加载中...')
            .fontSize(14)
            .fontColor(Color.White);
        }
        .zIndex(3);
      }
      // if (!this.avPlayer.isReady) {
      //   Image(this.previewUri)
      //     .zIndex(2)
      //     .width(this.xComponentWidth)
      //     .height(this.xComponentHeight)
      //     .transition(TransitionEffect.OPACITY)
      // }
    }
    .width('100%')
    .height('100%')
    .zIndex(2)
  }
}