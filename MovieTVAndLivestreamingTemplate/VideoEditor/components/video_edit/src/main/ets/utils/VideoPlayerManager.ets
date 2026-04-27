import media from '@ohos.multimedia.media';
import { BusinessError } from '@ohos.base';
import { fileIo } from '@kit.CoreFileKit';
import { BasicVideoData } from 'video_common';

// 播放状态接口
export interface PlayerState {
  isPlaying: boolean;
  isLoading: boolean;
  currentIndex: number;
  currentSegmentPlayed: number;
  totalPlayDuration: number;
  errorMessage: string;
  status: string;
  width: number;
  height: number;
}

export type PlayerStateChangeCallback = (state: PlayerState) => void;

const TAG = 'VideoPlayerManager';

/**
 * 双播放器无缝播放工具类
 */

export class VideoPlayerManager {
  private segmentList: BasicVideoData[] = [];
  public currentIndex: number = -1;
  private currentUrl: string = ''
  private currentFd: string = ''
  private totalPlayDuration: number = 0;
  private currentSegmentPlayed: number = 0;
  private errorMessage: string = '';
  private isPlaying: boolean = false
  private videoWidth: number = 0
  private videoHeight: number = 0
  // 双播放器实例
  private playerA: media.AVPlayer | null = null;
  private playerB: media.AVPlayer | null = null;
  private activePlayer: media.AVPlayer | null = null;
  private standbyPlayer: media.AVPlayer | null = null;
  public surfaceID: string = '';
  private switchThreshold = 500; // 切换阈值（毫秒）
  private playTimer: number | null = null;
  private currentStartTime: number = 0
  private stateChangeCallbacks: PlayerStateChangeCallback[] = [];
  private isSeeking: boolean = false // 锁
  private isChanging: boolean = false // 锁
  public seekSegmentIndex: number = 0
  private isStartPlay: boolean = false
  private isMuted: boolean = false

  /**
   * 构造函数
   * @param initialSegments 初始片段列表
   */
  constructor(initialSegments: BasicVideoData[], surfaceId: string) {
    this.segmentList = initialSegments
    this.surfaceID = surfaceId
    this.initDualPlayers(this.segmentList) // 初始化双播放器
  }

  /**
   * 注册状态变化回调（调用类通过此方法监听实时状态）
   * @param callback 状态变化时的回调函数
   */
  registerStateChangeCallback(callback: PlayerStateChangeCallback): void {
    if (!this.stateChangeCallbacks.includes(callback)) {
      this.stateChangeCallbacks.push(callback);
    }
  }

  /**
   * 取消状态变化回调
   * @param callback 要取消的回调函数
   */
  unregisterStateChangeCallback(callback: PlayerStateChangeCallback): void {
    this.stateChangeCallbacks = this.stateChangeCallbacks.filter(cb => cb !== callback);
  }

  /**
   * 通知所有注册的回调（状态变化时调用）
   */
  private notifyStateChange(): void {
    const currentState = this.getPlayState();
    this.stateChangeCallbacks.forEach(callback => {
      try {
        callback(currentState);
      } catch (err) {
      }
    });
  }

  /**
   * 初始化双播放器
   */
  private async initDualPlayers(initialSegments: BasicVideoData[]): Promise<void> {
    try {
      this.currentStartTime = this.segmentList[0]?.startTime
      // 初始化播放器A（活跃）
      this.playerA = await media.createAVPlayer();
      this.activePlayer = this.playerA;
      this.setupPlayerListeners(this.playerA, 'A');
      // 加载片段到活跃播放器
      await this.loadSegmentToPlayer(this.activePlayer!, initialSegments[0]);

      // 初始化播放器B（备用）
      this.playerB = await media.createAVPlayer();
      this.standbyPlayer = this.playerB;
      this.setupPlayerListeners(this.playerB, 'B');
      this.notifyStateChange(); // 初始化完成后通知状态
    } catch (err) {
      const error = err as BusinessError;
      this.setError(`创建播放器失败：${error.message}`);
    }
  }

  /**
   * 更新片段列表
   */
  updateSegmentList(newSegments: BasicVideoData[]): void {
    this.segmentList = [...newSegments];
    this.resetPlayState();
    this.notifyStateChange(); // 更新片段列表后通知状态
  }

