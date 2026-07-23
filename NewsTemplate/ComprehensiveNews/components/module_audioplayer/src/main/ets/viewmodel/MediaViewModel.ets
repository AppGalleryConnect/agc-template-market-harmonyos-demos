import { AppStorageV2, window } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { common, wantAgent } from '@kit.AbilityKit';
import { avSession } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { AudioItem, AudioPlayerState, AudioPlayMode } from '../model/AudioData';
import { ControlStateModel } from '../model/ControlStateModel';
import { BackgroundUtils } from '../utils/BackgroundUtils';
import { AudioUtils } from '../utils/AudioUtils';

const TAG = '[MediaViewModel]';

@ObservedV2
export class MediaViewModel {
  @Trace state: AudioPlayerState = AudioPlayerState.IDLE;
  @Trace isFirst: boolean = true;
  @Trace audioIndex: number = 0;
  @Trace playingId: string = '-1';
  @Trace audioList: AudioItem[] = [];
  @Trace controlState: ControlStateModel =
    AppStorageV2.connect<ControlStateModel>(ControlStateModel, () => new ControlStateModel())!;
  @Trace albumId: string = '-1'
  @Trace loadAudio: boolean = false
  static windowStage: window.WindowStage | undefined
  private isCurrent: boolean = true;
  private isNeedPlay: boolean = true;
  private isPrepared: boolean = false;
  private context: common.UIAbilityContext | undefined = undefined;
  private session?: avSession.AVSession;
  private playMode: AudioPlayMode = AudioPlayMode.ORDER;
  static instance: MediaViewModel | null;
  public avPlayer?: media.AVPlayer;

  @Computed
  get isPlaying() {
    return this.state === AudioPlayerState.PLAY
  }

  @Computed
  get isIdle() {
    return this.state === AudioPlayerState.IDLE
  }

  @Computed
  get isPause() {
    return this.state === AudioPlayerState.PAUSE
  }

