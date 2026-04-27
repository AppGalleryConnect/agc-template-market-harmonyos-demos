import { emitter } from '@kit.BasicServicesKit';
import { MediaViewModel } from '../viewmodel/MediaViewModel';
import { AudioConstants } from '../constants/Constants';
import { AudioViewModel } from '../viewmodel/AudioViewModel';
import { EventMap } from '../constants/EventMap';

export const entryName: string = AudioConstants.AUDIO_SUB_NAME;

@Entry({ routeName: entryName, useSharedStorage: true })
@ComponentV2
struct AudioSubWindow {
  @Local audioViewModel: AudioViewModel = new AudioViewModel(this.getUIContext())
  @Local mediaService: MediaViewModel = MediaViewModel.getInstance()

  aboutToAppear(): void {
    this.audioViewModel.initSubWindow()
  }


  build() {
    Column() {
      Column() {
        Row() {
          Image(this.mediaService.audioList[this.mediaService.audioIndex].mark)
            .objectFit(ImageFit.Fill)
            .width(32)
            .height(32)
            .borderRadius('50%')
            .clip(true)
            .rotate({ angle: this.audioViewModel.playerAnimation.imageRotate })
            .onAppear(() => {
              this.audioViewModel.playerAnimation.playerCoverRotate()
            })
            .onClick(() => {
              this.audioViewModel.onPlayerEvent()
            })
          if (!this.audioViewModel.viewState) {
            Marquee({
              start: this.mediaService.isPlaying,
              step: this.audioViewModel.step,
              loop: this.audioViewModel.loop,
              fromStart: this.audioViewModel.fromStart,
              src: this.mediaService.audioList[this.mediaService.audioIndex].title,
            })
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_on_primary'))
              .width(104)
            SymbolGlyph(MediaViewModel.getInstance().isPlaying ? $r('sys.symbol.pause_fill') :
              $r('sys.symbol.play_fill'))
              .fontSize(16)
              .fontColor([$r('sys.color.font_on_primary')])
              .onClick(() => {
                this.audioViewModel.audioPlay()
              })
            SymbolGlyph($r('sys.symbol.xmark'))
              .fontSize(16)
              .fontColor([$r('sys.color.font_on_primary')])
              .onClick(() => {
                MediaViewModel.getInstance().pause()
                emitter.emit(EventMap.DESTROY_SUB_WINDOW)
              })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .borderRadius('50%')
      .backgroundColor('#000000')
      .padding({
        left: 6,
        right: 16,
        top: 6,
        bottom: 6,
      })
      .width('100%')
      .gesture(
        PanGesture(this.audioViewModel.panOption)
          .onActionUpdate((event: GestureEvent) => {
            this.audioViewModel.onActionUpdate(event)
          })
          .onActionEnd((event: GestureEvent) => {
            this.audioViewModel.onActionEnd(event)
          }),
      )
    }
    .backgroundColor(Color.Transparent);
  }
}