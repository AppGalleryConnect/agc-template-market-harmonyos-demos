import { common } from '@kit.AbilityKit';
import { avSession } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BackgroundTaskManager } from '../utils/BackgroundTaskManager';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { VideoPlayData } from '../datasource/VideoPlayDataSource';

const TAG = 'AvSessionController';

export class AvSessionController {
  private static instance: AvSessionController | null;
  private context: common.UIAbilityContext | undefined = undefined;
  private avSession: avSession.AVSession | undefined = undefined;
  private avSessionMetadata: avSession.AVMetadata | undefined = undefined;
  public isAllow: boolean = false

  constructor() {
    this.initAvSession();
  }

  public static getInstance(): AvSessionController {
    if (!AvSessionController.instance) {
      AvSessionController.instance = new AvSessionController();
    }
    return AvSessionController.instance;
  }

  public initAvSession() {
    this.context = AppStorage.get('context');
    if (!this.context) {
      hilog.info(0x0000, TAG, `session create failed : conext is undefined`);
      return;
    }
    try {
      avSession.createAVSession(this.context, 'SHORT_AUDIO_SESSION', 'video').then(async (avSession) => {
        this.avSession = avSession;
        hilog.info(0x0000, TAG, `session create successed : sessionId : ${this.avSession.sessionId}`);
        if (AvSessionController.getInstance().isAllow) {
          BackgroundTaskManager.startContinuousTask(this.context);
        }
        this.setLaunchAbility();
        this.avSession.activate();
      });
    } catch (e) {
    }
  }

  public getAvSession() {
    return this.avSession;
  }

  public getAvSessionMetadata() {
    return this.avSessionMetadata;
  }

  public async setAVMetadata(curSource: VideoPlayData) {
    if (curSource === undefined) {
      hilog.info(0x0000, TAG, 'SetAVMetadata Error, curSource is null');
      return;
    }

    let metadata: avSession.AVMetadata = {
      assetId: `${curSource.getUrl()}`,
      duration: curSource.getPlayTime(),
      mediaImage: `${curSource.getPic()}`
    };
    if (this.avSession) {
      this.avSession.setAVMetadata(metadata).then(() => {
        this.avSessionMetadata = metadata;
        hilog.info(0x0000, TAG, 'SetAVMetadata successfully');
      }).catch((err: BusinessError) => {
        hilog.info(0x0000, TAG, `SetAVMetadata BusinessError: code: ${err.code}, message: ${err.message}`);
      });
    }
  }

  private setLaunchAbility() {
    if (!this.context) {
      return;
    }
    // const wantAgentInfo: wantAgent.WantAgentInfo = {
    //   wants: [
    //     {
    //       bundleName: this.context.abilityInfo.bundleName,
    //       abilityName: this.context.abilityInfo.name
    //     }
    //   ],
    //   operationType: wantAgent.OperationType.START_ABILITY,
    //   requestCode: 0,
    //   wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    // };
    // wantAgent.getWantAgent(wantAgentInfo).then((agent) => {
    //   if (this.avSession) {
    //     this.avSession.setLaunchAbility(agent);
    //   }
    // });
  }

  public setAvSessionPlayState(playbackState: avSession.AVPlaybackState) {
    if (this.avSession) {
      try {
        this.avSession.setAVPlaybackState(playbackState, (err: BusinessError) => {
          if (err) {
            hilog.info(0x0000, TAG, `SetAVPlaybackState BusinessError: code: ${err.code}, message: ${err.message}`);
          } else {
            hilog.info(0x0000, TAG, 'SetAVPlaybackState successfully');
          }
        });
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, TAG, `setAvSessionPlayState failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      }
    }
  }

  async unregisterSessionListener() {
    if (!this.avSession) {
      return;
    }
    this.avSession.off('play');
    this.avSession.off('pause');
    this.avSession.off('playNext');
    this.avSession.off('playPrevious');
    this.avSession.off('setLoopMode');
    this.avSession.off('seek');
    this.avSession.off('toggleFavorite');
    BackgroundTaskManager.stopContinuousTask(this.context);
  }
}