import { media } from '@kit.MediaKit';
import { display, window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { LongTakeAnimationProperties, LongTakeTransitionParam } from 'module_transition';
import { Constants } from '../constants/Constants'
import { AVPlayerController } from '../controller/AVPlayerController';
import { VideoCardPlayerController } from '../controller/VideoCardPlayerController';
import { isDisplayModeFull, pauseVideo, playVideo, setOrientation, isDevicePlaceFlat } from '../utils/Util';
import { VolumeAndBright } from '../utils/VolumeAndBright';
import { AVPlayerState, BreakpointNameEnum, PageNameEnum } from '../type/Index';
import { ProgressController } from '../components/VideoProgressBar';
import { BreakpointModel } from '../models/BreakpointModel';
import { Logger } from '../utils/Logger';

const TAG = '[LandscapeVideoVM]';

@ObservedV2
export class LandscapeVideoVM {
  player: media.AVPlayer | undefined;
  @Trace xComponentWidth: Length = Constants.FULL_PERCENT;
  @Trace xComponentHeight: Length = Constants.FULL_PERCENT;
  @Trace videoWidth: number = Constants.SURFACE_WIDTH;
  @Trace videoHeight: number = Constants.SURFACE_HEIGHT;
  // 当前跳转过来的路由栈
  @Trace pathStack: NavPathStack = new NavPathStack()
  // 当前视频的标题
  @Trace videoTitle: string = ''
  // 当前视频播放avplayer控制器
  @Trace avPlayerController: AVPlayerController | undefined = undefined;
  // 定时隐藏
  @Trace showBar: boolean = true
  @Trace time: number = 0
  // 是否锁屏
  @Trace showLock: boolean = true
  @Trace isLockScreen: boolean = false
  // 返回标识
  @Trace isBackFlag: boolean = false
  // 是否播放
  @Trace isPlaying: boolean = true;
  // 是否缓存
  @Trace isBuffering: boolean = false;
  @Trace trackThicknessSize: number = Constants.TRACK_SIZE_MIN;
  // 倍速
  @Trace isAccelerate: boolean = false;
  @Trace leftRateOpacity: number = 0;
  @Trace rightRateOpacity: number = 1;
  @Trace volumeUtil: VolumeAndBright = new VolumeAndBright()
  // 进度条跟随手势滑动
  @Trace panStartTime: number = 0
  @Trace panEndTime: number = 0
  // 一多适配的断点
  @Trace breakpointModel: BreakpointModel = new BreakpointModel();
  @Trace isFullMode: boolean = false;
  @Trace isMute: boolean = true
  // 是否隐藏进度条
  @Trace isHideSlide = false;
  // 是否显示开通会员的内容
  @Trace showMembershipOverlay: boolean = false;
  @Trace disableUpdateBrightAndVolume: boolean = false;
  // 是否是来源详情卡片
  @Trace isFromDetailCard: boolean = false;
  positionX: number = 0;
  positionY: number = 0;
  progressController: ProgressController = new ProgressController();
  uiContext?: UIContext
  windowClass?: window.Window
  videoCardPlayerController: VideoCardPlayerController = new VideoCardPlayerController();
  xComponentController: XComponentController = new XComponentController();
  @Trace longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  membershipBuilder: WrappedBuilder<[() => void]> | undefined = undefined;
  systemBarProperty: window.SystemBarProperties = {};

  constructor(uiContext: UIContext) {
    try {
      this.uiContext = uiContext;
      const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
      this.windowClass = context.windowStage!.getMainWindowSync();

      AppStorage.setAndRef('windowClass', this.windowClass)
    } catch (e) {
      Logger.error(TAG, 'getMainWindowSync fail, error: ' + JSON.stringify(e));
    }
  }

  @Computed
  get isTablet() {
    return [BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.breakpointModel.currentBreakpoint);
  }

  init() {
    try {
      this.windowClass?.on('windowSizeChange', (size) => {
        this.xComponentWidth = this.uiContext!.px2vp(size.width);
        this.xComponentHeight = this.uiContext!.px2vp(size.height);
        this.isFullMode = isDisplayModeFull();
        Logger.debug(TAG, 'this.isFullMode: ' + this.isFullMode + ', width: ' + size.width + ', height: ' + size.height);
        if (!this.isBackFlag && size.width < size.height && !this.isFullMode &&
          this.pathStack.getAllPathName().includes(PageNameEnum.VIDEO_LANDSCAPE_PAGE)
        ) {
          Logger.debug(TAG, 'on windowSizeChange quitFullScreen');
          this.quitFullScreen();
        }
      })
      this.showOrHiddenBar();
    } catch (err) {
      Logger.error(TAG, 'register windowClass fail, error: ' + JSON.stringify(err));
    }

  }

  async getWindowInfo() {
    window.getLastWindow(this.uiContext?.getHostContext())
      .then((windowClass) => {
        try {
          const width = windowClass.getWindowProperties().windowRect.width;
          const height = windowClass.getWindowProperties().windowRect.height;
          this.xComponentWidth = this.uiContext!.px2vp(width);
          this.xComponentHeight = this.uiContext!.px2vp(height);
        } catch (e) {
          Logger.error(TAG, `Failed to getWindowProperties, code: ${e.code}, message: ${e.message}`);
        }
      })
      .catch((e: BusinessError) => {
        Logger.error(TAG, `Failed to getLastWindow, code: ${e.code}, message: ${e.message}`);
      })
  }

  private onStateChange: (state: AVPlayerState) => void = (state) => {
    Logger.debug(TAG, 'stateChange: ' + state);
    // 详情页横屏播放完成时暂停，否则继续播放
    if (this.isFromDetailCard) {
      this.isPlaying = state === AVPlayerState.PLAYING
    } else {
      // 横屏时，播放完之后会重头播放，需要保持播放状态
      this.isPlaying = state === AVPlayerState.PLAYING || state === AVPlayerState.COMPLETED;
    }
  }
  private onBufferingUpdate: (infoType: media.BufferingInfoType) => void = (infoType) => {
    if (infoType === media.BufferingInfoType.BUFFERING_START) {
      this.isBuffering = true;
    }
    if (infoType === media.BufferingInfoType.BUFFERING_END) {
      this.isBuffering = false
    }
  }

  // 处理NavDestination上下文和路由参数
  handleContextInfo(context: NavDestinationContext) {
    this.pathStack = context.pathStack
    let param = context.pathInfo?.param as Record<string, Object | AVPlayerController | BreakpointNameEnum>;
    this.avPlayerController = (param.avPlayerController as AVPlayerController)
    this.player = (param.avPlayerController as AVPlayerController).getAVPlayer() as media.AVPlayer;
    this.videoWidth = param.videoWidth as number
    this.videoHeight = param.videoHeight as number
    this.videoTitle = param.videoTitle as string
    this.breakpointModel = param.breakpointModel as BreakpointModel
    this.isMute = param.isMute as boolean
    this.isHideSlide = param.isHideSlide as boolean
    this.isFromDetailCard = param.isFromDetailCard as boolean
    if (param.videoCardPlayerController) {
      this.videoCardPlayerController = param.videoCardPlayerController as VideoCardPlayerController;
      this.videoCardPlayerController.setMembershipOverlay = (value) => {
        this.showMembershipOverlay = value;
        if (this.showMembershipOverlay) {
          this.showBar = false;
          this.showLock = false;
          this.isLockScreen = false;
        }
      }
    }
    this.membershipBuilder = param.membershipBuilder as WrappedBuilder<[() => void]>;
    // 音量初始化
    this.volumeUtil.init()
    this.setMute()
    // 设置亮度
    this.volumeUtil.updateBrightness(this.uiContext!.getHostContext() as Context)
    // 状态监听
    this.avPlayerController?.onEvent('stateChange', this.onStateChange);
    this.avPlayerController?.onEvent('bufferingUpdate', this.onBufferingUpdate);
    this.registerCustomTransition(context, this.longTakeSession)
  }

  // 窗口等系统设置
  async setSystemConfig() {
    try {
      // 导航条、状态栏等设置
      await this.windowClass!.setSpecificSystemBarEnabled('navigationIndicator', false);
      await this.windowClass!.setSpecificSystemBarEnabled('status', true);
      this.systemBarProperty = this.windowClass!.getWindowSystemBarProperties();
      await this.windowClass!.setWindowSystemBarProperties({
        statusBarContentColor: '#FFFFFF',
      });
      // 窗口方向设置
      if (this.breakpointModel.isLandscapeAuto && display.isFoldable()) {
        Logger.debug(TAG, 'isLandscapeAuto set AUTO_ROTATION');
        const orientation = window.Orientation.AUTO_ROTATION;
        setOrientation(this.uiContext, orientation);
      }
    } catch (e) {
      Logger.error(TAG, `Failed to setSystemConfig, code: ${e.code}, message: ${e.message}`);
    }
  }

  // 还原状态栏、亮度等系统配置
  async resetSystemConfig() {
    try {
      await this.windowClass!.setSpecificSystemBarEnabled('navigationIndicator', true);
      await this.windowClass!.setSpecificSystemBarEnabled('status', true);
      await this.windowClass!.setWindowSystemBarProperties(this.systemBarProperty);
      await this.windowClass!.setWindowBrightness(-1);
    } catch (e) {
      Logger.error(TAG, `Failed to resetSystemConfig, code: ${e.code}, message: ${e.message}`);
    }
  }

  disappear() {
    try {
      // 清理窗口监听器
      this.windowClass!.off('windowSizeChange');
      // 清理avPlayerController的事件监听器
      this.avPlayerController?.offEvent('stateChange', this.onStateChange);
      this.avPlayerController?.offEvent('bufferingUpdate', this.onBufferingUpdate);
      this.videoCardPlayerController.setMembershipOverlay = () => {
      };
      // 清空本地引用（不影响共享的 avPlayerController 实例）
      this.avPlayerController = undefined;
      this.player = undefined;
      // 清理音量监听器
      this.volumeUtil.destroy();
      // 清理定时器
      if (this.time) {
        clearTimeout(this.time);
        this.time = 0;
      }
    } catch (e) {
      Logger.error(TAG, 'Fail to disappear, error: ' + JSON.stringify(e));
    }
  }

  async onBack() {
    this.isBackFlag = true;
    this.quitFullScreen();
  }

  quitFullScreen() {
    isDevicePlaceFlat((isFlat) => {
      // 默认是跟随桌面
      let orientation = window.Orientation.FOLLOW_DESKTOP;
      // 处理平放&&进入全屏前是竖屏状态
      if (isFlat) {
        if (this.breakpointModel.orientationBefore === display.Orientation.PORTRAIT) {
          orientation = window.Orientation.USER_ROTATION_PORTRAIT;
        } else if (this.breakpointModel.orientationBefore === display.Orientation.PORTRAIT_INVERTED) {
          orientation = window.Orientation.USER_ROTATION_PORTRAIT_INVERTED;
        }
      }
      setOrientation(this.uiContext, orientation).then(() => {
        Logger.debug(TAG, 'pop, orientation: ' + orientation);
        this.pathStack.pop(1);
      })
    })
  }

  async setSystemBarEnabled(enabled: boolean) {
    try {
      await this.windowClass?.setSpecificSystemBarEnabled('status', enabled);
    } catch (e) {
      Logger.error(TAG, `Failed to setSpecificSystemBarEnabled, code: ${e.code}, message: ${e.message}`);
    }
  }

  showOrHiddenBar() {
    if (this.showBar || this.showLock) {
      clearTimeout(this.time)
      this.time = setTimeout(() => {
        this.showBar = false
        this.showLock = false
        this.setSystemBarEnabled(false)
      }, 4000)
    } else {
      this.time && clearTimeout(this.time)
    }
  }

  lockScreen() {
    this.isLockScreen = !this.isLockScreen
    if (this.isLockScreen) {
      this.showBar = false
      this.showOrHiddenBar()
    } else {
      this.showBar = true
      if (this.isPlaying) {
        this.showOrHiddenBar()
      } else {
        this.time && clearTimeout(this.time)
      }
    }
  }

  switchPlayOrPause() {
    if (this.isPlaying) {
      this.pause();
      this.isPlaying = false;
      this.trackThicknessSize = Constants.TRACK_SIZE_MAX;
    } else {
      this.play();
      this.isPlaying = true;
      this.trackThicknessSize = Constants.TRACK_SIZE_MIN;
    }
    this.windowClass?.setWindowKeepScreenOn(true).catch((e: BusinessError) => {
      Logger.error(TAG, 'setWindowKeepScreenOn fail, error: ' + JSON.stringify(e));
    });
  }

  play() {
    playVideo(this.player);
  }

  pause() {
    pauseVideo(this.player);
  }

  setMute() {
    if (this.isMute) {
      this.volumeUtil.playerSliderModel.volume = 0
    }
  }

  // 处理视频外层的显示和隐藏
  handleVideoLayerVisible() {
    if (this.isPlaying) {
      this.showOrHiddenBar()
    } else {
      this.showBar = true
      if (this.time) {
        clearTimeout(this.time)
      }
    }
  }

  handleClickScreen() {
    this.showBar = this.isLockScreen ? false : !this.showBar
    this.showLock = !this.showLock
    if (this.isPlaying) {
      this.showOrHiddenBar()
    }
    this.setSystemBarEnabled(this.showBar);
  }

  // 长按加速
  onLongPress(event: GestureEvent) {
    if (this.avPlayerController?.avPlayer?.state === 'playing') {
      // 快进图标显隐变化
      this.leftRateOpacity = 1;
      this.rightRateOpacity = 0;
      if (event?.repeat) {
        this.isAccelerate = true;
        this.avPlayerController.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_2_00_X)
      }
    }
  }

  // 取消长按
  offLongPress() {
    if (this.avPlayerController?.avPlayer?.state === 'playing') {
      this.isAccelerate = false;
      this.avPlayerController.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_00_X)
    }
  }

  // 处理音量和亮度的滑动开始事件回调
  handleBrightAndVolumePanStart(event?: GestureEvent) {
    // 页面锁住时，不能进行操作
    if (this.isLockScreen) {
      return
    }
    if (!event) {
      return;
    }
    if (!event.fingerList[0]) {
      return
    }

    // 避免下拉状态栏时，误触发音量或亮度调节
    if (event.fingerList[0].localY <= 56 || event.fingerList[0].localY >= (this.xComponentHeight as number) - 48) {
      this.disableUpdateBrightAndVolume = true;
      return
    }

    this.disableUpdateBrightAndVolume = false;

    if (event.fingerList[0].localX >= (this.xComponentWidth as number) / 2) {
      this.volumeUtil.playerSliderModel.showVolumeProgress = true
    } else {
      this.volumeUtil.playerSliderModel.showBrightProgress = true
    }

    this.positionY = event.offsetY;
  }

  // 处理音量和亮度的滑动更新事件回调
  handleBrightAndVolumePanUpdate(event?: GestureEvent) {
    if (this.isLockScreen) {
      return
    }
    if (!event) {
      return;
    }
    if (!event.fingerList[0]) {
      return
    }
    if (this.disableUpdateBrightAndVolume) {
      return
    }
    if (event.fingerList[0].displayX >= (this.xComponentWidth as number) / 2) {
      this.onVolumeActionUpdate(event)
    } else {
      this.onBrightActionUpdate(event)
    }
  }

  // 音量
  onVolumeActionUpdate(event: GestureEvent) {
    if (!this.player) {
      return;
    }
    const canOperateState: string[] = [
      AVPlayerState.PREPARED, AVPlayerState.PLAYING, AVPlayerState.PAUSED, AVPlayerState.COMPLETED,
    ];
    if (canOperateState.indexOf(this.player.state) === -1) {
      return;
    }
    let changeVolume = (this.positionY - event.offsetY) / (this.xComponentHeight as number)
    let currentVolume = this.volumeUtil.playerSliderModel.volume + changeVolume;
    let endVolume = Math.min(Math.max(0, currentVolume), 1);
    // 处理音量进度的显隐变化
    this.volumeUtil.handleVolumeProgressChange()
    this.volumeUtil.offVolumeChangeListen();
    this.volumeUtil.playerSliderModel.onSliderChange(0, endVolume, SliderChangeMode.Moving);
    this.positionY = event.offsetY;
  }

  // 亮度更新
  onBrightActionUpdate(event: GestureEvent) {
    if (this.volumeUtil.playerSliderModel.bright !== -1 && this.volumeUtil.playerSliderModel.bright < 0) {
      this.volumeUtil.playerSliderModel.bright = 0
    }
    if (this.volumeUtil.playerSliderModel.bright > 1) {
      this.volumeUtil.playerSliderModel.bright = 1
    }
    this.volumeUtil.playerSliderModel.showBrightProgress = true
    this.volumeUtil.playerSliderModel.showVolumeProgress = false;
    this.volumeUtil.offVolumeChangeListen();
    let changeBright = (this.positionY - event.offsetY) / (this.xComponentHeight as number)
    let currentBright = this.volumeUtil.playerSliderModel.bright + changeBright;
    let endBright = Math.min(Math.max(0, currentBright), 1);
    this.volumeUtil.playerSliderModel.onSliderChange(1, endBright, SliderChangeMode.Moving);
    this.positionY = event.offsetY;
  }

  onActionEnd() {
    if (this.isLockScreen) {
      return
    }
    this.volumeUtil.playerSliderModel.showVolumeProgress = false
    this.volumeUtil.playerSliderModel.showBrightProgress = false
    this.volumeUtil.onVolumeChangeListen()
  }

  // 进度条
  handleProgressStart(event: GestureEvent) {
    if (this.isLockScreen) {
      return
    }
    if (!event) {
      return;
    }
    this.positionX = event.offsetX;
    this.panStartTime = this.progressController.currentTime;
  }

  // 更新进度条
  handleProgressUpdate(event: GestureEvent) {
    if (this.isLockScreen) {
      return
    }
    if (!event) {
      return;
    }
    let tempTime = this.positionX + event.offsetX
    let changeTime = tempTime / this.progressController.progressWidth * this.progressController.durationTime;
    let panTime = this.panStartTime + changeTime
    this.panEndTime = Math.min(Math.max(0, panTime), this.progressController.durationTime);
    this.progressController.sliderOnChange(this.panEndTime, SliderChangeMode.Moving);
  }

  // 进度条滑动结束
  handleProgressEnd() {
    if (this.isLockScreen) {
      return
    }
    this.progressController.sliderOnChange(this.panEndTime, SliderChangeMode.End);
  }

  // 自定义动画注册
  public registerCustomTransition(
    navDestContext: NavDestinationContext,
    longTakeSession: LongTakeAnimationProperties,
  ) {
    let param = navDestContext.pathInfo?.param as Record<string, Object>;
    let longTakeTransitionParam = param.longTakeTransitionParam as LongTakeTransitionParam;
    if (longTakeTransitionParam) {
      longTakeSession.init(navDestContext, longTakeTransitionParam, {
        pop: () => {
          navDestContext.pathStack.pop(1)
        },
      });
    }
  }
}