import { media } from '@kit.MediaKit';
import { PlayerLayoutSize } from './PlayController';

/**
 * 功能描述：播放会话是一个播放条目的播放封装，通过该会话能获取当前播放条目的播放状态
 * 1. 播放会话事件(播放状态变化，播放进度，播放完成事件)
 */
export class PlaySession {
  public avPlayer: media.AVPlayer | undefined = undefined;
  public avPlayerCallback: Map<string, Array<(...arg: string[] | number[]) => void>> = new Map();
  public stateChangeCallbacks: Map<string, Array<(state: string) => void>> = new Map();
  public timeUpdateCallbacks: Map<string, Array<(time: number) => void>> = new Map();
  onStartPip?: Function
  playLayout: PlayerLayoutSize = new PlayerLayoutSize();

  // 状态变化事件监听
  onStateChange(key: string, callback: (state: string) => void): void {
    if (this.stateChangeCallbacks.has(key)) {
      this.stateChangeCallbacks.get(key)?.push(callback);
    } else {
      this.stateChangeCallbacks.set(key, [callback]);
    }
  }

  // 时间更新事件监听
  onTimeUpdate(key: string, callback: (time: number) => void): void {
    if (this.timeUpdateCallbacks.has(key)) {
      this.timeUpdateCallbacks.get(key)?.push(callback);
    } else {
      this.timeUpdateCallbacks.set(key, [callback]);
    }
  }

  setAVPlayer(avPlayer: media.AVPlayer) {
    this.avPlayer = avPlayer;
  }

  getAVPlayer() {
    return this.avPlayer;
  }

  startPip() {
    if(this.onStartPip){
      this.onStartPip()
    }
  }
}