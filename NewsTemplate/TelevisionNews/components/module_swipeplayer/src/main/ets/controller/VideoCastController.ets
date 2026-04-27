import { avSession } from '@kit.AVSessionKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { VideoPlayerData } from '../type/Index';

const TAG = '[VideoCastController]';

/**
 * 投播控制器
 */
@ObservedV2
export class VideoCastController {
  private castController: avSession.AVCastController;
  private curVolume: number = 0;
  private maxVolume: number = 100;
  private videoData: VideoPlayerData | undefined = undefined;
  private castListenerMap: Map<CastEventKey, Array<(...args: ESObject) => void>> = new Map();
  @Trace deviceName: string = '';
  @Trace isCasting: boolean = false;
  @Trace connectState: avSession.ConnectionState = avSession.ConnectionState.STATE_DISCONNECTED;
  // 播放进度（单位：ms）
  @Trace currentTime: number = 0;
  @Trace isSeeking: boolean = false;

  constructor(castController: avSession.AVCastController) {
    this.castController = castController;
  }

  /**
   * 更新控制器
   * @param castController
   */
  updateController(castController: avSession.AVCastController) {
    this.castController = castController;
  }

  /**
   * 注册事件监听
   * @param key
   * @param callback
   */
  registerListener(key: CastEventKey, callback: (...args: ESObject) => void) {
    if (this.castListenerMap.has(key)) {
      this.castListenerMap.get(key)?.push(callback);
    } else {
      this.castListenerMap.set(key, [callback]);
    }
  }

  /**
   * 取消注册事件监听
   * @param key
   * @param callback
   */
  unregisterListener(key: CastEventKey, callback: (...args: ESObject) => void) {
    if (this.castListenerMap.has(key)) {
      const list = this.castListenerMap.get(key) || [];
      const index = list.findIndex(v => v === callback);
      if (index !== -1) {
        list.splice(index, 1);
      }
    }
  }

  /**
   * 设置视频数据
   * @param videoData
   */
  setVideoData(videoData: VideoPlayerData) {
    this.videoData = videoData;
  }

  /**
   * 启动对端播放
   */
  async startCastPlay() {
    let file: fs.File | null = null;
    try {
      // 设置播放参数
      const playItem: avSession.AVQueueItem = {
        itemId: 0,
        description: {
          assetId: this.videoData?.getVideoId() ?? '',
          title: this.videoData?.getVideoTitle() ?? '',
          mediaType: 'VIDEO',
          startPosition: this.currentTime,
          duration: this.videoData?.getVideoDuration() ?? 0,
        },
      };
      if (this.videoData?.getVideoUrl().startsWith('http')) {
        // 网络视频
        playItem.description!.mediaUri = this.videoData?.getVideoUrl();
      } else {
        // 本地视频
        file = fs.openSync(this.videoData?.getVideoUrl());
        playItem.description!.fdSrc = { fd: file.fd };
      }
      // 准备播放，这个不会触发真正的播放，会进行加载和缓冲
      await this.castController.prepare(playItem);
      // 启动播放，真正触发对端播放。请在Prepare成功后再调用start
      await this.castController.start(playItem);
    } catch (e) {
      UtilLog.error(TAG, `Failed to playItem. Code: ${e.code}, message: ${e.message}`);
    } finally {
      try {
        if (file) {
          fs.closeSync(file);
        }
      } catch (e) {
        UtilLog.error(TAG, `Failed to closeSync. Code: ${e.code}, message: ${e.message}`);
      }
    }
  }

  /**
   * 监听远端设备事件
   */
  onPlaybackEvent() {
    try {
      // 应用监听对端或播控中心上一集切换
      this.castController.on('playPrevious', () => {
        this.castListenerMap.get(CastEventKey.PLAY_PREVIOUS)?.forEach(callback => {
          callback();
        });
      });
      // 应用监听对端或播控中心下一集切换
      this.castController.on('playNext', () => {
        this.castListenerMap.get(CastEventKey.PLAY_NEXT)?.forEach(callback => {
          callback();
        });
      });
      this.castController.on('seekDone', () => {
        this.isSeeking = false;
      });
      // 应用监听对端或播控中心播放状态、实时进度和音量变化事件
      this.castController.on('playbackStateChange', 'all', (state: avSession.AVPlaybackState) => {
        UtilLog.debug(TAG, 'playbackStateChange, state: ' + JSON.stringify(state));
        // 最大音量
        if (state.extras?.maxCastVolume) {
          this.maxVolume = state.extras?.maxCastVolume as number;
        }
        // 音量变化
        if (state.volume) {
          this.curVolume = state.volume;
        }
        // 进度变化，可以根据position来获取对端播放的进度
        if (!this.isSeeking && state.position?.elapsedTime) {
          this.currentTime = state.position.elapsedTime;
        }
        this.castListenerMap.get(CastEventKey.PLAYBACK_STATE_CHANGE)?.forEach(callback => {
          callback(state);
        });
      });
    } catch (e) {
      UtilLog.error(TAG, `Failed to onPlaybackEvent. Code: ${e.code}, message: ${e.message}`);
      this.isSeeking = false;
    }
  }

  /**
   * 应用向对端设备下发播放命令
   */
  async play() {
    try {
      const command: avSession.AVCastControlCommand = { command: 'play' };
      await this.castController.sendControlCommand(command);
    } catch (e) {
      UtilLog.error(TAG, `Failed to play. Code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 应用向对端设备下发暂停命令
   */
  async pause() {
    try {
      const command: avSession.AVCastControlCommand = { command: 'pause' };
      await this.castController.sendControlCommand(command);
    } catch (e) {
      UtilLog.error(TAG, `Failed to pause. Code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 应用调节对端设备音量
   * @param step
   */
  async setVolume(step: number) {
    try {
      const value = step * Math.ceil(100 / this.maxVolume) + step;
      this.curVolume = this.curVolume + value;
      if (this.curVolume < 0) {
        this.curVolume = 0;
      }
      if (this.curVolume > 100) {
        this.curVolume = 100;
      }
      const command: avSession.AVCastControlCommand = {
        command: 'setVolume',
        parameter: this.curVolume,
      };
      await this.castController.sendControlCommand(command);
    } catch (e) {
      UtilLog.error(TAG, `Failed to setVolume. Code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 应用调节对端设备进度
   * @param time
   */
  async seek(time: number) {
    try {
      this.isSeeking = true;
      const command: avSession.AVCastControlCommand = {
        command: 'seek',
        parameter: time,
      };
      await this.castController.sendControlCommand(command);
    } catch (e) {
      UtilLog.error(TAG, `Failed to seek. Code: ${e.code}, message: ${e.message}`);
      this.isSeeking = false;
    }
  }

  /**
   * 取消监听远端设备事件
   */
  offPlaybackEvent() {
    try {
      this.castController.off('playPrevious');
      this.castController.off('playNext');
      this.castController.off('playbackStateChange');
    } catch (e) {
      UtilLog.error(TAG, `Failed to offPlaybackEvent. Code: ${e.code}, message: ${e.message}`);
    }
  }
}

export enum CastEventKey {
  PLAY_PREVIOUS = 'playPrevious',
  PLAY_NEXT = 'playNext',
  PLAYBACK_STATE_CHANGE = 'playbackStateChange',
  END_OF_STREAM = 'endOfStream',
}
