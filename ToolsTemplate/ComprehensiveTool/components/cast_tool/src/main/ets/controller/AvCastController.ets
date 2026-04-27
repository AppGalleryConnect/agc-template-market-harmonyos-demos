import avSession from '@ohos.multimedia.avsession';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { AvSessionController } from './AvSessionController';
import { CommonConstants } from '../constant/CommonConstants';
import { CastSessionListener, CastStatusModel } from '../model/Index';
import { CastService } from '../service/CastService';


const TAG = '[AvCastController]';


@ObservedV2
export class AvCastController {
  castController: avSession.AVCastController | undefined = undefined;
  castListener?: CastSessionListener;
  castItem?: avSession.AVQueueItem;
  maxVolume: number = 0;
  castServiceModule: CastStatusModel = CastService.getInstance().castStatusModel;
  private curVolume: number = 0;
  private reloadCasting = async () => {
    this.castItem!.description!.startPosition = 0;
    this.prepare();
    this.castServiceModule.isCastPlaying = true;
  };

  constructor(castController: avSession.AVCastController) {
    this.castController = castController;
  }

  public registerCastListener(castListener: CastSessionListener) {
    this.castListener = castListener;
  }

  public unregisterCastListener() {
    this.castListener = undefined;
  }

  public async startCasting(castItem: avSession.AVQueueItem) {
    this.castItem = castItem;
    this.castController = await AvSessionController.getInstance().getAvSession()?.getAVCastController();
    this.setPlaybackStateChangeListener();
    this.prepare();
    this.castServiceModule.isCasting = true;
    this.castServiceModule.isCastPlaying = true;
  }

  public endCasting() {
    AvSessionController.getInstance().getAvSession()?.stopCasting();
    this.stopCast();
    this.castServiceModule.isCasting = false;
    this.castServiceModule.isCastPlaying = false;
  }

  public seekCasting(seekTime: number) {
    this.castController?.sendControlCommand({ command: 'seek', parameter: seekTime });
  }

  public async stopCast() {
    try {
      this.castController?.off('playbackStateChange');
      this.castController?.off('endOfStream');
      this.castController?.off('playNext');
      this.castController?.off('playPrevious');
    } catch (error) {
      Logger.error(TAG, `Failed to setAVCastController. code: ${error.code}, message: ${error.message}`);
    }
  }

  public castPlayNextCallback = (): void => {
    this.castListener?.onPlayNext();
  };
  public castPlayPreviousCallback = (): void => {
    this.castListener?.onPlayPre();
  };

  public setVolume(value: number) {
    let avCommand: avSession.AVCastControlCommand = {
      command: 'setVolume',
      parameter: value,
    };
    this.castController?.sendControlCommand(avCommand);
  }

  public setVolumeByOffset(value: number) {
    value = value * Math.ceil(100 / this.maxVolume) + value;
    this.curVolume = this.curVolume + value;
    if (this.curVolume < 0) {
      this.curVolume = 0;
    }
    if (this.curVolume > 100) {
      this.curVolume = 100;
    }
    let avCommand: avSession.AVCastControlCommand = {
      command: 'setVolume',
      parameter: this.curVolume,
    };
    this.castController?.sendControlCommand(avCommand);
  }

  public async play() {
    let avCommand: avSession.AVCastControlCommand = {
      command: 'play',
    };
    await this.castController?.sendControlCommand(avCommand);
  }

  public pause() {
    let avCommand: avSession.AVCastControlCommand = {
      command: 'pause',
    };
    this.castController?.sendControlCommand(avCommand);
  }

  private setPlaybackStateChangeListener(): void {
    this.castController?.on('playbackStateChange', 'all', this.castPlaybackStateChangeListener);
    this.castController?.on('endOfStream', this.reloadCasting);
    this.castController?.on('playNext', this.castPlayNextCallback);
    this.castController?.on('playPrevious', this.castPlayPreviousCallback);
  }

  private async prepare() {
    await this.castController?.prepare(this.castItem);
    await this.castController?.start(this.castItem);
  }

  private castPlaybackStateChangeListener = (playbackState: avSession.AVPlaybackState) => {
    const duration = playbackState?.extras?.duration;
    if (typeof duration === 'number') {
      this.castServiceModule.castDuration = duration as number;
    }

    if (typeof playbackState?.position?.elapsedTime !== 'undefined') {
      this.castServiceModule.castCurrentTime = playbackState?.position?.elapsedTime;
    }
    if (playbackState.extras?.maxCastVolume) {
      this.maxVolume = playbackState.extras?.maxCastVolume as number;
      this.castServiceModule.castMaxVolume = this.maxVolume;
    }
    if (playbackState.state === CommonConstants.PLAYBACK_STATE_PAUSE ||
      playbackState.state === CommonConstants.PLAYBACK_STATE_STOP ||
      playbackState.state === CommonConstants.PLAYBACK_STATE_PREPARE ||
      playbackState.state === CommonConstants.PLAYBACK_STATE_INITIAL) {
      this.castServiceModule.isCastPlaying = false;
    }

    if (playbackState.state === CommonConstants.PLAYBACK_STATE_PLAY) {
      this.castServiceModule.isCastPlaying = true;
    }

    if (playbackState?.volume) {
      this.curVolume = playbackState?.volume;
      this.castServiceModule.castVolume = playbackState?.volume;
    }
  };
}