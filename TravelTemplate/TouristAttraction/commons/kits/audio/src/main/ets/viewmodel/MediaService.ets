import { media } from '@kit.MediaKit';
import wantAgent from '@ohos.app.ability.wantAgent';
import { avSession } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from 'common';
import { AudioPlayerState } from '../model/MusicData';
import { MediaTools } from '../utils/MediaTools';
import { BackgroundUtil } from '../utils/BackgroundUtil';
import { AppStorageV2 } from '@kit.ArkUI';
import { PlayInfo } from '../model/PlayInfo';
import { common } from '@kit.AbilityKit';

const TAG = 'MediaService';

export class MediaService {
  private playInfo: PlayInfo = AppStorageV2.connect(PlayInfo, 'playInfo', () => new PlayInfo())!;
  private static instance: MediaService | null;
  private context: common.UIAbilityContext = AppStorage.get('context')!;
  public avPlayer?: media.AVPlayer;
  private session?: avSession.AVSession;
  private state: AudioPlayerState = AudioPlayerState.IDLE;
  private isPrepared: boolean = false;
  private isCurrent: boolean = true;

  constructor() {
    this.initAudioPlayer();
  }

  private initAudioPlayer() {
    media.createAVPlayer().then(async avPlayer => {
      if (avPlayer !== null) {
        this.avPlayer = avPlayer;
        this.setAVPlayerCallback();
        this.createSession();
      }
    }).catch((error: BusinessError) => {
      Logger.error(TAG, 'this avPlayer: ', `catch error happened,error code is ${error.code}`);
    });
  }

