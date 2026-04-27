import { AppStorageV2 } from '@kit.ArkUI';
import { avSession } from '@kit.AVSessionKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { AVPlayerController } from '../controller/AVPlayerController';
import { CastEventKey, VideoCastController } from '../controller/VideoCastController';
import { VideoSessionController } from '../controller/VideoSessionController';
import { GlobalConfigModel } from '../models/GlobalConfigModel';
import { BreakpointModel } from '../models/BreakpointModel';
import { BreakpointNameEnum, VideoPlayerData } from '../type/Index';
import { secondToTime } from '../utils/Util';

const TAG = '[PageCastControlVM]';

@ObservedV2
export class PageCastControlVM {
  public uiContext: UIContext | undefined = undefined;
  public avPlayerController: AVPlayerController = new AVPlayerController();
  public avSessionController: VideoSessionController = new VideoSessionController();
  @Trace videoCastController: VideoCastController | null = null;
  @Trace globalConfigModel: GlobalConfigModel = AppStorageV2.connect(GlobalConfigModel, () => new GlobalConfigModel())!;
  @Trace isPlaying: boolean = true;
  @Trace pathStack: NavPathStack = new NavPathStack();
  @Trace breakpointModel: BreakpointModel = new BreakpointModel();
  @Trace videoTitle: string = '';
  // 视频时长（单位：ms）
  @Trace durationTime: number = 0;
  @Trace isSliderMoving: boolean = false;
  @Trace sliderValue: number = 0;
  @Trace isPlayOver: boolean = false;

  initParams(context: NavDestinationContext) {
    this.pathStack = context.pathStack;
    if (!context.pathInfo.param) {
      return;
    }
    let param = context.pathInfo.param as Record<string, Object | AVPlayerController |
    VideoSessionController | VideoCastController | BreakpointModel>;
    this.videoTitle = (param.videoData as VideoPlayerData).getVideoTitle();
    this.breakpointModel = (param.breakpointModel as BreakpointModel);
    this.avPlayerController = param.avPlayerController as AVPlayerController;
    this.avSessionController = param.avSessionController as VideoSessionController;
    this.videoCastController = param.videoCastController as VideoCastController;
    this.durationTime = this.avPlayerController.avPlayer?.duration ?? 10;
    try {
      this.videoCastController.registerListener(CastEventKey.PLAYBACK_STATE_CHANGE, this.onStateChange);
      this.videoCastController.registerListener(CastEventKey.END_OF_STREAM, this.onEndOfStream);
      this.avSessionController.getSession()?.on('outputDeviceChange', this.onConnectDeviceChange);
    } catch (e) {
      UtilLog.error(TAG, `Failed to onListeners. Code: ${e.code}, message: ${e.message}`);
    }
  }

  offListeners() {
    try {
      this.videoCastController?.unregisterListener(CastEventKey.PLAYBACK_STATE_CHANGE, this.onStateChange);
      this.videoCastController?.unregisterListener(CastEventKey.END_OF_STREAM, this.onEndOfStream);
      this.avSessionController.getSession()?.off('outputDeviceChange', this.onConnectDeviceChange);
    } catch (e) {
      UtilLog.error(TAG, `Failed to offListeners. Code: ${e.code}, message: ${e.message}`);
    }
  }

  async onBackPress() {
    this.uiContext?.showAlertDialog({
      title: '温馨提示',
      message: '远端设备会退出投屏播放。是否确认返回？',
      buttons: [
        {
          value: '确定',
          fontColor:
          this.globalConfigModel.themeColor,
          action: () => {
            this.quitCastVideo();
          },
        },
        {
          value: '取消',
          fontColor: this.globalConfigModel.themeColor,
          action: () => {
          },
        },
      ],
      onWillDismiss: () => {
      },
    })
  }

  quitCastVideo() {
    if (this.videoCastController?.isCasting) {
      this.pathStack.pop();
      this.avSessionController.stopCasting();
      // 同步远端设备进度
      this.avPlayerController.getAVPlayer()?.seek(this.videoCastController.currentTime);
      // 切回本地播放
      this.avPlayerController.play();
      this.videoCastController.isCasting = false;
    }
  }

  reStart() {
    this.isPlayOver = false;
    this.videoCastController!.currentTime = 0;
    this.videoCastController?.startCastPlay();
  }

  onConnectDeviceChange: (state: avSession.ConnectionState, device: avSession.OutputDeviceInfo) => void =
    (state, device) => {
      const currentDevice: avSession.DeviceInfo = device?.devices?.[0];
      // 切换到本机，退出投屏
      if (currentDevice?.castCategory !== avSession.AVCastCategory.CATEGORY_REMOTE) {
        this.quitCastVideo();
        return;
      }
      // 更新连接状态
      this.videoCastController!.connectState = state;
    };
  onStateChange: Callback<avSession.AVPlaybackState> = (state) => {
    if (this.disableOperate) {
      return;
    }
    if (this.videoCastController?.isSeeking) {
      return;
    }
    // 播放状态变化
    if (state.state) {
      this.isPlaying = [
        avSession.PlaybackState.PLAYBACK_STATE_PLAY,
        avSession.PlaybackState.PLAYBACK_STATE_BUFFERING,
      ].includes(state.state);
    }
  };
  onEndOfStream: () => void = () => {
    this.isPlayOver = true;
  };

  onSliderChange(value: number, mode: SliderChangeMode) {
    UtilLog.debug(TAG, `onSliderChange, mode: ${mode}, value: ${value}`);
    this.isSliderMoving = mode === SliderChangeMode.Moving;
    this.sliderValue = Math.floor(value / 1000) * 1000;
    this.videoCastController!.currentTime = this.sliderValue;
    if (mode === SliderChangeMode.End || mode === SliderChangeMode.Click) {
      this.videoCastController?.seek(this.sliderValue);
    }
  }

  @Computed
  get disableOperate() {
    return this.disconnected || this.connecting;
  }

  @Computed
  get disconnected() {
    return this.videoCastController?.connectState === avSession.ConnectionState.STATE_DISCONNECTED;
  }

  @Computed
  get connecting() {
    return this.videoCastController?.connectState === avSession.ConnectionState.STATE_CONNECTING;
  }

  @Computed
  get currentTime() {
    const time = this.isSliderMoving ? this.sliderValue : this.videoCastController?.currentTime;
    return time ?? 0;
  }

  @Computed
  get currentStringTime() {
    return secondToTime(Math.floor(this.currentTime / 1000));
  }

  @Computed
  get durationStringTime() {
    return secondToTime(Math.floor(this.durationTime / 1000));
  }

  @Computed
  get isSplit() {
    return [BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.breakpointModel.currentBreakpoint);
  }
}