import { media } from '@kit.MediaKit';
import { AVPlayerState } from '../type/Index';
import { Logger } from '../utils/Logger';

const TAG = '[AVPlayerController]';

/**
 * AVPlayer控制器
 */
export class AVPlayerController {
  public avPlayer: media.AVPlayer | undefined = undefined;
  public avPlayerCallback: Map<string, Array<(...args: ESObject) => void>> = new Map();

  /**
   * 添加listener
   * @param key
   * @param callback
   */
  public onEvent(key: string, callback: (...args: ESObject) => void): void {
    if (this.avPlayerCallback.has(key)) {
      this.avPlayerCallback.get(key)?.push(callback);
    } else {
      this.avPlayerCallback.set(key, [callback]);
    }
  }

  /**
   * 删除listener
   * @param key
   * @param callback
   */
  public offEvent(key: string, callback: (...args: ESObject) => void): void {
    if (this.avPlayerCallback.has(key)) {
      const list = this.avPlayerCallback.get(key) || [];
      const index = list.findIndex(v => v === callback);
      if (index !== -1) {
        list.splice(index, 1);
      }
    }
  }

  public setAVPlayer(avPlayer: media.AVPlayer): void {
    this.avPlayer = avPlayer;
  }

  public getAVPlayer(): media.AVPlayer | undefined {
    return this.avPlayer;
  }

  private canPlay(state: string): boolean {
    let canPlayStates = [
      AVPlayerState.PREPARED,
      AVPlayerState.PAUSED,
      AVPlayerState.COMPLETED,
    ] as string[]
    return canPlayStates.includes(state)
  }

  public async play(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }
    if (!this.canPlay(this.avPlayer.state)) {
      return;
    }
    try {
      await this.avPlayer.play();
    } catch (err) {
      Logger.debug(TAG, 'play error!');
    }
  }

  public async pause(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }
    if (this.avPlayer.state !== AVPlayerState.PLAYING) {
      return;
    }

    try {
      await this.avPlayer.pause();
    } catch (err) {
      Logger.debug(TAG, 'pause error!');
    }
  }

  public async reset(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }
    try {
      await this.avPlayer.reset();
    } catch (err) {
      Logger.debug(TAG, 'reset error!');
    }
  }

  // 跳转到指定播放位置，只能在prepared/playing/paused/completed状态调用
  public seek(seekTime: number): void {
    if (!this.avPlayer) {
      return;
    }
    if (![AVPlayerState.PREPARED,
      AVPlayerState.PAUSED,
      AVPlayerState.PLAYING,
      AVPlayerState.COMPLETED,
    ].includes(this.avPlayer.state as AVPlayerState)) {
      return;
    }

    try {
      this.avPlayer.seek(seekTime, media.SeekMode.SEEK_PREV_SYNC);
    } catch (err) {
      Logger.debug(TAG, 'seek error!');
    }
  }
}