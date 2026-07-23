import { hilog } from '@kit.PerformanceAnalysisKit';
import { common, wantAgent } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { avSession } from '@kit.AVSessionKit';
import { VideoData } from '../model/VideoData';
import { BackgroundTaskManager } from '../common/utils/BackgroundTaskManager';

const TAG = 'AvSessionController';

export class AvSessionController {
  private static instance: AvSessionController | null;
  private context: common.UIAbilityContext | undefined = undefined;
  private avSession: avSession.AVSession | undefined = undefined;
  private avSessionMetadata: avSession.AVMetadata | undefined = undefined;
  private avSessionController: avSession.AVSessionController | undefined = undefined
  constructor() {
  }

  public static getInstance(): AvSessionController {
    if (!AvSessionController.instance) {
      AvSessionController.instance = new AvSessionController();
    }
    return AvSessionController.instance;
  }

  public async initAvSession(context: common.UIAbilityContext) {
    try {
      this.context = context;
      if (!this.context) {
        hilog.info(0x0000, TAG, `session create failed : conext is undefined`);
        return;
      }
      this.avSession = await avSession.createAVSession(this.context, 'SHORT_AUDIO_SESSION', 'video')
      hilog.info(0x0000, TAG, `session create successed : sessionId : ${this.avSession.sessionId}`);
      this.avSessionController = await this.avSession.getController();
      hilog.info(0x0000, TAG, `session controller create successed : sessionId : ${this.avSession.sessionId}`);
      BackgroundTaskManager.startContinuousTask(this.context);
      this.setLaunchAbility();
      await this.avSession.setExtras({
        requireAbilityList: ['url-cast']
      });
    } catch (e) {
    }
  }

  public async release() {
    this.unregisterSessionListener()
    try {
      await this.avSession?.deactivate()
    } catch (e) {
      hilog.error(0x0000, TAG, `release deactivate failed: ${e}`);
    }
    try {
      await this.avSession?.destroy()
    } catch (e) {
      hilog.error(0x0000, TAG, `release destroy failed: ${e}`);
    }
    this.avSession = undefined
  }

  private setLaunchAbility() {
    if (!this.context) {
      return;
    }
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: this.context.abilityInfo.bundleName,
          abilityName: this.context.abilityInfo.name
        }
      ],
      // operationType: wantAgent.OperationType.START_ABILITIES,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    try {
      wantAgent.getWantAgent(wantAgentInfo).then((agent) => {
        if (this.avSession) {
          this.avSession.setLaunchAbility(agent);
        }
      });
    } catch (e) {
    }
  }

  public getAvSession() {
    return this.avSession;
  }

  public getAvSessionController() {
    return this.avSessionController;
  }

  public getAvSessionMetadata() {
    return this.avSessionMetadata;
  }

  public async setAVMetadata(curSource: VideoData, duration?: number) {
    hilog.error(0x0000, TAG, 'SetAVMetadata');
    if (curSource === undefined) {
      hilog.error(0x0000, TAG, 'SetAVMetadata Error, curSource is null');
      return;
    }

    let metadata: avSession.AVMetadata = {
      assetId: `${curSource.index}}`,
      title: curSource.name as string,
      mediaImage: curSource.head,
      duration: duration,
      filter: avSession.ProtocolType.TYPE_CAST_PLUS_STREAM | avSession.ProtocolType.TYPE_DLNA,
    };
    hilog.info(0x0000, TAG, `SetAVMetadata ${JSON.stringify(metadata)}`);
    if (this.avSession) {
      await this.avSession.setAVMetadata(metadata).then(() => {
        this.avSessionMetadata = metadata;
        hilog.info(0x0000, TAG, 'SetAVMetadata successfully');
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, `SetAVMetadata BusinessError: code: ${err.code}, message: ${err.message}`);
      });
    }
  }

  public setAvSessionPlayState(playbackState: avSession.AVPlaybackState) {
    if (this.avSession) {
      try {
        this.avSession.setAVPlaybackState(playbackState, (err: BusinessError) => {
          if (err) {
            hilog.error(0x0000, TAG, `SetAVPlaybackState BusinessError: code: ${err.code}, message: ${err.message}`);
          } else {
            hilog.info(0x0000, TAG, 'SetAVPlaybackState successfully');
          }
        });
      } catch (e) {
        hilog.error(0x0000, TAG, `setAvSessionPlayState failed: ${e}`);
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
    try {
      BackgroundTaskManager.stopContinuousTask(this.context);
    } catch (e) {
      hilog.error(0x0000, TAG, `stopContinuousTask failed: ${e}`);
    }
  }
}