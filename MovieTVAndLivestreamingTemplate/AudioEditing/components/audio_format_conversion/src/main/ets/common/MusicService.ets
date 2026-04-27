import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { audio } from '@kit.AudioKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { getMusicModel, MusicModel } from '../viewModel/MusicModelVM';
import { AudioPlayerState } from '../model/MusicData';
import { MediaTools } from 'audio_common';

const DOMAIN = 0x0001;

export class MusicService {
  private static instance: MusicService;
  public avPlayer?: media.AVPlayer;
  private changedData: MusicModel = getMusicModel();
  switchPlayStatus?: (paused: boolean) => void;
  private isPrepared: boolean = false;
  private state: AudioPlayerState = AudioPlayerState.IDLE;

  public static getInstance(): MusicService {
    if (!MusicService.instance) {
      MusicService.instance = new MusicService();
    }
    return MusicService.instance;
  }

  public initAudioPlayer(): Promise<number> {
    return new Promise(async (resole) => {
      media.createAVPlayer()
        .then(avPlayer => {
          if (avPlayer !== null) {
            this.avPlayer = avPlayer;
            this.setAVPlayerCallback();
            resole(1)
          }
        })
        .catch((error: BusinessError) => {
          resole(0)
        });
    })
  }

  private setAVPlayerCallback(): void {
    if (this.avPlayer) {
      this.avPlayer.on('seekDone', this.avPlayerSeekDoneCall);
      this.avPlayer.on('error', this.avPlayerErrorCall);
      this.avPlayer.on('timeUpdate', this.avPlayerTimeUpdateCall);
      this.avPlayer.on('stateChange', this.avPlayerStateChangeCall)
    }
  }

  private avPlayerSeekDoneCall = (seekDoneTime: number) => {

  };
  private avPlayerErrorCall = (error: BusinessError) => {
    this.reset();
  };
  private avPlayerTimeUpdateCall = (updateTime: number) => {

    this.changedData.progress = updateTime;
    this.changedData.currentTime = MediaTools.msToCountdownTime(updateTime);

  };
  // 注册avplayer回调函数
  private avPlayerStateChangeCall = async (state: string) => {

    switch (state) {
      case 'idle': // 成功调用reset接口后触发该状态机上报
        this.state = AudioPlayerState.IDLE;
        this.isPrepared = false;
        break;
      case 'initialized': // avplayer 设置播放源后触发该状态上报
        if (this.avPlayer) {
          this.avPlayer.audioRendererInfo = {
            usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
            rendererFlags: 0
          };
        }
        this.avPlayer?.prepare().catch(() => {

        });
        break;
      case 'prepared': // prepare调用成功后上报该状态机
        this.state = AudioPlayerState.PREPARED;
        this.isPrepared = true;
        this.setCallBackData(true);
        break;
      case 'playing': // play成功调用后触发该状态机上报
        if (this.switchPlayStatus) {
          this.switchPlayStatus(false);
        }
        this.state = AudioPlayerState.PLAY;

        break;
      case 'paused': // pause成功调用后触发该状态机上报
        if (this.switchPlayStatus) {
          this.switchPlayStatus(true);
        }
        this.state = AudioPlayerState.PAUSE;
        break;
      case 'completed': // 播放结束后触发该状态机上报
        if (this.switchPlayStatus) {
          this.switchPlayStatus(true);
        }
        this.state = AudioPlayerState.COMPLETED;
        break;
      case 'stopped': // stop接口成功调用后触发该状态机上报
        this.state = AudioPlayerState.STOP;
        break;
      case 'released':
        this.state = AudioPlayerState.RELEASED;
        break;
      default:
        this.state = AudioPlayerState.UNKNOWN;
        break;
    }


  }

  private setCallBackData(isPlay: boolean): void {

    this.changedData.totalTime = MediaTools.msToCountdownTime(this.getDuration());
    this.changedData.progressMax = this.getDuration();
    this.changedData.fileSize = this.getFileSize(this.changedData.currentUrl)


  }

  private getFileSize(filePath: string): number {
    let size: number = 0
    try {
      size = fs.statSync(filePath).size;
    } catch (error) {

    }

    return size;
  }

  private reset(): void {
    this.avPlayer?.reset().then(() => {

    }).catch((error: BusinessError) => {
    });
  }

  private prepare() {
    this.avPlayer?.prepare().then(() => {

    }).catch((error: BusinessError) => {
    });
  }

  async stop() {
    if (this.avPlayer) {
      this.avPlayer.stop();
    }
  }

  async setSpeed(speedValue: number) {
    if (this.avPlayer) {
      this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_75_X);
    }
  }

  async setSpeedDone() {
    if (this.avPlayer) {
      this.avPlayer.on('speedDone', (speed: number) => {
      });
    }

  }

  async release() {
    if (this.avPlayer) {
      await this.stop();
      this.changedData.progress = 0;
      this.changedData.currentTime = '00:00';
      this.changedData.fileSize = 0

    }
  }

  async setUrl(uri: string): Promise<void> {
    this.changedData.currentUrl = uri
    if (this.avPlayer) {
      this.avPlayer.reset().catch(() => {

      });
      let fdPath = 'fd://';
      let file: fs.File | undefined = undefined
      // 打开相应的资源文件地址获取 fd，并为 url 赋值触发 initialized 状态机上报
      try {
        file = fs.openSync(uri);
        fdPath += file.fd;
        this.avPlayer.url = fdPath;
      }catch (e) {
        fs.closeSync(file)
      }finally {
        fs.closeSync(file)
      }
    }
  }


  private getCurrentTime(): number {
    if (this.isPrepared && this.avPlayer) {
      return this.avPlayer.currentTime;
    }
    return 0;
  }

  private getDuration(): number {
    if (this.isPrepared && this.avPlayer) {
      return this.avPlayer.duration;
    }
    return 0;
  }

  public seek(ms: number): void {
    if (this.isPrepared && this.state !== AudioPlayerState.ERROR && this.avPlayer) {

      let seekMode = this.getCurrentTime() < ms ? 0 : 1;
      let realTime = (ms <= 0 ? 0 : (ms >= this.getDuration() ? this.getDuration() : ms));
      this.avPlayer.seek(realTime, seekMode);
    }
  }
}