  /**
   * 设置播放器监听
   */
  private setupPlayerListeners(avPlayer: media.AVPlayer, _playerName: 'A' | 'B'): void {
    avPlayer.on('startRenderFrame', () => {
      this.notifyStateChange(); // 首帧渲染后更新状态
    });
    avPlayer.on('seekDone', (seekTime: number) => {
      this.isSeeking = false
      if (avPlayer === this.activePlayer && this.currentIndex >= 0) {
        const currentSegment = this.segmentList[this.currentIndex];
        this.currentSegmentPlayed = Math.max(0, (seekTime / 1000) - currentSegment.startTime);
        this.notifyStateChange();
      }
    });
    avPlayer.on('timeUpdate', (currentTime: number) => {
      if (avPlayer !== this.activePlayer || this.currentIndex < 0) {
        return;
      }
      avPlayer.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, this.isMuted);

      // currentTime 是视频总进度（毫秒）
      const currentSegment = this.segmentList[this.currentIndex];
      const segmentInnerTime = currentTime - currentSegment.startTime;
      this.currentSegmentPlayed = Math.max(0, Math.min(segmentInnerTime, currentSegment.duration));

      // 检测是否超出片段时长（避免播放超时）
      if (currentTime < currentSegment.duration) {
        if (currentSegment.duration - currentTime <= this.switchThreshold) {
          const nextIndex = this.currentIndex + 1;
          if (nextIndex < this.segmentList.length) {
            this.isPlaying = true
            this.preloadNextSegment(nextIndex);
          }
        }
      }
      // 实时通知状态（播放时间变化）
      this.notifyStateChange();
    });
    avPlayer.on('error', (_err: BusinessError) => {
      // 调用reset重置资源，触发idle状态
    })
    avPlayer.on('stateChange', async (state: string, _reason: media.StateChangeReason) => {
      switch (state) {
        case 'idle':
          break;
        case 'initialized':
          // 设置surfaceID
          avPlayer.surfaceId = this.surfaceID;
          avPlayer.prepare();
          break;
        case 'prepared':
          this.isChanging = false
          avPlayer.seek(this.currentStartTime)
          if (this.currentIndex !== -1 && this.isStartPlay) {
            avPlayer.play()
          }
          break;
        case 'playing':
          this.isPlaying = true
          this.startTimer(); // 启动进度计时器
          break;
        case 'paused':
          this.clearTimer();
          break;
        case 'completed':
          //调用播放结束接口
          avPlayer.pause();
          break;
        case 'stopped':
          // 调用prepare接口初始化avplayer状态重播
          avPlayer.pause();
          break;
        case 'released':
          break;
        default:
          break;
      }
      this.videoWidth = avPlayer.width
      this.videoHeight = avPlayer.height
      // 状态变化后通知调用类
      this.notifyStateChange();
    });
  }

  /**
   * 开始播放（从指定索引）
   */
  async startPlayback(startIndex: number, startTime: number): Promise<void> {
    this.isStartPlay = true
    this.currentStartTime = startTime
    try {
      if (!this.surfaceID) {
        throw new Error('未绑定 surfaceId，请先调用 setSurfaceId');
      }
      if (this.segmentList.length === 0) {
        throw new Error('无可用片段');
      }
      if (startIndex < 0 || startIndex >= this.segmentList.length) {
        throw new Error('起始索引无效');
      }
      this.clearError();
      this.currentIndex = startIndex;
      const targetSegment = this.segmentList[startIndex];

      if (startIndex === this.seekSegmentIndex) {
        this.seekSegmentIndex = startIndex
        if (['prepared', 'playing', 'paused', 'completed'].includes(this.activePlayer?.state ?? '')) {
          // 开始播放
          this.activePlayer!.seek(startTime, media.SeekMode.SEEK_NEXT_SYNC);
          await this.activePlayer!.play()
        } else {
          await this.loadSegmentToPlayer(this.activePlayer!, targetSegment);
        }
      } else {
        this.seekSegmentIndex = startIndex
        //更新视频源
        await this.activePlayer!.reset()
        const fd = await fileIo.open(targetSegment.basicUrl, fileIo.OpenMode.READ_ONLY);
        const url = `fd://${fd.fd}`;
        this.activePlayer!.url = url; // 动态切换资源
      }
      this.notifyStateChange(); // 开始加载前通知状态

      // 预加载下一个片段
      const nextIndex = startIndex + 1;
    } catch (err) {
      const error = err as BusinessError;
      this.setError(`播放失败：${error.message || error.code}`);
    } finally {
    }
  }

  /**
   * 获取当前播放状态（供 UI 渲染使用）
   * 返回类型指定为 PlayerState 接口，解决编译器报错
   */
  getPlayState(): PlayerState {
    let playerState = {
      isPlaying: this.isPlaying,
      width: this.videoWidth,
      height: this.videoHeight,
      currentIndex: this.currentIndex,
      currentSegmentPlayed: this.currentSegmentPlayed,
      totalPlayDuration: this.totalPlayDuration,
      errorMessage: this.errorMessage,
    } as PlayerState
    return playerState
  }

  /**
   * 暂停播放
   */
  async pausePlayback(): Promise<void> {
    this.isStartPlay = false
    try {
      if (this.activePlayer?.state === 'playing') {
        this.isPlaying = false
        await this.activePlayer.pause();
      }
      this.clearTimer();
      this.notifyStateChange(); // 暂停后通知状态
    } catch (err) {
      const error = err as BusinessError;
      this.setError(`暂停失败：${error.message}`);
    }
  }

  /**
   * 恢复播放
   */
  async resumePlayback(): Promise<void> {
    try {
      if (!this.surfaceID) {
        throw new Error('未绑定 surfaceId');
      }
      if (this.currentIndex < 0) {
        return;
      }
      if (this.activePlayer?.state === 'paused') {
        await this.activePlayer.play();
        this.startTimer();
        this.notifyStateChange(); // 恢复后通知状态
      }
    } catch (err) {
      const error = err as BusinessError;
      this.setError(`恢复失败：${error.message}`);
    }
  }

  /**
   * 两个视频长按左右切换后，切换播放机、更换视频fd、seek到对应位置（时间戳）
   */
  async parentItemMoveSeek(time: number, allBasicVideos: BasicVideoData[]) {
    try {
      if (!this.activePlayer) {
        throw new Error('无当前播放片段');
      }

      // 遍历所有视频，动态计算遍历到当前视频元素后，遍历到的所有视频的时长
      let totalTime = 0;
      for (let index = 0; index < allBasicVideos.length; index++) {
        const element = allBasicVideos[index];
        totalTime += element.duration;

        if (time <= totalTime) {
          // 切换后当前视频播放的位置（时间戳）
          const currentTime = element.duration - (totalTime - time);
          // 切换播放机，（1、播放时间小于所有视频的时长；2、播放时间大于其中一个视频时长，小于另外一个视频时长）
          // 两种场景不做区分，直接切换播放机，简化逻辑
          const tempPlayer = this.activePlayer;
          this.activePlayer = this.standbyPlayer!;
          this.standbyPlayer = tempPlayer;
          await this.standbyPlayer.reset()
          // 给激活态播放机赋值视频fd、并seek到对应位置
          if (this.activePlayer.state === 'idle') {
            let file = await fileIo.open(element.basicUrl, fileIo.OpenMode.READ_ONLY);
            this.activePlayer.url = 'fd://' + file.fd;
            this.isChanging = true
            this.seekSegmentIndex = index
            if (['prepared', 'playing', 'paused', 'completed'].includes(this.activePlayer.state)) {
              this.activePlayer.seek(currentTime);
              this.isSeeking = true
            }
          }
          break;
        }
      }
    } catch (error) {
    }
  }

  async seekToAction1(time: number, index: number, _direction: number, currentSegment: BasicVideoData,
    absoluteTime: number) {
    if (!this.activePlayer) {
      throw new Error('无当前播放片段');
    }
    if (index === this.seekSegmentIndex && time < currentSegment.duration - 200) {
      if (['prepared', 'playing', 'paused', 'completed'].includes(this.activePlayer.state)) {
        this.activePlayer.seek(absoluteTime);
        this.isSeeking = true
      }
    } else {
      if (!this.isChanging) {
        const tempPlayer = this.activePlayer;
        this.activePlayer = this.standbyPlayer!;
        this.standbyPlayer = tempPlayer;
        await this.standbyPlayer.reset()
        let file = await fileIo.open(this.segmentList[index].basicUrl, fileIo.OpenMode.READ_ONLY);
        let fdPath = `fd://${file.fd}`;
        if (this.activePlayer.state === 'idle') {
          this.activePlayer.url = fdPath
        }
        this.isChanging = true
        this.seekSegmentIndex = index
      }
    }
  }

  async seekToAction2(time: number, index: number, _direction: number, _currentSegment: BasicVideoData,
    absoluteTime: number) {
    if (!this.activePlayer) {
      throw new Error('无当前播放片段');
    }
    if (time > 200 && index === this.seekSegmentIndex) {
      if (['prepared', 'playing', 'paused', 'completed'].includes(this.activePlayer.state)) {
        this.activePlayer.seek(absoluteTime);
        this.isSeeking = true
      }
    } else {
      if (!this.isChanging) {
        const tempPlayer = this.activePlayer;
        this.activePlayer = this.standbyPlayer!;
        this.standbyPlayer = tempPlayer;
        await this.standbyPlayer.reset()
        let file = await fileIo.open(this.segmentList[index].basicUrl, fileIo.OpenMode.READ_ONLY);
        let fdPath = `fd://${file.fd}`;
        if (this.activePlayer.state === 'idle') {
          this.activePlayer.url = fdPath
        }
        this.isChanging = true
        this.seekSegmentIndex = index
      }
    }
  }

  async seekToAction(time: number, index: number, direction: number, currentSegment: BasicVideoData,
    absoluteTime: number) {
    if (direction > 0) {
      this.seekToAction1(time, index, direction, currentSegment, absoluteTime)
    } else if (direction < 0) {
      this.seekToAction2(time, index, direction, currentSegment, absoluteTime)
    }
  }

  /**
   * 进度跳转（当前片段内）
   */
  async seekTo(time: number, index: number, direction: number): Promise<void> {
    this.isStartPlay = false
    try {
      if (time < 0) {
        return
      }
      if (this.isSeeking) {
        return
      }
      if (!this.activePlayer) {
        throw new Error('无当前播放片段');
      }
      const currentSegment = this.segmentList[index];
      if (time < 0 || time > currentSegment.duration) {
        throw new Error(`跳转时间无效（0-${currentSegment.duration}s）`);
      }
      this.currentSegmentPlayed = time;
      // 计算绝对跳转时间（片段起始时间 + 目标时间）
      const absoluteTime = (currentSegment.startTime + time); // 毫秒
      this.seekToAction(time, index, direction, currentSegment, absoluteTime)
      // 跳转后保持原状态（播放/暂停）
      if (this.activePlayer.state === 'playing') {
        this.startTimer();
      }
      this.notifyStateChange(); // 跳转后通知状态
    } catch (err) {
      const error = err as BusinessError;
      this.setError(`跳转失败：${error.message}`);
    }
  }


  /**
   * 加载片段到指定播放器
   */
  private async loadSegmentToPlayer(player: media.AVPlayer, segment: BasicVideoData): Promise<void> {
    await player.reset();
    let file = await fileIo.open(segment.basicUrl, fileIo.OpenMode.READ_ONLY);
    let fdPath = `fd://${file.fd}`;
    if (this.currentIndex === -1) {
      player.url = fdPath; // 动态切换资源
    }
    this.currentFd = fdPath
    this.currentUrl = segment.basicUrl
  }

  /**
   * 预加载下一个片段（备用播放器）
   */
  private async preloadNextSegment(index: number): Promise<void> {
    this.seekSegmentIndex = index
    if (!this.standbyPlayer || index >= this.segmentList.length || !this.surfaceID) {
      return;
    }

    try {
      const segment = this.segmentList[index];
      await this.loadSegmentToPlayer(this.standbyPlayer, segment);
    } catch (err) {
    }
  }

  /**
   * 处理片段播放完成
   */
  private async handleSegmentComplete(): Promise<void> {
    this.clearTimer();
    // 累计总时长
    if (this.currentIndex >= 0) {
      this.totalPlayDuration += this.segmentList[this.currentIndex].duration;
    }
    this.currentSegmentPlayed = 0;
    // 切换到下一个片段
    const nextIndex = this.currentIndex + 1;
    if (nextIndex < this.segmentList.length) {
      await this.switchToNextSegment(nextIndex);
    } else {
      // 所有片段播放完成
      this.currentIndex = -1;
      this.isPlaying = false
      this.activePlayer?.pause()
    }
    this.notifyStateChange(); // 片段切换后通知状态
  }

  /**
   * 切换到下一个片段（双播放器交替核心）
   */
  private async switchToNextSegment(nextIndex: number): Promise<void> {
    if (!this.activePlayer || !this.standbyPlayer || !this.surfaceID) {
      return;
    }
    try {
      this.currentIndex = nextIndex;
      const targetSegment = this.segmentList[nextIndex];
      this.currentStartTime = targetSegment.startTime
      this.notifyStateChange(); // 切换前通知加载状态
      this.activePlayer.pause()
      // 切换活跃/备用角色（无需重新绑定 surfaceId，已提前绑定）
      const tempPlayer = this.activePlayer;
      this.activePlayer = this.standbyPlayer;
      this.standbyPlayer = tempPlayer;
      this.activePlayer.url = this.currentFd
      // 预加载下下个片段
      const nextNextIndex = nextIndex + 1;
      if (nextNextIndex < this.segmentList.length) {
        this.preloadNextSegment(nextNextIndex);
      }
    } catch (err) {
      const error = err as BusinessError;
      this.setError(`切换片段失败：${error.message}`);
    } finally {
      this.notifyStateChange(); // 切换后通知状态
    }
  }

  /**
   * 启动进度计时器（双重保障：配合 timeUpdate 监听）
   */
  private startTimer(): void {
    this.clearTimer();
    this.playTimer = setInterval(() => {
      if (this.currentIndex < 0 || !this.activePlayer || this.activePlayer.state !== 'playing') {
        return;
      }
      const currentSegment = this.segmentList[this.currentIndex];
      // 防止进度超出片段时长
      if (this.currentSegmentPlayed >= currentSegment.duration) {
        this.currentSegmentPlayed = currentSegment.duration;
        this.handleSegmentComplete();
        this.clearTimer();
      }
      // 计时器辅助更新（确保极端情况下时间同步）
      this.notifyStateChange();
    }, 10);
  }

  /**
   * 清除计时器
   */
  private clearTimer(): void {
    if (this.playTimer) {
      clearInterval(this.playTimer);
      this.playTimer = null;
    }
  }

  /**
   * 重置播放状态
   */
  private async resetPlayState(): Promise<void> {
    await this.pausePlayback();
    this.currentIndex = -1;
    this.currentSegmentPlayed = 0;
    this.totalPlayDuration = 0;
    this.clearError();
  }

  /**
   * 销毁资源（必须调用）
   */
  async destroy(): Promise<void> {
    this.clearTimer();
    this.resetPlayState();

    // 释放播放器资源
    if (this.activePlayer) {
      try {
        await this.activePlayer.release();
      } catch (err) {
      }
    }
    if (this.standbyPlayer) {
      try {
        await this.standbyPlayer.release();
      } catch (err) {
      }
    }
    if (this.playerA) {
      try {
        await this.playerA.release();
      } catch (err) {
      }
    }
    if (this.playerB) {
      try {
        await this.playerB.release();
      } catch (err) {
      }
    }

    this.playerA = null;
    this.playerB = null;
    this.activePlayer = null;
    this.standbyPlayer = null;
    this.surfaceID = '';
  }

  /**
   * 设置错误信息
   */
  private setError(message: string): void {
    this.errorMessage = message;
    this.notifyStateChange(); // 错误发生时通知状态
  }

  /**
   * 清除错误信息
   */
  private clearError(): void {
    this.errorMessage = '';
    this.notifyStateChange(); // 销毁后通知状态
  }

  // 设置静音
  public setToMuteMode(flag: boolean) {
    this.isMuted = flag
  }
}