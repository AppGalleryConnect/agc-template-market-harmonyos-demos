import { media } from '@kit.MediaKit';
import { AVPlayerState } from '../type/Index';
import { Logger } from '../utils/Logger';
import { AVPlayerController } from './AVPlayerController';

const TAG = '[AVPlayerManager]';

/**
 * AVPlayer管理器
 */
export class AVPlayerManager {
  private static instance?: AVPlayerManager
  private playerIdMap: Map<number, string> = new Map();
  private playerControllerMap: Map<string, AVPlayerController> = new Map();

  public static getInstance(): AVPlayerManager {
    if (!AVPlayerManager.instance) {
      AVPlayerManager.instance = new AVPlayerManager()
    }
    return AVPlayerManager.instance
  }

  public getAVPlayer(index: number): media.AVPlayer | undefined {
    let playerId = this.playerIdMap.get(index);
    return this.playerControllerMap.get(playerId!)?.avPlayer;
  }

  private canPlay(state: string): boolean {
    let canPlayStates = [
      AVPlayerState.PREPARED,
      AVPlayerState.PAUSED,
      AVPlayerState.COMPLETED,
    ] as string[]
    return canPlayStates.includes(state)
  }

  public async play(index: number): Promise<void> {
    let playerId = this.playerIdMap.get(index);
    const target = this.playerControllerMap.get(playerId!)?.avPlayer;
    if (!target) {
      return;
    }
    if (!this.canPlay(target.state)) {
      return;
    }

    try {
      await target.play();
    } catch (err) {
      Logger.debug(TAG, 'play error! avPlayer undefined!');
    }
  }

  public async pause(index: number): Promise<void> {
    let playerId = this.playerIdMap.get(index);
    const target = this.playerControllerMap.get(playerId!)?.avPlayer;
    if (!target) {
      return;
    }
    if (target.state !== AVPlayerState.PLAYING) {
      return;
    }

    try {
      await target.pause();
    } catch (err) {
      Logger.debug(TAG, 'pause error! avPlayer undefined!');
    }
  }

  public async release(index: number): Promise<void> {
    let playerId = this.playerIdMap.get(index);
    if (!this.playerControllerMap.get(playerId!)?.avPlayer) {
      return;
    }

    try {
      await this.playerControllerMap.get(playerId!)?.avPlayer?.release();
    } catch (err) {
      Logger.debug(TAG, 'release error! avPlayer undefined!');
    }
  }

  public seek(index: number, timeMs: number): void {
    let playerId = this.playerIdMap.get(index);
    if (!this.playerControllerMap.get(playerId!)?.avPlayer) {
      return;
    }

    try {
      this.playerControllerMap.get(playerId!)?.avPlayer?.seek(timeMs, media.SeekMode.SEEK_PREV_SYNC);
    } catch (err) {
      Logger.debug(TAG, 'seek error! avPlayer undefined!');
    }
  }

  private canSetSpeed(state: string): boolean {
    let canSetSpeedStates = [
      AVPlayerState.PREPARED,
      AVPlayerState.PLAYING,
      AVPlayerState.PAUSED,
      AVPlayerState.COMPLETED,
    ] as string[]
    return canSetSpeedStates.includes(state)
  }

  public setSpeed(index: number, speed: media.PlaybackSpeed): void {
    let playerId = this.playerIdMap.get(index);
    const target = this.playerControllerMap.get(playerId!)?.avPlayer;
    if (!target) {
      return;
    }
    if (!this.canSetSpeed(target.state)) {
      return;
    }

    try {
      this.playerControllerMap.get(playerId!)?.avPlayer?.setSpeed(speed);
    } catch (err) {
      Logger.debug(TAG, 'setSpeed error! avPlayer undefined!');
    }
  }

  public setPlayerId(index: number, playerId: string): void {
    this.playerIdMap.set(index, playerId);
  }

  public getPlayerId(index: number): string | undefined {
    return this.playerIdMap.get(index);
  }

  public setAVPlayerController(playerId: string, avPlayerController: AVPlayerController): void {
    this.playerControllerMap.set(playerId, avPlayerController);
  }

  public getAVPlayerController(index: number): AVPlayerController | undefined {
    let playerId = this.playerIdMap.get(index);
    return this.playerControllerMap.get(playerId!);
  }

  public deleteAVPlayerController(playerId: string): void {
    this.playerControllerMap.delete(playerId);
  }

  public clear(): void {
    this.playerIdMap.clear()
    this.playerControllerMap.clear()
  }
}
