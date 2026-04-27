import { media } from '@kit.MediaKit';
import { AVPlayerController } from './AVPlayerController';
import { AVPlayerManager } from './AVPlayerManager';

export class SwipePlayerController {
  private avPlayerMgr?: AVPlayerManager;
  private curentIndex: number = 0;
  private swiperController?: SwiperController;

  public getCurrentAVPlayerController(): AVPlayerController | undefined {
    return this.avPlayerMgr?.getAVPlayerController(this.curentIndex);
  }

  public getAVPlayerMgr(): AVPlayerManager | undefined {
    return this.avPlayerMgr;
  }

  public getCurrentIndex(): number {
    return this.curentIndex;
  }

  public getAVPlayer(): media.AVPlayer | undefined {
    return this.avPlayerMgr?.getAVPlayer(this.curentIndex);
  }

  public setAVPlayerMgr(avPlayerMgr: AVPlayerManager): void {
    this.avPlayerMgr = avPlayerMgr;
  }

  public setSwiperController(swiperController: SwiperController): void {
    this.swiperController = swiperController;
  }

  public setCurrentIndex(curentIndex: number): void {
    this.curentIndex = curentIndex;
  }

  public async play(): Promise<void> {
    await this.avPlayerMgr?.play(this.curentIndex);
  }

  public async pause(): Promise<void> {
    await this.avPlayerMgr?.pause(this.curentIndex);
  }

  public async release(): Promise<void> {
    await this.avPlayerMgr?.release(this.curentIndex);
  }

  public seek(timeMs: number): void {
    this.avPlayerMgr?.seek(this.curentIndex, timeMs);
  }

  public setSpeed(speed: media.PlaybackSpeed): void {
    this.avPlayerMgr?.setSpeed(this.curentIndex, speed);
  }

  // 播放指定索引的视频
  public changeIndex(index: number, useAnimation: boolean = true): void {
    this.swiperController?.changeIndex(index, useAnimation);
  }
}