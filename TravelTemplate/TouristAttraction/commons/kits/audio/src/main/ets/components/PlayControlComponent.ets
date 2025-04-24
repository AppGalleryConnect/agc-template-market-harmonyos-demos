import { MediaService } from '../viewmodel/MediaService';

@ComponentV2
export struct PlayControlComponent {
  @Local mediaService: MediaService | undefined = undefined;
  @Param @Require isPlay: boolean;
  @Param @Require isGuide: boolean;
  @Param @Require url: string;

  build() {
    Image(this.isPlay ? (this.isGuide ? $r('app.media.pause_white') : $r('app.media.pause_norm')) :
      (this.isGuide ? $r('app.media.play_white') : $r('app.media.play_norm')))
      .size({ width: 24, height: 24 })
      .onClick(async () => {
        this.mediaService = MediaService.getInstance();
        this.isPlay ? this.mediaService.pause() : this.mediaService.play(this.url);
      });
  }
}