  private seekCall: (seekDoneTime: number) => void = (seekDoneTime: number) => {
    this.isCurrent = true;
    UtilLog.info(TAG, `AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    this.setPlayState({
      position: {
        elapsedTime: this.getCurrentTime(),
        updateTime: new Date().getTime(),
      },
    });
  };
  private errorCall: (err: BusinessError) => void = (err: BusinessError) => {
    UtilLog.error(TAG, `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
    this.avPlayer?.reset().catch((e: BusinessError) => {
      UtilLog.error(TAG, 'reset fail, error: ' + JSON.stringify(e));
    });
  };
  private updateTimeCall: (updateTime: number) => void = (updateTime: number) => {
    if (this.isCurrent) {
      this.controlState.currentTime = AudioUtils.msToCountdownTime(updateTime)
      this.controlState.progress = updateTime
    }
  };
  private stateCall: (state: string) => Promise<void> = async (state: string) => {
    switch (state) {
      case 'idle':
        UtilLog.info(TAG, 'AVPlayer state idle called.');
        this.state = AudioPlayerState.IDLE;
        let url = this.audioList[this.audioIndex].src;
        this.resetControlState()
        if (this.avPlayer && url) {
          this.avPlayer.url = url;
          UtilLog.info(TAG, 'loadAsset avPlayer.url:' + this.avPlayer.fdSrc);
        }
        break;
      case 'initialized':
        UtilLog.info(TAG, 'AVPlayer state initialized called.');
        this.state = AudioPlayerState.INITIALIZED;
        if (this.avPlayer) {
          this.avPlayer.prepare().then(() => {
            UtilLog.info(TAG, 'AVPlayer prepare succeeded.');
          }).catch((err: BusinessError) => {
            UtilLog.error(TAG, `Invoke prepare failed, code is ${err.code}, message is ${err.message}`);
          });
        }
        break;
      case 'prepared':
        UtilLog.info(TAG, 'AVPlayer state prepared called.');
        this.state = AudioPlayerState.PREPARED;
        this.isPrepared = true;
        this.controlState.totalTime = AudioUtils.msToCountdownTime(this.getDuration())
        this.controlState.progressMax = this.getDuration()
        if (this.avPlayer && this.isNeedPlay) {
          this.avPlayer.play().then(() => {
            this.createSession();
          }).catch((e: BusinessError) => {
            UtilLog.error(TAG, 'play fail, error: ' + JSON.stringify(e));
          });
        }
        this.isNeedPlay = true;
        UtilLog.info(TAG, 'AVPlayer prepared succeeded.');
        break;
      case 'playing':
        UtilLog.info(TAG, 'AVPlayer state playing called.');
        this.state = AudioPlayerState.PLAY;
        this.loadAudio = false
        break;
      case 'paused':
        UtilLog.info(TAG, 'AVPlayer state paused called.');
        this.state = AudioPlayerState.PAUSE;
        break;
      case 'completed':
        UtilLog.info(TAG, 'AVPlayer state completed called.');
        this.state = AudioPlayerState.COMPLETED;
        this.playNext(true);
        break;
      case 'stopped':
        UtilLog.info(TAG, 'AVPlayer state stopped called.');
        this.state = AudioPlayerState.STOP;
        if (this.avPlayer) {
          this.avPlayer.reset().catch((e: BusinessError) => {
            UtilLog.error(TAG, 'reset fail, error: ' + JSON.stringify(e));
          });
        }
        break;
      case 'released':
        UtilLog.info(TAG, 'AVPlayer state released called.');
        this.state = AudioPlayerState.RELEASED;
        break;
      default:
        UtilLog.info(TAG, 'AVPlayer state unknown called.');
        this.state = AudioPlayerState.UNKNOWN;
        break;
    }
    this.updateIsPlay(this.state === AudioPlayerState.PLAY);
  };
  private playCall: () => void = () => {
    UtilLog.info(TAG, `on play , do play task`);
    if (this.isFirst) {
      this.loadAssent(0);
    } else {
      this.play();
    }
  };
  private pauseCall: () => void = () => {
    UtilLog.info(TAG, `on pause , do pause task`);
    this.pause();
  };
  private playNextCall: () => void = () => {
    UtilLog.info(TAG, `on playNext , do playNext task`);
    this.playNext();
  };
  private playPreviousCall: () => void = () => {
    UtilLog.info(TAG, `on playPrevious , do playPrevious task`);
    this.playPrevious();
  };
  private volumeChangeCall: (volume: number) => void = (volume: number) => {
    UtilLog.info(TAG, `on volumeChangeCall, do volumeChange task`);
    AppStorage.setOrCreate('volume', volume);
  };

  private resetControlState() {
    this.controlState.currentTime = '00:00'
    this.controlState.totalTime = '00:00'
    this.controlState.progress = 0
  }

  async initAudioList(context: common.UIAbilityContext) {
    await this.initAudioPlayer(context);
  }

  setAlbumIdId(albumId: string) {
    if (albumId) {
      this.albumId = albumId
    }
  }

  async setAudioList(list: AudioItem[]) {
    if (list) {
      this.audioList = list;
    }
  }

  public static getInstance() {
    if (!MediaViewModel.instance) {
      MediaViewModel.instance = new MediaViewModel();
    }
    return MediaViewModel.instance;
  }

  public getAvplayer() {
    return this.avPlayer
  }

  public static setWindowStage(windowStage: window.WindowStage) {
    MediaViewModel.windowStage = windowStage
  }

  public isSameCurrentPlay(albumId: string) {
    return this.albumId === albumId
  }

  public isSameCurrentPlayWithIndex(albumId: string, playingId: string) {
    return this.albumId === albumId &&
      playingId === MediaViewModel.getInstance().playingId
  }

  private async initAudioPlayer(context: common.UIAbilityContext) {
    this.context = context
    try {
      let avPlayer = await media.createAVPlayer()
      if (avPlayer !== null) {
        this.avPlayer = avPlayer;
        this.setAVPlayerCallback();
      }
    } catch (e) {
      UtilLog.error(TAG, 'this avPlayer: ', `catch error happened,error code is ${e.code}`);
    }
  }

  private setAVPlayerCallback() {
    if (!this.avPlayer) {
      return;
    }
    try {
      this.avPlayer.on('seekDone', this.seekCall);

      this.avPlayer.on('error', this.errorCall);

      this.avPlayer.on('timeUpdate', this.updateTimeCall);

      this.avPlayer.on('stateChange', this.stateCall);

      this.avPlayer.on('volumeChange', this.volumeChangeCall);
    } catch (e) {
      UtilLog.error(TAG, 'register avPlayer fail, error: ' + JSON.stringify(e));
    }
  }

  setLaunchAbility() {
    if (!this.context) {
      return;
    }
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: this.context.abilityInfo.bundleName,
          abilityName: this.context.abilityInfo.name,
        },
      ],
      actionType: wantAgent.OperationType.START_ABILITIES,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG],
    };
    wantAgent.getWantAgent(wantAgentInfo)
      .then((agent) => {
        if (this.session) {
          this.session.setLaunchAbility(agent).catch((e: BusinessError) => {
            UtilLog.error(TAG, 'setLaunchAbility fail, error: ' + JSON.stringify(e));
          });
        }
      }).catch((err: BusinessError) => {
      UtilLog.error(TAG,
        `getWantAgent failed, code: ${JSON.stringify(err.code)}, message: ${JSON.stringify(err.message)}`);
    });
  }

  async createSession() {
    if (!this.context) {
      return;
    }
    try {
      const session: avSession.AVSession = AppStorage.get('avSession') as avSession.AVSession;
      if (session) {
        this.session = session;
        UtilLog.info(TAG, `session exist: sessionId : ${this.session.sessionId}`);
      } else {
        this.session = await avSession.createAVSession(this.context, 'SESSION_AUDIO', 'audio');
        AppStorage.setOrCreate('avSession', this.session);
        BackgroundUtils.startContinuousTask(this.context);
        this.setLaunchAbility();
        UtilLog.info(TAG, `session create done : sessionId : ${this.session.sessionId}`);
      }
      this.setAVMetadata();
      this.updateIsPlay(true);
      this.setListenerForMesFromController();
      this.session.activate().catch((e: BusinessError) => {
        UtilLog.error(TAG, 'activate fail, error: ' + JSON.stringify(e));
      });
    } catch (error) {
      UtilLog.error(TAG, `Failed to createAVSession, code: ${error.code}, message: ${error.message}`);
    }
  }

  async setListenerForMesFromController() {
    if (!this.session) {
      return;
    }
    try {
      this.session.on('play', this.playCall);
      this.session.on('pause', this.pauseCall);
      this.session.on('playNext', this.playNextCall);
      this.session.on('playPrevious', this.playPreviousCall);
    } catch (error) {
      UtilLog.error(TAG, `${error.code} + ${error.message}`);
    }
  }

  async unregisterSessionListener() {
    if (!this.session) {
      return;
    }
    try {
      this.session.off('play');
      this.session.off('pause');
      this.session.off('playNext');
      this.session.off('playPrevious');
    } catch (error) {
      UtilLog.error(TAG, `${error.code} + ${error.message}`);
    }
  }

  async setAVMetadata() {
    let id = this.audioIndex;
    try {
      if (this.context) {
        let mediaImage = this.audioList[this.audioIndex].mark
        UtilLog.info(TAG, 'getPixelMapFromResource success' + JSON.stringify(mediaImage));
        let metadata: avSession.AVMetadata = {
          assetId: `${id}`,
          title: this.audioList[this.audioIndex].title,
          artist: this.audioList[this.audioIndex].description,
          mediaImage: mediaImage,
          duration: this.getDuration(),
        };
        if (this.session) {
          this.session.setAVMetadata(metadata).then(() => {
            UtilLog.info(TAG, 'SetAVMetadata successfully');
          }).catch((err: BusinessError) => {
            UtilLog.error(TAG, `SetAVMetadata BusinessError: code: ${err.code}, message: ${err.message}`);
          });
        }
      }
    } catch (error) {
      UtilLog.error(TAG, `SetAVMetadata try: code: ${(error as BusinessError).code},
       message: ${(error as BusinessError).message}`);
    }
  }

  /**
   * 根据索引播放音频
   * @param audioIndex
   * @param isNeedPlay
   */
  async loadAssent(audioIndex: number, loadOnly?: boolean) {
    if (this.loadAudio) {
      return
    }
    this.loadAudio = true
    if (audioIndex >= this.audioList.length) {
      UtilLog.error(TAG, `current musicIndex ${audioIndex}`);
      return;
    }
    this.updateMusicIndex(audioIndex);
    if (this.isFirst && this.avPlayer) {
      this.isFirst = false;
      let url = this.audioList[audioIndex].src
      if (url) {
        if (loadOnly) {
          this.isNeedPlay = false;
        }
        this.avPlayer.url = url;
      }
    } else {
      await this.stop();
    }
  }

  /**
   * 判断是否第一次加载
   *
   * @returns isFirst
   */
  public getFirst() {
    return this.isFirst;
  }

  /**
   * 设置播放模式
   *
   * @param playMode
   */
  public setPlayModel(playMode: AudioPlayMode) {
    this.playMode = playMode;
    UtilLog.info(TAG, 'setPlayModel mode: ' + this.playMode);
  }


  private updateIsPlay(isPlay: boolean) {
    this.controlState.isPlay = isPlay
    this.setPlayState({
      state: isPlay ? avSession.PlaybackState.PLAYBACK_STATE_PLAY : avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      position: {
        elapsedTime: this.getCurrentTime(),
        updateTime: new Date().getTime(),
      },
    });
  }

  /**
   * 调整音频进度
   *
   * @param ms.
   */
  public seek(ms: number) {
    if (this.isPrepared && this.state !== AudioPlayerState.ERROR && this.avPlayer) {
      let seekMode = this.getCurrentTime() < ms ? 0 : 1;
      let realTime = (ms <= 0 ? 0 : (ms >= this.getDuration() ? this.getDuration() : ms));
      this.isCurrent = false;
      this.avPlayer.seek(realTime, seekMode);
    }
  }

  private getCurrentTime() {
    if (this.isPrepared && this.avPlayer) {
      return this.avPlayer.currentTime;
    }
    return 0;
  }

  private getDuration() {
    if (this.isPrepared && this.avPlayer) {
      return this.avPlayer.duration;
    }
    return 0;
  }

  private start(seekMs?: number) {
    UtilLog.info(TAG, 'AVPlayer play() isPrepared:' + this.isPrepared + ', state:' + this.state + '，seek:' + seekMs);
    if (this.avPlayer) {
      this.avPlayer.prepare().then(() => {
      }).catch((error: BusinessError) => {
        UtilLog.error(TAG, `start error ${JSON.stringify(error)}`);
        this.state = AudioPlayerState.ERROR;
        this.updateIsPlay(false);
        this.isPrepared = false;
      });
    }
  }

  public checkPlayPrevious: (currentIndex: number) => boolean = () => true;
  public checkPlayNext: (currentIndex: number, isAutoNext: boolean) => boolean = () => true;

  /**
   * 播放音频
   */
  public async play() {
    if (this.loadAudio) {
      return
    }
    UtilLog.info(TAG, 'AVPlayer play() isPrepared:' + this.isPrepared + ', state:' + this.state);
    if (!this.isPrepared) {
      this.start(0);
    } else if (this.avPlayer) {
      this.avPlayer.play().then(async () => {
        UtilLog.info(TAG, 'progressTime play() current time:' + this.getCurrentTime());
        this.seek(this.getCurrentTime());
        await this.createSession();
        this.state = AudioPlayerState.PLAY;
      }).catch((e: BusinessError) => {
        UtilLog.error(TAG, 'play fail, error: ' + JSON.stringify(e));
      });
    }
  }

  /**
   * 暂停音频
   */
  public pause() {
    UtilLog.info(TAG, 'AVPlayer pause() isPrepared:' + this.isPrepared + ', state:' + this.state);
    if (this.isPrepared && this.state === AudioPlayerState.PLAY && this.avPlayer) {
      this.avPlayer.pause().then(() => {
        this.state = AudioPlayerState.PAUSE;
        this.updateIsPlay(false);
        if (this.context) {
          BackgroundUtils.stopContinuousTask(this.context);
        }
      }).catch((err: BusinessError) => {
        UtilLog.error(TAG, 'Failed to pause,error message is :' + err.message);
      })
    }
  }

  public playNext(isAutoNext: boolean = false) {
    UtilLog.info(TAG, 'playNext Index:' + this.audioIndex + ', length-1:' + (this.audioList.length - 1));
    const canPlayNext = this.checkPlayNext(this.audioIndex, isAutoNext);
    if (!canPlayNext) {
      return;
    }
    if (this.audioIndex === this.audioList.length - 1) {
      this.loadAssent(0);
    } else {
      this.loadAssent(this.audioIndex + 1);
    }
  }

  /**
   * 播放上一首
   */
  public playPrevious() {
    const canPlayPrevious = this.checkPlayPrevious(this.audioIndex);
    if (!canPlayPrevious) {
      return;
    }
    switch (this.playMode) {
      case AudioPlayMode.ORDER:
      case AudioPlayMode.SINGLE_CYCLE:
        if (this.audioIndex === 0) {
          this.updateMusicIndex(this.audioList.length - 1);
        } else {
          this.updateMusicIndex(this.audioIndex - 1);
        }
        UtilLog.info(TAG, 'setLastIndex:' + this.audioIndex);
        this.loadAssent(this.audioIndex);
        break;
      default:
        break;
    }
  }

  /**
   * 暂停音频
   */
  public async stop() {
    UtilLog.info(TAG, 'stop()');
    if (this.isPrepared && this.avPlayer) {
      try {
        UtilLog.info('this.state', this.state)
        await this.avPlayer.stop();
        this.updateIsPlay(false);
        this.state = AudioPlayerState.PAUSE;
        if (this.context) {
          BackgroundUtils.stopContinuousTask(this.context);
        }
      } catch (error) {
        UtilLog.error(TAG, `${error.code} + ${error.message}`);
      }
    }
  }

  private async reset() {
    UtilLog.info(TAG, 'reset()');
    if (this.avPlayer) {
      try {
        await this.avPlayer.reset();
      } catch (error) {
        UtilLog.error(TAG, `${error.code} + ${error.message}`);
      }
    }
    this.isPrepared = false;
  }

  /**
   * 释放音频
   */
  public release() {
    if (this.avPlayer && this.session && this.context) {
      try {
        this.updateIsPlay(false);
        this.stop();
        this.reset();
        this.avPlayer.release().catch((e: BusinessError) => {
          UtilLog.error(TAG, 'release fail, error: ' + JSON.stringify(e));
        });
        this.state = AudioPlayerState.IDLE;
        BackgroundUtils.stopContinuousTask(this.context);
        this.unregisterSessionListener();
        this.session.destroy((err: BusinessError) => {
          if (err) {
            UtilLog.error(TAG, `Failed to destroy session. Code: ${err.code}, message: ${err.message}`);
          } else {
            UtilLog.info(TAG, `Destroy : SUCCESS `);
          }
        });
      } catch (error) {
        UtilLog.error(TAG, `${error.code} + ${error.message}`);
      }
    }
  }

  private updateMusicIndex(musicIndex: number) {
    AppStorage.setOrCreate('selectIndex', musicIndex);
    this.playingId = this.audioList[musicIndex].audioId
    if (this.audioIndex !== musicIndex) {
      this.audioIndex = musicIndex;
    }
    UtilLog.info(TAG, 'this.session !== undefined ===> ' + (this.session !== undefined));
    if (this.session !== undefined) {
      this.setAVMetadata();
    }
  }

  private async setPlayState(playbackState: avSession.AVPlaybackState) {
    if (this.session) {
      this.session.setAVPlaybackState(playbackState).then(() => {
        UtilLog.info(TAG, 'SetAVPlaybackState successfully');
      }).catch((err: BusinessError) => {
        UtilLog.info(TAG, `SetAVPlaybackState BusinessError: code: ${err.code}, message: ${err.message}`);
      })
    }
  }
}