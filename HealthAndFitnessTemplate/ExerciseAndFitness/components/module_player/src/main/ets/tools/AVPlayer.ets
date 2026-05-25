import { audio } from '@kit.AudioKit';
import { media } from '@kit.MediaKit';
import { COURSE_CONTENT, COURSE_DATA1, Record, ExerciseRecord, ExerciseDays } from 'lib_common';
import { UIContext, AppStorageV2, App  } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';

// AVPlayer的状态机
enum AVPlayerState {
  IDLE = 'idle',
  INITIALIZED = 'initialized',
  PREPARED = 'prepared',
  PLAYING = 'playing',
  PAUSED = 'paused',
  COMPLETED = 'completed',
  STOPPED = 'stopped',
  RELEASED = 'released',
  ERROR = 'error'
}

// AVPlayer 类用于处理视频播放相关的逻辑。
@ObservedV2
export class AVPlayer {
  callbackComplete: () => void = () => {
  };
  callbackTimeUpdate: (nol: number, total: number) => void = (nol: number) => {
  };
  callbackBitrateUpdate: (bitrateList: number[]) => void = (bitrateList: number[]) => {
  };
  callbackErrorUpdate: (error: string) => void = (error: string) => {
  };
  @Trace currentTime: number = 0;
  @Trace totalDuration: number = 0;
  @Trace isPlaying: boolean = false;
  @Trace isLoading: boolean = true;
  @Trace isLoadError: boolean = false;
  // surfaceID用于播放画面显示，具体的值需要通过XComponent接口获取，相关文档链接见上面XComponent创建方法
  surfaceID: string = '';
  // 画中画是否开启
  isPipOpen: boolean = false;
  // 复原
  isPiPWindowRestore: boolean = false;
  avPlayer: media.AVPlayer = {} as media.AVPlayer;
  isCreate: boolean = false;
  seekTime: number = 0;
  // 碰到特殊场景进入其他页时，即便加载成功也不需要播放
  isResetPause: boolean = false;
  courseId: string = '';

  showEndDialog(context: UIContext) {
    context.showAlertDialog({
      title: '恭喜你！',
      message: '已完成本次训练课程',
      alignment: DialogAlignment.Center,
      confirm: {
        value: '确定',
        fontColor: Color.White,        // 字体颜色
        backgroundColor: $r('app.color.app_theme'),    // 背景颜色
        action: () => { }
      }
    });
  }

  async init(context: UIContext, courseId: string, url: string, seekTime: number): Promise<void> {
    await this.release();
    // 创建avPlayer实例对象
    try {
      this.avPlayer = await media.createAVPlayer();
      this.courseId = courseId;
      // 创建状态机变化回调函数
      await this.setStateChangeCallback(context);
      await this.setSourceInfoCallback();
      this.isCreate = true;
      this.isResetPause = false;
      this.avPlayer.url = url;
      this.isLoading = true;
      this.seekTime = seekTime;
    } catch (e) {
      console.error(`Failed to create av player. error: ${JSON.stringify(e)}`)
    }
  }

  getPlay() {
    if (this.avPlayer) {
      try {
        this.avPlayer.play();
      } catch (e) {
        console.error('avPlayer play failed')
      }
    }
  }

  getPause() {
    if (this.avPlayer) {
      try {
        this.avPlayer.pause();
      } catch (e) {
        console.error('avPlayer pause failed')
      }
    }
  }

  getStop() {
    if (this.avPlayer) {
      try {
        this.avPlayer.stop();
      } catch (e) {
        console.error('avPlayer stop failed')
      }
    }
  }

  changeVolume(volume: number) {
    if (this.avPlayer) {
      this.avPlayer.setVolume(volume)
    }
  }

  changeSpeed(speed: number) {
    if (this.avPlayer) {
      this.avPlayer.setSpeed(speed)
    }
  }

  changeSeek(seekTime: number, mode: SliderChangeMode) {
    if (this.avPlayer) {
      this.avPlayer.seek(seekTime, 2);
    }
  }

  setSurfaceId(surfaceId: string): void {
    if (this.avPlayer.surfaceId === surfaceId) {
      return
    }
    this.surfaceID = surfaceId
    this.avPlayer.surfaceId = this.surfaceID;
  }

  // 切换播放
  async changePlay(url: string, seekTime: number) {
    if (this.avPlayer) {
      setTimeout(() => {
        this.isLoadError = false
      }, 1000)
      this.isPlaying = false
      this.isLoading = true
      this.isResetPause = false;
      try {
        await this.avPlayer.reset()
      } catch (e) {
        console.error('reset failed')
      }
      this.totalDuration = 0
      this.seekTime = seekTime
      this.avPlayer.url = url
    }
  }

  setCompleteCallback(func: () => void) {
    this.callbackComplete = func;
    this.isPlaying = false
  }

  setTimeUpdateCallback(func: (nol: number, total: number) => void) {
    this.callbackTimeUpdate = func;
  }

