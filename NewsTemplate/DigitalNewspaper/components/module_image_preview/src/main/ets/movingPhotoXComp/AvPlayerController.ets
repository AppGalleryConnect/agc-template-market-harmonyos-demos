import { media } from '@kit.MediaKit';
import { audio } from '@kit.AudioKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { vibrator } from '@kit.SensorServiceKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { AVPlayerState, AvState } from '../models/AVPlayerState';

const TAG = '[AvPlayerController]';

@ObservedV2
export class AvPlayerController {
  @Trace surfaceID: string = '';
  @Trace videoSrc?: string;
  @Trace playerState: AvState = new AvState()
  private avPlayer?: media.AVPlayer;
  private context: UIContext | undefined = undefined

  constructor(context: UIContext) {
    this.context = context
  }

  setState(playerState: AvState) {
    this.playerState = playerState
  }

  public async initAVPlayer(videoUrl: string, surfaceId: string, avPlayer?: media.AVPlayer) {
    if (!this.context) {
      UtilLog.info(TAG, `initPlayer failed context not set`);
      return
    }
    this.videoSrc = videoUrl;
    if (!this.videoSrc) {
      return;
    }
    this.surfaceID = surfaceId;

    try {
      this.avPlayer = avPlayer ? avPlayer : await media.createAVPlayer()
      this.setAVPlayerCallback();

      if (!this.context) {
        UtilLog.info(TAG, `initPlayer failed context not set`);
        return
      }
      this.avPlayer.url = this.videoSrc;
    } catch (err) {
      UtilLog.error(TAG,
        `initPlayer failed, code is ${err.code}, message is ${err.message}`);
    }
  }


  private setAVPlayerCallback() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer!.on('error', (err: BusinessError) => {
      UtilLog.error(TAG, `AVPlayer error, code is ${err.code}, message is ${err.message}`);
      this.avPlayer!.reset().catch((err: BusinessError) => {
        UtilLog.error(TAG,
          `reset failed, code is ${err.code}, message is ${err.message}`);
      });
    });

    this.avPlayer.on('error', (err: BusinessError) => {
      if (!this.avPlayer) {
        return;
      }
      UtilLog.error(TAG,
        `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      this.avPlayer.reset().catch((err: BusinessError) => {
        UtilLog.error(TAG,
          `reset failed, code is ${err.code}, message is ${err.message}`);
      });
    })
    this.setStateChangeCallback();
  }

  private setStateChangeCallback() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.on('stateChange', async (state) => {
      if (!this.avPlayer) {
        return;
      }
      switch (state) {
        case 'idle':
          UtilLog.info(TAG, 'setAVPlayerCallback AVPlayer state idle called.');
          break;
        case 'initialized':
          this.avPlayer.surfaceId = this.surfaceID;
          this.playerState.avState = AVPlayerState.INITIALIZED
          this.avPlayer.prepare().catch((err: BusinessError) => {
            UtilLog.error(TAG,
              `prepare failed, code is ${err.code}, message is ${err.message}`);
          });
          break;
        case 'prepared':
          this.avPlayer!.audioInterruptMode = audio.InterruptMode.SHARE_MODE;
          this.playerState.avState = AVPlayerState.PREPARED
          break;
        case 'paused':
          this.playerState.avState = AVPlayerState.PAUSED
          break;
        case 'playing':
          this.playerState.avState = AVPlayerState.PLAYING
          break;
        case 'completed':
          this.playerState.avState = AVPlayerState.COMPLETED
          break;
        case 'error':
          UtilLog.info(TAG, 'setAVPlayerCallback AVPlayer state error called.');
          break;
        default:
          UtilLog.info(TAG, 'setAVPlayerCallback AVPlayer state unknown called.');
          break;
      }
    });
  }

  startVibration() {
    try {
      vibrator.startVibration({
        type: 'preset',
        effectId: 'haptic.notice.success',
        count: 1,
      }, {
        usage: 'notification',
      }, (error: BusinessError) => {
        if (error) {
          UtilLog.error(TAG, `Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
          return;
        }
        UtilLog.info(TAG, 'Succeed in starting vibration');
      });
    } catch (error) {
      UtilLog.error(TAG, `Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
    }
  }


  videoPlay(): void {
    if (this.avPlayer) {
      this.avPlayer.play().then(() => {
        this.startVibration()
      }).catch((err: BusinessError) => {
        UtilLog.error(TAG,
          `play failed, code is ${err.code}, message is ${err.message}`);
      });
    }
  }

  async videoStop() {
    if (this.avPlayer) {
      await this.avPlayer.pause()
      this.videoSeek(0)
    }
  }

  videoSeek(seekTime: number): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.seek(seekTime, media.SeekMode.SEEK_CLOSEST);
      } catch (err) {
        UtilLog.error(TAG,
          `videoSeek failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  async videoReset(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }
    try {
      await this.avPlayer.reset();
    } catch (err) {
      UtilLog.error(TAG, `videoReset failed, code is ${err.code}, message is ${err.message}`);
    }

  }

  async videoRelease(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.release((err) => {
      if (err === undefined) {
        UtilLog.info(TAG, 'videoRelease release success');
      } else {
        UtilLog.error(TAG,
          `videoRelease release filed,  code is ${err.code}, message is ${err.message}`);
      }
    });
  }
}