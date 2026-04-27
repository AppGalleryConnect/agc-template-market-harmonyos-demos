import { common, wantAgent } from '@kit.AbilityKit';
import { avSession } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { BackgroundTaskUtils } from '../utils/BackgroundTaskUtils';
import { AVPlayerState, VideoPlayerData } from '../type/Index';

const TAG = '[VideoSessionController]';

/**
 * 播控中心控制器
 */
export class VideoSessionController {
  private static _instance: VideoSessionController | null;
  private session: avSession.AVSession | null = null;

  public static get instance() {
    if (!VideoSessionController._instance) {
      VideoSessionController._instance = new VideoSessionController();
    }
    return VideoSessionController._instance;
  }

  public getSession() {
    return this.session;
  }

  /**
   * 创建会话
   * @param context
   */
  public async create(context: Context) {
    try {
      this.session = await avSession.createAVSession(context, 'SESSION_VIDEO', 'video');
      BackgroundTaskUtils.createBackgroundTask(context as common.UIAbilityContext);
      this.setLaunchApp(context as common.UIAbilityContext);
      UtilLog.info(TAG, `Session created. sessionId: ${this.session.sessionId}`);
    } catch (e) {
      UtilLog.error(TAG, `Failed to createAVSession. Code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 设置元数据
   * @param videoData
   * @returns
   */
  public setAVMetadata(videoData: VideoPlayerData) {
    if (!this.session) {
      return;
    }
    const metadata: avSession.AVMetadata = {
      assetId: videoData.getVideoId(),
      title: videoData.getVideoTitle(),
      filter: avSession.ProtocolType.TYPE_CAST_PLUS_STREAM | avSession.ProtocolType.TYPE_DLNA,
    };
    if (videoData.getCoverUrl()) {
      metadata.mediaImage = videoData.getCoverUrl();
    }
    if (videoData.getVideoDuration()) {
      metadata.duration = videoData.getVideoDuration();
    }
    if (videoData.getAuthorName?.()) {
      metadata.subtitle = videoData.getAuthorName?.();
    }
    this.session.setAVMetadata(metadata).then(() => {
      UtilLog.info(TAG, `setAVMetadata successfully, videoData: ${JSON.stringify(videoData)}`);
    }).catch((e: BusinessError) => {
      UtilLog.error(TAG, `Failed to set AVMetadata. Code: ${e.code}, message: ${e.message}`);
    });
  }

  /**
   * 设置extra参数支持投屏
   */
  public async supportCast() {
    try {
      // 请按照如下参数设置，告知系统应用当前支持投播，才能成功投播。
      await this.session?.setExtras({
        requireAbilityList: ['url-cast'],
      });
    } catch (e) {
      UtilLog.error(TAG, `Failed to supportCast setExtras. Code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 禁用投屏
   */
  public async disableCast() {
    try {
      await this.session?.setExtras({
        requireAbilityList: [],
      });
    } catch (e) {
      UtilLog.error(TAG, `Failed to disableCast setExtras. Code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 是否在投屏中
   */
  async isCasting(): Promise<boolean> {
    try {
      if (!this.session) {
        return false;
      }
      const outputDeviceInfo = await this.session.getOutputDevice();
      return outputDeviceInfo.devices[0]?.castCategory === avSession.AVCastCategory.CATEGORY_REMOTE;
    } catch (e) {
      UtilLog.error(TAG, `Failed to getOutputDevice. Code: ${e.code}, message: ${e.message}`);
      return false;
    }
  }

  /**
   * 停止投屏
   */
  public async stopCasting() {
    try {
      // 一般来说，应用退出时，而不希望继续投播，可以主动结束
      await this.session?.stopCasting();
    } catch (e) {
      UtilLog.error(TAG, `Failed to stopCasting. Code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 设置播放状态
   * @param state
   */
  public async initAVPlaybackState() {
    if (!this.session) {
      return;
    }
    try {
      const state: avSession.AVPlaybackState = {
        state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
        position: {
          elapsedTime: 0,
          updateTime: new Date().getTime(),
        },
        speed: 1,
        loopMode: avSession.LoopMode.LOOP_MODE_SEQUENCE,
        isFavorite: false,
      };
      await this.session.setAVPlaybackState(state);
    } catch (e) {
      UtilLog.error(TAG, `Failed to set setAVPlaybackState. Code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 注册session事件监听
   * @param callback
   */
  public setListener(callback: SessionListener) {
    if (!this.session) {
      return;
    }
    try {
      if (callback.play) {
        this.session.on('play', callback.play);
      }

      if (callback.pause) {
        this.session.on('pause', callback.pause);
      }

      if (callback.playNext) {
        this.session.on('playNext', callback.playNext);
      }

      if (callback.playPrevious) {
        this.session.on('playPrevious', callback.playPrevious);
      }
      // 如支持投播，可使用下面接口监听设备连接状态的变化
      if (callback.outputDeviceChange) {
        this.session.on('outputDeviceChange', callback.outputDeviceChange);
      }
    } catch (e) {
      UtilLog.error(TAG, `Failed to session.on commands. Code: ${e.code}, message: ${e.message}`);
    }
  }


  /**
   * 释放session事件监听
   */
  public releaseListener() {
    if (!this.session) {
      return;
    }
    try {
      this.session.off('play');
      this.session.off('pause');
      this.session.off('playNext');
      this.session.off('playPrevious');
    } catch (e) {
      UtilLog.error(TAG, `Failed to releaseListener. Code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 释放播放事件监听
   */
  public releasePlayListener() {
    if (!this.session) {
      return;
    }
    try {
      this.session.off('play');
    } catch (e) {
      UtilLog.error(TAG, `Failed to releasePlayListener. Code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 释放上一个/下一个事件监听
   */
  public releaseNextPreviousListener() {
    if (!this.session) {
      return;
    }
    try {
      this.session.off('playNext');
      this.session.off('playPrevious');
    } catch (e) {
      UtilLog.error(TAG, `Failed to releaseNextPreviousListener. Code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 从avplayer同步状态到播控中心
   */
  public setState: (state: string) => void = async (state) => {
    UtilLog.debug(TAG, 'setState: ' + state);
    if (!this.session) {
      return;
    }
    try {
      await this.session.setAVPlaybackState({
        state: state === AVPlayerState.PLAYING ?
          avSession.PlaybackState.PLAYBACK_STATE_PLAY : avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      });
    } catch (e) {
      UtilLog.error(TAG, `Failed to setState. Code: ${e.code}, message: ${e.message}`);
    }
  }
  /**
   * 从avplayer同步进度到播控中心
   */
  public setProgress: (time: number) => void = async (time) => {
    try {
      if (!this.session) {
        return;
      }
      await this.session.setAVPlaybackState({
        position: {
          elapsedTime: time,
          updateTime: new Date().getTime(),
        },
      });
    } catch (e) {
      UtilLog.error(TAG, `Failed to setProgress. Code: ${e.code}, message: ${e.message}`);
    }
  };

  /**
   * 从播控中心拉起应用
   * @param context
   */
  private async setLaunchApp(context: common.UIAbilityContext) {
    if (!this.session) {
      return;
    }
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: context.abilityInfo.bundleName,
          abilityName: context.abilityInfo.name,
        },
      ],
      actionType: wantAgent.OperationType.START_ABILITIES,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG],
    };
    try {
      const agent = await wantAgent.getWantAgent(wantAgentInfo);
      await this.session.setLaunchAbility(agent);
    } catch (e) {
      UtilLog.error(TAG, `Failed to launchApp. Code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 激活会话
   */
  public async activate() {
    try {
      if (!this.session) {
        return;
      }
      await this.session.activate();
      UtilLog.info(TAG, `Success to activate, sessionId: ${this.session?.sessionId}`);
    } catch (e) {
      UtilLog.error(TAG, `Failed to activate. Code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 禁用会话
   */
  public async deactivate() {
    try {
      await this.session?.deactivate();
    } catch (e) {
      UtilLog.error(TAG, `Failed to deactivate. Code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 销毁会话
   * @param context
   */
  public async destroy(context: Context) {
    try {
      if (!this.session) {
        return;
      }
      this.releaseListener();
      await this.session?.destroy();
      await BackgroundTaskUtils.cancelBackgroundTask(context as common.UIAbilityContext);
      this.session = null;
    } catch (e) {
      UtilLog.error(TAG, `Failed to destroy. Code: ${e.code}, message: ${e.message}`);
    }
  }
}

export interface SessionListener {
  play?: () => void;
  pause?: () => void;
  playNext?: () => void;
  playPrevious?: () => void;
  outputDeviceChange?: (state: avSession.ConnectionState, device: avSession.OutputDeviceInfo) => void;
}