import avSession from '@ohos.multimedia.avsession';
import { AvSessionController } from './AvSessionController';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConstants } from '../common/CommonConstants';
import {  CastSessionListener, CastStatusModel } from '../model/CastStatusModel'

const TAG = '[AvCastController]'
const DOMAIN = 0x000

@ObservedV2
export class AvCastController {
  castController: avSession.AVCastController | undefined = undefined;
  castListener?: CastSessionListener
  castItem?: avSession.AVQueueItem
  private curVolume: number = 0
  maxVolume: number = 0
  castServiceModule: CastStatusModel = CastStatusModel.instance

  public registerCastListener(castListener: CastSessionListener) {
    this.castListener = castListener
  }

  public unregisterCastListener() {
    this.castListener = undefined
  }

  constructor(castController: avSession.AVCastController) {
    this.castController = castController
  }

  public async startCasting(castItem: avSession.AVQueueItem) {
    hilog.debug(DOMAIN, TAG, `startCasting`)
    this.castItem = castItem
    try {
      this.castController = await AvSessionController.getInstance().getAvSession()?.getAVCastController();
    } catch (e) {
      hilog.error(DOMAIN, TAG, `startCasting getAVCastController failed: ${e}`);
    }
    this.setPlaybackStateChangeListener();
    this.prepare();
    this.castServiceModule.isCasting = true
    this.castServiceModule.isCastPlaying = true
    hilog.debug(DOMAIN, TAG, `startCasting end`)
  }

  public endCasting() {
    hilog.debug(DOMAIN, TAG, `endCasting`)
    try {
      AvSessionController.getInstance().getAvSession()?.stopCasting();
    } catch (e) {
      hilog.error(DOMAIN, TAG, `stopCasting failed: ${e}`);
    }
    this.stopCast();
    this.castServiceModule.isCasting = false
    this.castServiceModule.isCastPlaying = false
    hilog.debug(DOMAIN, TAG, `endCasting end`)
  }

  public seekCasting(seekTime: number) {
    hilog.debug(DOMAIN, TAG, `seekCasting`)
    try {
      this.castController?.sendControlCommand({ command: 'seek', parameter: seekTime });
    } catch (e) {
      hilog.error(DOMAIN, TAG, `sendControlCommand failed: ${e}`);
    }
    hilog.debug(DOMAIN, TAG, `seekCasting end`)
  }

