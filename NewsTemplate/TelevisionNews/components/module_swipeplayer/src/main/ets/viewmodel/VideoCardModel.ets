import { media } from '@kit.MediaKit';
import { display } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { avSession } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { Constants } from '../constants/Constants';
import { BreakpointNameEnum, PageNameEnum, VideoPlayerData } from '../type/Index';
import { VideoPlayerModel } from './VideoPlayerModel';
import { VideoNetworkModel } from '../models/VideoNetworkModel';
import { isDisplayModeFull } from '../utils/Util';
import { Logger } from '../utils/Logger';
import { SessionListener, VideoSessionController } from '../controller/VideoSessionController';
import { VideoCastController } from '../controller/VideoCastController';
import { AVPlayerController } from '../controller/AVPlayerController';
import { BreakpointModel } from '../models/BreakpointModel';

const TAG = '[VideoCardModel]';

@ObservedV2
export class VideoCardModel extends VideoPlayerModel {
  // 封面图的高度
  @Trace coverImgHeight: Length = Constants.VIDEO_CARD_HEIGHT;
  @Trace isPause: boolean = true;
  @Trace enableAVSession: boolean = false;
  @Trace enableCastPlay: boolean = false;
  @Trace breakpointModel: BreakpointModel = new BreakpointModel();
  videoNetwork?: VideoNetworkModel
  xComponentId: string = ''

  initPlayerManager(data: VideoPlayerData) {
    // 设置视频数据
    this.setVideoData(data);
    this.playerId = 'player_' + data.getVideoId() + util.generateRandomUUID();
    this.avPlayerManager.setPlayerId(this.index, this.playerId);
    this.avPlayerManager.setAVPlayerController(this.playerId, this.avPlayerController!);
  }

  async initAVPlayer() {
    try {
      // 创建播放器
      const avPlayer = await media.createAVPlayer();
      if (avPlayer) {
        this.avPlayerController.setAVPlayer(avPlayer);
        // 设置视频url
        if (this.videoNetwork?.isWiFi || (this.videoNetwork?.isCellular && this.videoNetwork?.canUseMobileData)) {
          this.setDataSource()
        }
        // 初始化监听事件
        this.initPlayerListener(avPlayer)
      }
    } catch (e) {
      Logger.error(TAG, 'createAVPlayer fail, error: ' + JSON.stringify(e));
    }
  }

  // 计算尺寸
  adaptiveVideoSize() {
    try {
      let videoRatio = Number(this.videoWidth) / Number(this.videoHeight);
      let displayWidth = display.getDefaultDisplaySync().width;
      let vpWidth = this.uiContext!.px2vp(displayWidth);
      let screenWidth = vpWidth;
      // 大折叠、平板适配
      let isFullMode = isDisplayModeFull();
      if (isFullMode || (!isFullMode && this.breakpointModel.currentBreakpoint !== BreakpointNameEnum.SM)) {
        screenWidth = vpWidth / 2 - 48
      }
      this.xComponentHeight = screenWidth / videoRatio;
    } catch (e) {
      Logger.error(TAG, 'getDefaultDisplaySync fail, error: ' + JSON.stringify(e));
    }
  }

  initXComponentId() {
    this.xComponentId = 'XComponentId' + this.playerId;
  }

  // 使用移动流量播放
  playVideoWithMobileData() {
    let player = this.avPlayerController.getAVPlayer()
    if (player) {
      if (player.state === 'idle') {
        this.setDataSource()
      } else {
        this.avPlayerController.getAVPlayer()?.play().catch((e: BusinessError) => {
          Logger.error(TAG, 'play fail, error: ' + JSON.stringify(e));
        })
      }
    } else {
      this.initAVPlayer();
    }
  }

  jumpCastControlPage() {
    let param: Record<string, Object | AVPlayerController |
    VideoSessionController | VideoCastController | BreakpointModel> = {};
    param.avPlayerController = this.avPlayerController;
    param.avSessionController = this.avSessionController;
    param.videoCastController = this.videoCastController!;
    param.videoData = this.getVideData();
    param.breakpointModel = this.breakpointModel;
    setTimeout(() => {
      this.pathStack.pushPathByName(PageNameEnum.REMOTE_CONTROL_PAGE, param);
    }, 100);
  }

  async handleAVSession(context: Context) {
    if (!this.enableAVSession) {
      return;
    }
    if (!this.avSessionController.getSession()) {
      await this.avSessionController.create(context);
    }
    if (this.enableCastPlay) {
      this.avSessionController.supportCast();
    }
    this.avSessionController.setListener(this.sessionListener);
    this.avSessionController.activate();

    // 监听avplayer事件
    this.onAVPlayerChangeBySession();
  }

  public sessionListener: SessionListener = {
    play: () => {
      this.avPlayerController?.play()
    },
    pause: () => {
      this.avPlayerController?.pause()
    },
    outputDeviceChange: (state, device) => {
      this.outputDeviceChange(state, device);
    },
  };

  async outputDeviceChange(state: avSession.ConnectionState, device: avSession.OutputDeviceInfo) {
    try {
      const session = this.avSessionController.getSession();
      if (!session) {
        return;
      }
      // 可以通过当前设备及设备连接状态来更新应用内播放界面的显示
      const currentDevice: avSession.DeviceInfo = device?.devices?.[0];
      UtilLog.debug(TAG, `outputDeviceChange, state: ${state}, currentDevice: ${JSON.stringify(currentDevice)}`);
      if (currentDevice?.castCategory === avSession.AVCastCategory.CATEGORY_REMOTE &&
        state === avSession.ConnectionState.STATE_CONNECTED) {
        // 设备连接成功
        UtilLog.info(TAG, `Device connected: ${currentDevice.deviceId}, ${currentDevice.deviceName}`);
        const castController = await session.getAVCastController();
        if (this.videoCastController) {
          this.videoCastController.updateController(castController);
        } else {
          this.videoCastController = new VideoCastController(castController);
        }
        this.videoCastController.onPlaybackEvent();
        this.videoCastController.connectState = state;
        this.videoCastController.deviceName = currentDevice.deviceName;
        if (!this.videoCastController.isCasting) {
          this.videoCastController.currentTime = this.avPlayerController.avPlayer?.currentTime ?? 0;
        }
        // 本地暂停播放
        this.avPlayerController.pause();
        // 对端设备播放
        this.videoCastController.setVideoData(this.getVideData());
        this.videoCastController.startCastPlay();
        // 跳转遥控器页面
        if (!this.videoCastController.isCasting) {
          this.jumpCastControlPage();
        }
        this.videoCastController.isCasting = true;
      }
    } catch (e) {
      UtilLog.error(TAG, `Failed to handle outputDeviceChange. Code: ${e.code}, message: ${e.message}`);
    }
  }
}