  async createSession() {
    if (!this.context) {
      return;
    }
    this.session = await avSession.createAVSession(this.context, 'SESSION_NAME', 'audio');
    this.session.activate();
    Logger.info(TAG, `session create done : sessionId : ${this.session.sessionId}`);
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: this.context.abilityInfo.bundleName,
          abilityName: this.context.abilityInfo.name,
        },
      ],
      requestCode: 0,
    };
    wantAgent.getWantAgent(wantAgentInfo).then((agent) => {
      if (this.session) {
        this.session.setLaunchAbility(agent);
      }
    });
    this.setListenerForMesFromController();
  }

  async setListenerForMesFromController() {
    if (!this.session) {
      return;
    }
    this.session.on('play', this.playCall);
    this.session.on('pause', this.pauseCall);
  }

  private playCall: () => void = () => {
    Logger.info(TAG, `on play , do play task`);
    this.play(this.playInfo.url);
  };
  private pauseCall: () => void = () => {
    Logger.info(TAG, `on pause , do pause task`);
    this.pause();
  };

  public async play(url: string) {
    Logger.info(TAG, 'AVPlayer play() isPrepared:' + this.isPrepared + ', state:' + this.state);
    BackgroundUtil.startContinuousTask(this.context);
    if (this.avPlayer) {
      this.updateMusicUrl(url);
      this.avPlayer.url = url;
    }
  }

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

  public pause() {
    Logger.info(TAG, 'AVPlayer pause() isPrepared:' + this.isPrepared + ', state:' + this.state);
    if (this.isPrepared && this.state === AudioPlayerState.PLAY && this.avPlayer) {
      this.avPlayer.reset().then(() => {
        this.updateIsPlay(false);
      });
    }
  }

  public unregisterSessionListener() {
    this.session?.off('play');
    this.session?.off('pause');
  }

  public async stop() {
    Logger.info(TAG, 'stop()');
    if (this.isPrepared && this.avPlayer) {
      this.avPlayer.stop().then(() => {
        this.updateIsPlay(false);
        this.state = AudioPlayerState.STOP;
      });
    }
  }

  private updateIsPlay(isPlay: boolean) {
    this.playInfo.isPlay = isPlay;
    AppStorage.setOrCreate<AudioPlayerState>('audioPlayerState',
      isPlay ? AudioPlayerState.PLAY : AudioPlayerState.STOP);
  }

  private updateMusicUrl(url: string) {
    Logger.info(TAG, 'update audio url ===> ' + url);
    this.playInfo.url = url;
    Logger.info(TAG, 'this.session !== undefined ===> ' + (this.session !== undefined));
  }

  private getDuration() {
    if (this.isPrepared && this.avPlayer) {
      return this.avPlayer.duration === -1 ? 0 : this.avPlayer.duration;
    }
    return 0;
  }

  private setAVPlayerCallback() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.on('seekDone', this.seekCall);
    this.avPlayer.on('error', this.errorCall);
    this.avPlayer.on('timeUpdate', this.updateTimeCall);
    this.avPlayer.on('stateChange', this.stateCall);
  }

  private seekCall: (seekDoneTime: number) => void = (seekDoneTime: number) => {
    this.isCurrent = true;
    Logger.info(TAG, `AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
  };
  private errorCall: (err: BusinessError) => void = (err: BusinessError) => {
    Logger.error(TAG, `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
    this.avPlayer?.reset();
  };
  private updateTimeCall: (updateTime: number) => void = (updateTime: number) => {
    if (this.isCurrent) {
      this.playInfo.currentTime = MediaTools.msToCountdownTime(updateTime);
      this.playInfo.progress = updateTime;
    }
  };
  private stateCall: (state: string) => Promise<void> = async (state: string) => {
    switch (state) {
      case 'idle':
        Logger.info(TAG, 'AVPlayer state idle called.');
        this.state = AudioPlayerState.IDLE;
        break;
      case 'initialized':
        Logger.info(TAG, 'AVPlayer state initialized called.');
        this.state = AudioPlayerState.INITIALIZED;
        if (this.avPlayer) {
          this.avPlayer.prepare().then(() => {
            Logger.info(TAG, 'AVPlayer prepare succeeded.');
          }, (err: BusinessError) => {
            Logger.error(TAG, `Invoke prepare failed, code is ${err.code}, message is ${err.message}`);
          });
        }
        break;
      case 'prepared':
        Logger.info(TAG, 'AVPlayer state prepared called.');
        this.state = AudioPlayerState.PREPARED;
        this.isPrepared = true;
        this.playInfo.totalTime = MediaTools.msToCountdownTime(this.getDuration());
        this.playInfo.progressMax = this.getDuration();
        if (this.avPlayer) {
          this.avPlayer.play();
        }
        Logger.info(TAG, 'AVPlayer prepared succeeded.');
        break;
      case 'playing':
        Logger.info(TAG, 'AVPlayer state playing called.');
        this.state = AudioPlayerState.PLAY;
        break;
      case 'paused':
        Logger.info(TAG, 'AVPlayer state paused called.');
        this.state = AudioPlayerState.PAUSE;
        break;
      case 'completed':
        Logger.info(TAG, 'AVPlayer state completed called.');
        this.state = AudioPlayerState.COMPLETED;
        break;
      case 'stopped':
        Logger.info(TAG, 'AVPlayer state stopped called.');
        this.state = AudioPlayerState.STOP;
        if (this.avPlayer) {
          this.avPlayer.reset();
        }
        break;
      case 'released':
        Logger.info(TAG, 'AVPlayer state released called.');
        this.state = AudioPlayerState.RELEASED;
        break;
      default:
        Logger.info(TAG, 'AVPlayer state unknown called.');
        this.state = AudioPlayerState.UNKNOWN;
        break;
    }
    this.updateIsPlay(this.state === AudioPlayerState.PLAY);
  };

  public releaseAvPlayer() {
    // 返回或跳转清空进度
    this.playInfo.progress = 0;
    this.playInfo.currentTime = '00:00';
    this.playInfo.totalTime = '00:00';
    if (AppStorage.get('audioPlayerState') === AudioPlayerState.PLAY) {
      if (this.avPlayer) {
        this.avPlayer.reset(() => {
          MediaService.instance = null;
          this.updateIsPlay(false);
        });
      }
    }
  }

  public static getInstance(): MediaService {
    if (!MediaService.instance) {
      MediaService.instance = new MediaService();
    }
    return MediaService.instance;
  }
}