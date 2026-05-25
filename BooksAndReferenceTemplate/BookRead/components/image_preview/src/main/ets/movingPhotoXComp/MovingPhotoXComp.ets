import { PreviewComponentInfo, SourceImageModel } from '../models/PreviewModel';
import { AvPlayerController } from './AvPlayerController';
import { AVPlayerState, AvState } from '../models/AVPlayerState';
import { ImagePreviewOptions } from '../models/ImagePreviewOptions';

const TAG = '[MovingPhotoXComp]';

@ComponentV2
export struct MovingPhotoXComp {
  @Param longTakeEffectMap: Map<number, PreviewComponentInfo> = new Map()
  @Param @Require index: number
  @Param @Require imageSrc: SourceImageModel
  @Param @Require params: ImagePreviewOptions
  @Param loadingStatus: number = 0
  @Param startIndex: number = 0
  @Param avPlayerController: AvPlayerController = new AvPlayerController(this.getUIContext())
  @Local surfaceW: number = 0;
  @Local surfaceH: number = 0;
  @Local playerState: AvState = new AvState()
  @Event onStart: () => void = () => {
  }
  @Event onPause: () => void = () => {
  }
  @Event onFinish: () => void = () => {
  }
  @Event onPrepared: () => void = () => {
  }
  private surfaceId: string = '';
  private xComponentController: XComponentController = new XComponentController();

  @Monitor('loadingStatus')
  loadingStatusChange() {
    if (this.loadingStatus === 1) {
      this.surfaceW = this.longTakeEffectMap.get(this.index)?.width ?? 0
      this.surfaceH = this.longTakeEffectMap.get(this.index)?.height ?? 0
    }
  }

  @Monitor('playerState.avState')
  playerStateChange() {
    if (this.playerState.avState === AVPlayerState.PREPARED) {
      this.onPrepared()
      this.params.onPreparedListener(this.imageSrc, this.startIndex)
    }
    if (this.playerState.avState === AVPlayerState.PAUSED) {
      this.onPause()
      this.params.onPauseListener(this.imageSrc, this.startIndex)
    }
    if (this.playerState.avState === AVPlayerState.COMPLETED) {
      this.onFinish()
      this.params.onFinishListener(this.imageSrc, this.startIndex)
    }
    if (this.playerState.avState === AVPlayerState.PLAYING) {
      this.onStart()
      this.params.onStartListener(this.imageSrc, this.startIndex)
    }
    if (this.playerState.avState === AVPlayerState.STOPPED) {
      this.params.onStopListener(this.imageSrc, this.startIndex)
    }
  }

  aboutToAppear() {
    this.avPlayerController.setState(this.playerState)
  }

  aboutToDisappear() {
    this.avPlayerController.videoRelease();
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      XComponent({
        id: 'xComponent',
        type: XComponentType.SURFACE,
        controller: this.xComponentController,
      })
        .onLoad(() => {
          this.surfaceId = this.xComponentController.getXComponentSurfaceId();
          this.avPlayerController.initAVPlayer(this.imageSrc.videoUrl!, this.surfaceId);
        })
        .height(this.surfaceH)
        .width(this.surfaceW)
      Image(this.imageSrc.imageUrl)
        .objectFit(ImageFit.Contain)
        .draggable(false)
        .gesture(
          GestureGroup(GestureMode.Exclusive,
            LongPressGesture().onAction(() => {
              this.avPlayerController.videoPlay()
            })
              .onActionEnd(() => {
                this.avPlayerController.videoStop()
              }),
          ),
        )
        .visibility(this.playerState.avState !== AVPlayerState.PLAYING ? Visibility.Visible : Visibility.None)
    }
  }
}