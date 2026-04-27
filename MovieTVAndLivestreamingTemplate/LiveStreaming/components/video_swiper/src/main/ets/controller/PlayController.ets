import { media } from '@kit.MediaKit';
import { AVPlayerState } from '../constant/AVPlayerState';

@ObservedV2
export class PlayerLayoutSize {
  @Trace playerWidth: number | string = '100%';
  @Trace playerHeight: number | string = '100%';
  @Trace playerPositionX: number | string = 0;
  @Trace playerPositionY: number | string = 0;
}
@ObservedV2
export class SwipeOption {
  @Trace disableSwipe: boolean = false;
}
/**
 * 功能描述：播放控制是将swiper和video结合的控制类，实现对整体功能的控制
 * 1. 播放控制
 * 2. 选集播放
 * 3. swipe事件(当前索引变化, 滑动到末尾，滑动到开头)
 */
export class PlayController {
  playLayout: PlayerLayoutSize = new PlayerLayoutSize();
  private swiperController?: SwiperController
  autoPlay: boolean = false
  loopPlay:boolean = false
  allowBackground:boolean = false;
  private avPlayerMap: Map<number, media.AVPlayer> = new Map
  public curentIndex: number = 0;
  swipeOption:SwipeOption = new SwipeOption()
  private listener: BackPressListener = new BackPressListener();
  static onStopPip?: Function

  setSwiperController(swiperController: SwiperController) {
    this.swiperController = swiperController
  }

  setAVPlayer(index: number, avPlayer: media.AVPlayer) {
    this.avPlayerMap.set(index, avPlayer)
  }

  getAVPlayer(): media.AVPlayer | undefined {
    return this.avPlayerMap.get(this.curentIndex);
  }

  private canPlay(state: string): boolean {
    return state === AVPlayerState.PREPARED || state === AVPlayerState.PAUSED || state === AVPlayerState.COMPLETED;
  }

  public play() {
    let avPlayer = this.avPlayerMap.get(this.curentIndex)
    if (!avPlayer) {
      return
    }
    if (!this.canPlay(avPlayer.state)) {
      return;
    }
    avPlayer.play()
  }

  private canPause(state: string): boolean {
    return state === AVPlayerState.PLAYING
  }

  public pause() {
    let avPlayer = this.avPlayerMap.get(this.curentIndex)
    if (!avPlayer) {
      return
    }
    if (!this.canPause(avPlayer.state)) {
      return
    }
    avPlayer.pause();
  }

  private canSeek(state: string): boolean {
    return (state === AVPlayerState.PREPARED) || (state === AVPlayerState.PLAYING) ||
      (state === AVPlayerState.PAUSED) || (state === AVPlayerState.COMPLETED)
  }

  public seek(timeMs: number) {
    let avPlayer = this.avPlayerMap.get(this.curentIndex)
    if (!avPlayer) {
      return
    }
    if (!this.canSeek(avPlayer.state)) {
      return
    }
    avPlayer.seek(timeMs, media.SeekMode.SEEK_PREV_SYNC);
  }

  private canSetSpeed(state: string) {
    return state === AVPlayerState.PREPARED || state === AVPlayerState.PLAYING || state === AVPlayerState.PAUSED ||
      state === AVPlayerState.COMPLETED;
  }

  public setSpeed(speed: media.PlaybackSpeed) {
    let avPlayer = this.avPlayerMap.get(this.curentIndex)
    if (!avPlayer) {
      return
    }
    if (!this.canSetSpeed(avPlayer.state)) {
      return
    }
    avPlayer.setSpeed(speed);
  }

  // 设置播放视图的高度，避让详情页的详情栏
  public setPlayerHeight(height: number | string) {
    this.playLayout.playerHeight = height
  }

  public setPlayerWidth(width: number | string) {
    this.playLayout.playerWidth = width
  }

  public setPlayerPositionX(x: number | string) {
    this.playLayout.playerPositionX = x
  }

  // 播放指定索引的剧集
  public changeIndex(index: number) {
    this.swiperController?.changeIndex(index)
  }

  public disableSwipe(disable:boolean){
    this.swipeOption.disableSwipe = disable
  }

  public backPressListener(): BackPressListener {
    return this.listener;
  }
}
export class BackPressListener {
  private onBackPressCallback?: () => void;

  public onBackPress(): boolean {
    if (this.onBackPressCallback) {
      this.onBackPressCallback();
      this.onBackPressCallback = undefined;
      return true;
    } else {
      return false;
    }
  }

  public registerOnBackPress(onBackPressCallback: () => void) {
    this.onBackPressCallback = onBackPressCallback;
  }

  public clearOnBackPress() {
    this.onBackPressCallback = undefined;
  }

  stopPip() {
    if(PlayController.onStopPip){
      PlayController.onStopPip()
    }
  }
}