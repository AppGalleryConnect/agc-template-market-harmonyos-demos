import { common, wantAgent } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { avSession } from '@kit.AVSessionKit';
import { UtilLog as Logger, UtilLog } from '@hw-agconnect/util-log';
import { MediaData } from '../model/Index';
import { BackgroundTaskManager } from '../util/BackgroundTaskManager';


const TAG = 'AvSessionController';

export class AvSessionController {
  private static instance: AvSessionController | null;
  private context: common.UIAbilityContext | undefined = undefined;
  private avSession: avSession.AVSession | undefined = undefined;
  private avSessionMetadata: avSession.AVMetadata | undefined = undefined;
  private avSessionController: avSession.AVSessionController | undefined = undefined;

  public static getInstance(): AvSessionController {
    if (!AvSessionController.instance) {
      AvSessionController.instance = new AvSessionController();
    }
    return AvSessionController.instance;
  }

  public async initAvSession(context: common.UIAbilityContext) {
    this.context = context;
    if (!this.context) {
      Logger.info(TAG, `session create failed : conext is undefined`);
      return;
    }
    try {
      this.avSession = await avSession.createAVSession(this.context, 'SHORT_AUDIO_SESSION', 'video');
      Logger.info(TAG, `session create successed : sessionId : ${this.avSession.sessionId}`);
      this.avSessionController = await this.avSession.getController();
      Logger.info(TAG, `session controller create successed : sessionId : ${this.avSession.sessionId}`);
      BackgroundTaskManager.startContinuousTask(this.context);
      this.setLaunchAbility();
      await this.avSession.setExtras({
        requireAbilityList: ['url-cast'],
      });
    } catch (e) {
      UtilLog.error(TAG, `sessionFlowFn fail : ${JSON.stringify(e)}`);
    }
  }

  public async release() {
    this.unregisterSessionListener();
    await this.avSession?.deactivate();
    await this.avSession?.destroy();
    this.avSession = undefined;
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

  public async setAVMetadata(curSource: MediaData, duration?: number) {
    if (curSource === undefined) {
      Logger.error(TAG, 'SetAVMetadata Error, curSource is null');
      return;
    }
    let metadata: avSession.AVMetadata = {
      assetId: curSource.id,
      title: curSource.name as string,
      mediaImage: curSource.head,
      duration: duration,
      filter: avSession.ProtocolType.TYPE_CAST_PLUS_STREAM | avSession.ProtocolType.TYPE_DLNA,
    };
    if (this.avSession) {
      await this.avSession.setAVMetadata(metadata).then(() => {
        this.avSessionMetadata = metadata;
        Logger.info(TAG, 'SetAVMetadata successfully');
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `SetAVMetadata BusinessError: code: ${err.code}, message: ${err.message}`);
      });
    }
  }

  public setAvSessionPlayState(playbackState: avSession.AVPlaybackState) {
    if (this.avSession) {
      this.avSession.setAVPlaybackState(playbackState, (err: BusinessError) => {
        if (err) {
          Logger.error(TAG, `SetAVPlaybackState BusinessError: code: ${err.code}, message: ${err.message}`);
        } else {
          Logger.info(TAG, 'SetAVPlaybackState successfully');
        }
      });
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

  private setLaunchAbility() {
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
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG],
    };
    try {
      wantAgent.getWantAgent(wantAgentInfo).then((agent) => {
        if (this.avSession) {
          this.avSession.setLaunchAbility(agent);
        }
      });
    } catch (e) {
      UtilLog.error(`getSupportedCameras failed: ${JSON.stringify(e)}`);
    }
  }
}