  setBitrateUpdateCallback(func: (bitrateList: number[]) => void) {
    this.callbackBitrateUpdate = func;
  }

  setErrorCallback(func: (error: string) => void) {
    this.callbackErrorUpdate = func;
  }

  // 资源释放
  async release() {
    if (this.isCreate) {
      this.isCreate = false;
      this.isPlaying = false;
      this.isLoading = false;
      this.isLoadError = false;
      this.isResetPause = false;
      try {
        await this.avPlayer.release();
      } catch (e) {
        console.error('avPlayer release failed')
      }
    }
  }

  // 视频信息上报函数
  async setSourceInfoCallback(): Promise<void> {
    // 时间上报函数
    this.avPlayer.on('timeUpdate', (time: number) => {
      this.currentTime = time
      this.callbackTimeUpdate(time, this.totalDuration);
    });
    // 音量变化回调函数
    this.avPlayer.on('volumeChange', (vol: number) => {
    });
    // 视频播放结束触发回调
    this.avPlayer.on('endOfStream', () => {
    });
    // seek操作回调函数
    this.avPlayer.on('seekDone', (seekDoneTime: number) => {
    });
    // 视频总时长上报函数
    this.avPlayer.on('durationUpdate', (duration: number) => {
    });
    // 设置倍速播放回调函数
    this.avPlayer.on('speedDone', (speed: number) => {
    });
    // bitrate设置成功回调函数
    this.avPlayer.on('bitrateDone', (bitrate: number) => {
    });
    // 缓冲上报回调函数
    this.avPlayer.on('bufferingUpdate', (infoType: media.BufferingInfoType, value: number) => {
    });
    // 首帧上报回调函数
    this.avPlayer.on('startRenderFrame', () => {
    });
    // 视频宽高上报回调函数
    this.avPlayer.on('videoSizeChange', (width: number, height: number) => {
    });
    // 焦点上报回调函数
    this.avPlayer.on('audioInterrupt', (info: audio.InterruptEvent) => {
    });
    // HLS上报所有支持的比特率
    this.avPlayer.on('availableBitrates', (bitrates: number[]) => {
      this.callbackBitrateUpdate(bitrates);
    });
    // 设置错误监听
    this.avPlayer.on('error', (error) => {
      this.callbackErrorUpdate('Error ' + error.code + ' - ' + error.message);
    });
  }

  // 状态机
  async setStateChangeCallback(context: UIContext): Promise<void> {
    this.avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      if (this.avPlayer == null) {
        return;
      }
      switch (state) {
        // 闲置状态,成功调用reset接口后触发该状态机上报
        case AVPlayerState.IDLE:
          this.isLoadError = false
          break;
        // 资源初始化，avplayer设置播放源后触发该状态上报
        case AVPlayerState.INITIALIZED:
          if (this.surfaceID) {
            this.setSurfaceId(this.surfaceID); // 设置显示画面，当播放的资源为纯音频时无需设置
            try {
              this.avPlayer.prepare();
            } catch (e) {
              console.error('avPlayer prepare failed')
            }
          }
          break;
        // 已准备状态
        case AVPlayerState.PREPARED:
          this.avPlayer.audioInterruptMode = audio.InterruptMode.INDEPENDENT_MODE;
          this.totalDuration = this.avPlayer.duration;
          this.currentTime = this.totalDuration * this.seekTime / 100
          this.avPlayer.seek(this.currentTime, 2);
          if (this.isResetPause) {
            this.isPlaying = false;
            try {
              this.avPlayer.pause();
            } catch (e) {
              console.error('avPlayer play failed')
            }
          }else {
            this.isPlaying = true;
            try {
              this.avPlayer.play();
            } catch (e) {
              console.error('avPlayer play failed')
            }
          }
          this.changeSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_00_X)
          this.isLoadError = false;
          break;
        // 正在播放状态
        case AVPlayerState.PLAYING:
          this.isLoading = false;
          this.isPlaying = true;
          break;
        // 暂停状态
        case AVPlayerState.PAUSED:
          this.isLoading = false;
          this.isPlaying = false;
          break;
        // 播放至结尾状态
        case AVPlayerState.COMPLETED:
          this.isPlaying = false
          this.showEndDialog(context)
          this.callbackComplete();
          break;
        // 停止状态
        case AVPlayerState.STOPPED:
          break;
        // 销毁状态，销毁与当前AVPlayer关联的播放引擎，无法再进行状态转换
        case AVPlayerState.RELEASED:
          this.isLoading = true;
          break;
        // 错误状态，当播放引擎发生不可逆的错误，则会转换至当前状态
        case AVPlayerState.ERROR:
          setTimeout(() => {
            this.isPlaying = false;
            this.isLoading = false;
            this.isLoadError = true;
          }, 1000)
          break;
        default:
          break;
      }
    })
  }
}