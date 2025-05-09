import { VideoModel } from '../viewModels/VideoModel'
import { window } from '@kit.ArkUI';


@ComponentV2
export struct VideoPlayer {

  @Param data: VideoModel = new VideoModel()
  @Param index: number = 0
  @Param videoHeight: number = 184
  @Param playIdx: number[] = []
  @Event player: (curIndex: number) => void = (curIndex: number) => {}
  public curRate: PlaybackSpeed = PlaybackSpeed.Speed_Forward_1_00_X
  @Local isPlayer: boolean = false
  @Local isFullScreen: boolean = false

  handlerOrientation(type: number) {
    window.getLastWindow(getContext(this), (err, win) => {
      win.setPreferredOrientation(type)
    })
  }

  build() {
    Stack() {
      Video({
        src: this.data?.videoUrl,
        previewUri: this.data?.previewUri,
        currentProgressRate: this.curRate,
        controller: this.data?.videoController,
      })
        .autoPlay(false)
        .height(this.videoHeight)
        .width('100%')
        .borderRadius(8)
        .controls(this.isPlayer)
        .onFinish(() => {
          if (!this.isFullScreen) {
            this.isPlayer = false
          }
        })
        .onStart(() => {
          this.player && this.player(this.index)
          this.playIdx.push(this.index)
        })
        .onFullscreenChange((event) =>{
          this.isFullScreen = event.fullscreen
          if (event.fullscreen) {
            this.handlerOrientation(window.Orientation.LANDSCAPE)
          } else {
            this.handlerOrientation(window.Orientation.PORTRAIT)
          }
        })
      if (!this.isPlayer) {
        Image($r('app.media.ic_player')).width(48).height(48)
          .onClick(() => {
            this.isPlayer = !this.isPlayer
            if (this.isPlayer) {
              this.playIdx.push(this.index)
              this.data.videoController?.start()
              this.player && this.player(this.index)
            } else {
              this.data.videoController?.pause()
              this.playIdx.splice(this.index, 1)
            }
          })
      }
    }
    .alignContent(Alignment.Center)
  }
}