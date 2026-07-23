import { media } from '@kit.MediaKit';
import { AVPlayerState } from '../constant/AVPlayerState';
import { AvPlayer } from './AvPlayer';
import { PlaySession } from './PlaySession';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AvPlayerPool } from './AvPlayerPool';
import { MediaSource } from '../constant/MediaSource'

@ObservedV2
export class PlayerLayoutSize {
  @Trace playerWidth: number | string = '100%';
  @Trace playerHeight: number | string = '100%';
  @Trace playerPositionX: number | string = 0;
  @Trace playerPositionY: number | string = 0;
}

const TAG = 'Player_Controller'

/**
 * 功能描述：播放控制是将swiper和video结合的控制类，实现对整体功能的控制
 * 1. 播放控制
 * 2. 选集播放
 * 3. swipe事件(当前索引变化, 滑动到末尾，滑动到开头)
 */
@ObservedV2
export class PlayController {
  playList: MediaSource[] = []
  playLayout: PlayerLayoutSize = new PlayerLayoutSize();
  private swiperController?: SwiperController
  autoPlay: boolean = false
  @Trace isLocked: boolean = false
  private avPlayerMap: Map<number, AvPlayer> = new Map
  @Trace curentIndex: number = 0;
  @Trace id: string = ''
  @Trace isVip: boolean = false
  static _lockedDrama: Map<string, Array<number>> = new Map
  @Trace isCasting: boolean = false
  @Trace disableSwiper: boolean = false
  private surfaceMap: Map<number, string> = new Map

  public static get lockedDrama() {
    if (!PlayController._lockedDrama) {
      PlayController._lockedDrama = new Map
    }
    return PlayController._lockedDrama;
  }

  setPlayList(playList: MediaSource[]) {
    this.playList = playList
  }

  setSurfaceId(index: number, surfaceId: string) {
    this.surfaceMap.set(index, surfaceId)
  }

  clearSurfaceId(index: number) {
    this.surfaceMap.delete(index)
  }

  setSwiperController(swiperController: SwiperController) {
    this.swiperController = swiperController
  }

  setAVPlayer(index: number, avPlayer: AvPlayer) {
    hilog.error(0x000, TAG, `setAVPlayer Player index:${index} curentIndex:${this.curentIndex}`)
    this.avPlayerMap.set(index, avPlayer)
  }

  getAVPlayer(): AvPlayer | undefined {
    return this.avPlayerMap.get(this.curentIndex);
  }

  private canPlay(state: string): boolean {
    return state === AVPlayerState.PREPARED || state === AVPlayerState.PAUSED || state === AVPlayerState.COMPLETED;
  }

  public play() {
    let avPlayer = this.avPlayerMap.get(this.curentIndex)
    if (!avPlayer) {
      hilog.error(0x000, TAG, `can not find Player ${this.curentIndex}`)
      return
    }
    if (!this.canPlay(avPlayer.state)) {
      hilog.error(0x000, TAG, `can not Play ${this.curentIndex}`)
      return;
    }
    avPlayer.play()
  }

  public async playIndex(index: number) {
    this.curentIndex = index
    // 处理surface重定向，解决小窗关闭后的播放问题
    let mediaSource = this.playList[index]
    // 复用播放器
    let avPlayer: AvPlayer = await AvPlayerPool.getInstance().acquire(mediaSource);
    let hasSurfaceId = this.surfaceMap.has(index)
    if (hasSurfaceId) {
      let surfaceId = this.surfaceMap.get(index)
      if (!surfaceId) {
        return
      }
      hilog.info(0x000, TAG, `playIndex setSurfaceId:${surfaceId}`)
      avPlayer?.setSurfaceID(surfaceId)
    }
  }

  private canPause(state: string): boolean {
    return state === AVPlayerState.PLAYING
  }

  public async pause() {
    let avPlayer = this.avPlayerMap.get(this.curentIndex)
    if (!avPlayer) {
      return
    }
    // if (!this.canPause(avPlayer.state)) {
    //   return
    // }
    await avPlayer.pause();
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
    avPlayer.seek(timeMs);
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
    avPlayer.setPlaybackRate(speed);
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
    this.curentIndex = index
    this.swiperController?.changeIndex(index, true)
  }
}