  public async stopCast() {
    try {
      this.castController?.off('playbackStateChange');
      this.castController?.off('endOfStream');
      this.castController?.off('playNext');
      this.castController?.off('playPrevious');
      this.castController?.off('error');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to setAVCastController. code: ${error.code}, message: ${error.message}`);
    }
  }

  private setPlaybackStateChangeListener(): void {
    try {
      this.castController?.on('playbackStateChange', 'all', this.castPlaybackStateChangeListener);
      this.castController?.on('endOfStream', this.reloadCasting);
      this.castController?.on('playNext', this.castPlayNextCallback);
      this.castController?.on('playPrevious', this.castPlayPreviousCallback);
      this.castController?.on('error', this.errorCallback);
    } catch (e) {
      hilog.error(DOMAIN, TAG, `setPlaybackStateChangeListener failed: ${e}`);
    }
  }

  private async prepare() {
    try {
      await this.castController?.prepare(this.castItem);
      await this.castController?.start(this.castItem);
    } catch (e) {
      hilog.error(DOMAIN, TAG, `prepare failed: ${e}`);
    }
  }

  private castPlaybackStateChangeListener = (playbackState: avSession.AVPlaybackState) => {
    const duration = playbackState?.extras?.duration;
    if (typeof duration === 'number') {
      // hilog.debug(DOMAIN, TAG, `Casting updateDuration`)
      this.castServiceModule.castDuration = duration as number
    }

    if (typeof playbackState?.position?.elapsedTime !== 'undefined') {
      // hilog.debug(DOMAIN, TAG, `Casting elapsedTime:${playbackState?.position?.elapsedTime}`)
      this.castServiceModule.castCurrentTime = playbackState?.position?.elapsedTime
    }
    if (playbackState.extras?.maxCastVolume) {
      this.maxVolume = playbackState.extras?.maxCastVolume as number
      this.castServiceModule.castMaxVolume = this.maxVolume
      hilog.debug(DOMAIN, TAG, `Casting maxCastVolume ${this.maxVolume}`)
    }
    if (playbackState.state === CommonConstants.PLAYBACK_STATE_PAUSE ||
      playbackState.state === CommonConstants.PLAYBACK_STATE_STOP ||
      playbackState.state === CommonConstants.PLAYBACK_STATE_PREPARE ||
      playbackState.state === CommonConstants.PLAYBACK_STATE_INITIAL) {
      hilog.debug(DOMAIN, TAG, `Casting not playing`)
      this.castServiceModule.isCastPlaying = false
    }

    if (playbackState.state === CommonConstants.PLAYBACK_STATE_PLAY) {
      hilog.debug(DOMAIN, TAG, `Casting playing`)
      this.castServiceModule.isCastPlaying = true
    }

    if (playbackState?.volume) {
      this.curVolume = playbackState?.volume
      this.castServiceModule.castVolume = playbackState?.volume
      hilog.info(DOMAIN, TAG, `Casting Volume:${this.curVolume}`)
    }
  };
  private reloadCasting = async () => {
    this.castItem!.description!.startPosition = 0
    this.prepare();
    this.castServiceModule.isCastPlaying = true
  };
  private castReload = async () => {
  };
  public castPlayNextCallback = (): void => {
    hilog.debug(DOMAIN, TAG, 'castPlayNextCallback')
    this.castListener?.onPlayNext()
  };
  public castPlayPreviousCallback = (): void => {
    hilog.debug(DOMAIN, TAG, 'castPlayPreviousCallback')
    this.castListener?.onPlayPre()
  };

  private errorCallback() {
    // this.castListener?.onError()
  }

  public setVolume(value: number) {
    hilog.debug(DOMAIN, TAG, `setVolume Volume:${value}`)
    let avCommand: avSession.AVCastControlCommand = {
      command: 'setVolume',
      parameter: value
    };
    try {
      this.castController?.sendControlCommand(avCommand);
    } catch (e) {
      hilog.error(DOMAIN, TAG, `setVolume sendControlCommand failed: ${e}`);
    }
    hilog.debug(DOMAIN, TAG, `setVolume Volume:${value} end`)
  }

  public setVolumeByOffset(value: number) {
    hilog.debug(DOMAIN, TAG, `setVolumeByOffset Volume:${value}`)
    value = value * Math.ceil(100 / this.maxVolume) + value
    this.curVolume = this.curVolume + value
    if (this.curVolume < 0) {
      this.curVolume = 0
    }
    if (this.curVolume > 100) {
      this.curVolume = 100
    }
    let avCommand: avSession.AVCastControlCommand = {
      command: 'setVolume',
      parameter: this.curVolume
    };
    try {
      this.castController?.sendControlCommand(avCommand);
    } catch (e) {
      hilog.error(DOMAIN, TAG, `setVolumeByOffset sendControlCommand failed: ${e}`);
    }
    hilog.debug(DOMAIN, TAG, `setVolumeByOffset Volume:${this.curVolume}`)
  }

  public async play() {
    let avCommand: avSession.AVCastControlCommand = {
      command: 'play',
    };
    try {
      await this.castController?.sendControlCommand(avCommand);
    } catch (e) {
      hilog.error(DOMAIN, TAG, `play sendControlCommand failed: ${e}`);
    }
  }

  public pause() {
    let avCommand: avSession.AVCastControlCommand = {
      command: 'pause',
    };
    try {
      this.castController?.sendControlCommand(avCommand);
    } catch (e) {
      hilog.error(DOMAIN, TAG, `pause sendControlCommand failed: ${e}`);
    }
  }
}