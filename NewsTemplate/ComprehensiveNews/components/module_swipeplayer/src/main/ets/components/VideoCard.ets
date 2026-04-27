import { media } from '@kit.MediaKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { AVPlayerState, BreakpointNameEnum, PageNameEnum, VideoPlayerData } from '../type/Index'
import { handleSandboxVideoUrl, isDisplayModeFolded, secondToTime, toast } from '../utils/Util'
import { Constants } from '../constants/Constants'
import { VideoProgressBar } from './VideoProgressBar'
import { AVPlayerManager } from '../controller/AVPlayerManager'
import { AVPlayerController } from '../controller/AVPlayerController'
import { VideoCardPlayerController } from '../controller/VideoCardPlayerController'
import { VideoCardModel } from '../viewmodel/VideoCardModel'
import { VideoNetworkModel, VideoNetworkSetting } from '../models/VideoNetworkModel'
import { BreakpointModel } from '../models/BreakpointModel'
import { BaseImage } from './BaseImage'
import { Logger } from '../utils/Logger';

const TAG = '[VideoCard]';

@ComponentV2
export struct VideoCard {
  // 列表视频信息
  @Param @Require videoData: VideoPlayerData
  // List显示区域内中间子组件索引值
  @Param currentIndex: number = 0
  // 列表视频的索引
  @Param index: number = 0;
  // 组件所在页面是否显示
  @Param isShown: boolean = false
  // 是否是详情页的视频卡片
  @Param isFromDetailCard: boolean = false
  // 是否支持pip
  @Param enablePip: boolean = true;
  // 是否可以滑动进度条
  @Param canChangeSlide: boolean = false
  // 是否隐藏进度条
  @Param isHideSlide: boolean = false
  // 视频卡片控制器
  @Param videoCardPlayerController: VideoCardPlayerController = new VideoCardPlayerController()
  // 网络
  @Param videoNetwork: VideoNetworkModel | undefined = undefined
  @Param videoNetworkSetting: VideoNetworkSetting | undefined = undefined
  // 一多适配的断点
  @Param currentBreakpoint: BreakpointNameEnum = BreakpointNameEnum.SM;
  // 主题色
  @Param themeColor: string | Resource = $r('sys.color.brand');
  // 路由栈
  @Param pathStack: NavPathStack = new NavPathStack();
  // 是否横屏
  @Param isLandscape: boolean = false;
  // 是否接入播控中心
  @Param enableAVSession: boolean = false;
  // 是否支持投屏播放
  @Param enableCastPlay: boolean = false;
  // 是否允许播放
  @Param canPlay: boolean = true;
  // 全屏自定义图标
  @Param fullScreenIcon: Resource | undefined = undefined
  // 是否隐藏静音图标
  @Param isNeedMuteIcon: boolean = false
  // 是否受画中画影响，释放播放器
  @Param isNeedRelease: boolean = true
  // 视频信息view
  @BuilderParam videoInfoViewBuilder: CustomBuilder;
  @BuilderParam videoProgressBar: CustomBuilder;
  // 视频播放完后，界面展示的内容
  @Param completedBtnBuilder: WrappedBuilder<[AVPlayerController]> | undefined = undefined;
  // 提示开通会员的内容
  @Param membershipBuilder: WrappedBuilder<[() => void]> | undefined = undefined;
  @Param isMute: boolean = false
  @Param isDetailBack: boolean = false;
  // 点击title，回调事件
  @Event onClickEvent: (avPlayerController: AVPlayerController | undefined, callback: () => void) => void;
  // 播放list某个item的视频
  @Event onPlayItem: (playIndex: number) => void
  // 在移动网络下点击播放按钮，默认为是同意使用流量播放
  @Event setUseMobileData: () => void
  // 播放状态回调
  @Event playerStateCallback: (state: string, id: string) => void = () => {
  }
  // 播放进度回调
  @Event timeUpdateCallback: (timeMs: number) => void = () => {
  };
  // xComponent ready回调
  @Event xComponentReadyCallback: (controller: XComponentController) => void;
  @Event onMute: (value: boolean) => void = () => {
  };
  // 视频状态变成complete的回调
  @Event onStateComplete: () => void = () => {
  };
  // 全屏操作状态回调
  @Event onFullScreenOperation: (isStarting: boolean) => void = () => {
  };
  @Provider() showMembershipOverlay: boolean = false;
  // XComponent控制器
  private xComponentController: XComponentController = new XComponentController();
  vm: VideoCardModel = new VideoCardModel(this.getUIContext(), this.index)

  async playAVPlayer(avplayer: media.AVPlayer | undefined) {
    try {
      await avplayer?.play()
    } catch (e) {
      Logger.error(TAG, 'play fail, error: ' + JSON.stringify(e));
    }
  }

  async pauseAVPlayer(avplayer: media.AVPlayer | undefined) {
    try {
      await avplayer?.pause();
    } catch (e) {
      Logger.error(TAG, 'pause fail, error: ' + JSON.stringify(e));
    }
  }

  // 播放器状态监听
  private playerStateListener = (state: string) => {
    if (this.index === this.currentIndex && this.videoNetwork) {
      // 播放时，才能使用画中画
      if (this.enablePip && this.isFromDetailCard && this.videoNetworkSetting?.enableLivePiP) {
        this.vm.pipWindowModel.isEnablePiP = state === AVPlayerState.PLAYING
        this.vm.pipWindowModel.videoPlayerStatus = state;
        Logger.debug(TAG, 'this.vm.pipWindowModel.isEnablePiP: ' + this.vm.pipWindowModel.isEnablePiP,
          'this.vm.pipWindowModel.videoPlayerStatus: ' + this.vm.pipWindowModel.videoPlayerStatus);
      }
    }
  }
  // 准备状态监听事件
  private preparedListener = () => {
    // 自动播放开关打开，才会播放
    if (this.index === this.currentIndex && this.isShown &&
      (this.videoNetworkSetting?.autoPlayTabRecommend || this.isFromDetailCard)
    ) {
      this.playerStateCallback && this.playerStateCallback(AVPlayerState.PREPARED, this.videoData.getVideoId())
      this.vm.avPlayerController.play()
    }
  }
  // 播放状态监听
  private playingListener = () => {
    if (this.index === this.currentIndex && this.videoNetwork) {
      this.videoNetwork.canUseMobileData = true;
      // 播放状态回调
      this.playerStateCallback && this.playerStateCallback(AVPlayerState.PLAYING, this.videoData.getVideoId())
    }
  }
  // 播放进度监听
  private timeUpdateListener = (timeMs: number) => {
    this.timeUpdateCallback(timeMs);
  };
  // 播放完成状态监听事件
  private completedListeners = () => {
    this.onStateComplete();
    if (this.isFromDetailCard) {
      this.vm.isPause = true;
      return
    }
    // 设置自动播放下一个，且推荐视频自动播放开关打开，则当前视频播放完之后，继续播放下一个
    if (this.videoNetworkSetting?.autoPlayNext && this.videoNetworkSetting?.autoPlayTabRecommend) {
      this.vm.isPause = true;
      this.vm.avPlayerController.avPlayer!.seek(0, media.SeekMode.SEEK_CLOSEST);
      this.onPlayItem?.(this.currentIndex + 1)
      this.playAVPlayer(this.vm.avPlayerManager.getAVPlayer(this.currentIndex + 1))
      return
    }
    // 其他情况，重头开始播放
    this.vm.avPlayerController.play()
  }
  // 视频播放错误事件监听
  private errorListener = () => {
    if (this.videoNetwork && !this.videoNetwork.hasNet && this.vm.isBuffering) {
      toast(this.vm.uiContext!, {
        message: '网络连接不可用',
        alignment: Alignment.Center,
        textColor: Color.Red,
      })
      this.vm.isBuffering = false;
      this.vm.isPause = true;
    }
  }
  // 缓存事件监听
  private buffingUpdateListener = (infoType: media.BufferingInfoType) => {
    if (this.currentIndex === this.index) {
      if (infoType === media.BufferingInfoType.BUFFERING_START) {
        if (this.videoNetworkSetting?.autoPlayTabRecommend || this.isFromDetailCard) {
          this.vm.isPause = false;
        }
        this.vm.isBuffering = true;
      }
      if (infoType === media.BufferingInfoType.BUFFERING_END) {
        this.vm.isBuffering = false;
        if (!this.isShown) {
          this.vm.avPlayerController.pause();
        }
      }
    }
  }

  @Monitor('currentIndex')
  onIndexChanged() {
    this.onChangeListIndex();
  }

  @Monitor('videoNetwork.isNetworkAvailable', 'currentIndex')
  onCellularChange(monitor: IMonitor) {
    let isNetworkAvailable = monitor.value()?.now as boolean
    if (this.videoNetworkSetting?.remindWithoutWlan === 1) {
      this.videoNetwork!.hasUseMobileDataTip = false
    }
    if (this.currentIndex === this.index) {
      if (isNetworkAvailable && this.videoNetwork?.isCellular && !this.videoNetwork?.hasUseMobileDataTip) {
        toast(this.getUIContext(), {
          message: '正在使用流量播放',
          alignment: Alignment.Center,
        })
        if (this.videoNetwork && this.videoNetworkSetting?.remindWithoutWlan === 0) {
          this.videoNetwork.hasUseMobileDataTip = true
        }
        return
      }
      if (this.videoNetwork && this.videoNetwork.hasNet) {
        this.playAVPlayer(this.vm.avPlayerController.getAVPlayer())
      }
    }
  }

  @Monitor('videoNetwork.hasNet')
  onNetworkChange(monitor: IMonitor) {
    let hasNet = monitor.value()?.now as boolean;
    let playerState = this.vm.avPlayerController.avPlayer?.state
    if (this.currentIndex === this.index && playerState === 'idle' && hasNet) {
      this.vm.avPlayerController.avPlayer!.url = this.videoData.getVideoUrl()
    }
  }

  @Monitor('currentBreakpoint')
  onCurrentBreakpointChange(monitor: IMonitor) {
    // 设置断点
    let breakpoint = monitor.value()?.now as BreakpointNameEnum;
    this.vm.breakpointModel.currentBreakpoint = breakpoint;
  }

  @Monitor('vm.pipWindowModel.isReleaseVideoPlayer')
  onReleaseVideoPlayer() {
    Logger.debug(TAG, 'onReleaseVideoPlayer this.vm.pipWindowModel.isReleaseVideoPlayer: ' +
      this.vm.pipWindowModel.isReleaseVideoPlayer,
      'this.isNeedRelease:' + this.isNeedRelease);
    if (this.vm.pipWindowModel.isReleaseVideoPlayer && this.isNeedRelease) {
      Logger.debug(TAG, 'onReleaseVideoPlayer handlerDisappear')
      this.vm.handlerDisappear();
    }
  }

  @Monitor('vm.pipWindowModel.isPipStop', 'vm.pipWindowModel.isBackgroundPip')
  onPipStop() {
    if (this.vm.pipWindowModel.isPipStop && this.vm.pipWindowModel.isBackgroundPip) {
      Logger.debug(TAG, 'pause the avplayer, when stop the pip in background');
      this.pause();
    }
  }

  @Monitor('enableCastPlay', 'vm.pipWindowModel.isPipStop', 'vm.pipWindowModel.currentPiPVideoId')
  onPipStart() {
    if (!this.enableCastPlay) {
      return;
    }
    if (!this.vm.pipWindowModel.isPipStop && this.vm.pipWindowModel.currentPiPVideoId) {
      // 存在画中画时，禁用投屏功能
      this.vm.avSessionController.disableCast();
    } else {
      // 不存在画中画时，启用投屏功能
      this.vm.avSessionController.supportCast();
    }
  }

  @Monitor('isLandscape')
  onChangeOrientation(monitor: IMonitor) {
    const isLandscape = (monitor.value()?.now) as boolean;
    Logger.debug(TAG, 'isLandscape: ' + this.isLandscape + ', isShown:' + this.isShown + ', isClickFullScreenBtn:' +
      this.vm.isClickFullScreenBtn + ',currentBreakpoint:' + this.vm.breakpointModel.currentBreakpoint)
    if (!isLandscape) {
      this.vm.isClickFullScreenBtn = false;
      return
    }

    // 获取当前页面，避免重复进入
    const allPathNames = this.pathStack.getAllPathName();
    const lastPath = allPathNames.length > 0 ? allPathNames[allPathNames.length - 1] : '';
    if (lastPath === PageNameEnum.VIDEO_LANDSCAPE_PAGE) {
      Logger.debug(TAG, 'current already landScapePage');
      return;
    }
    const isFoldMode = isDisplayModeFolded();
    // 自动横屏：组件处于显示状态、横屏、当前索引视频、不是通过点击全屏按钮的横屏、直板机（折叠屏折叠态）状态下
    if (isLandscape && this.isShown && !this.vm.isClickFullScreenBtn &&
      (this.vm.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM || isFoldMode)
    ) {
      Logger.debug(TAG, 'auto fullscreen');
      this.onFullScreenOperation(true);
      this.handleFullScreen(false);
    }
  }

  @Monitor('canPlay')
  onAccessPlayChange() {
    if (this.canPlay) {
      this.vm.avSessionController.setListener({ play: this.vm.sessionListener.play })
    } else {
      this.vm.avSessionController.releasePlayListener();
    }
  }

  @Monitor('isHideSlide')
  onHideSlideChange() {
    this.vm.isHideSlide = this.isHideSlide;
  }

  @Computed
  get durationStringTime() {
    const durationTime = Math.floor(this.videoData.getVideoDuration() / 1000)
    return secondToTime(durationTime);
  }

  aboutToAppear() {
    Logger.debug(TAG, 'aboutToAppear, isFromDetailCard:' + this.isFromDetailCard + ', news title: ' +
      this.videoData.getVideoTitle());

    if (this.isFromDetailCard) {
      this.vm.avPlayerManager = new AVPlayerManager()
    }
    this.vm.globalConfigModel.themeColor = this.themeColor;
    this.vm.breakpointModel.currentBreakpoint = this.currentBreakpoint
    this.vm.videoNetwork = this.videoNetwork
    this.vm.enableAVSession = this.enableAVSession
    this.vm.enableCastPlay = this.enableCastPlay
    this.vm.isHideSlide = this.isHideSlide
    this.vm.setPathStack(this.pathStack);
    this.vm.initPlayerManager(this.videoData)
    this.vm.initXComponentId()
    // 播放器状态监听
    this.vm.onPlayerStateListener(this.playerStateListener);
    // 准备状态监听事件
    this.vm.onPreparedListener(this.preparedListener);
    // 视频播放状态监听事件
    this.vm.onPlayingListener(this.playingListener);
    // 视频进度监听
    this.vm.onTimeUpdateListener(this.timeUpdateListener);
    // 完成状态监听事件
    this.vm.onCompletionListener(this.completedListeners);
    // 播放错误状态监听事件
    this.vm.onErrorListener(this.errorListener);
    // 缓存事件监听
    this.vm.onBuffingUpdateListener(this.buffingUpdateListener);
    // 监听首帧事件
    this.vm.onStartRenderFrameListener(() => {
      if (this.index === this.currentIndex) {
        this.vm.showCover = false;
      }
    })
    // 视频尺寸变化监听
    this.vm.onVideoSizeChangedListener(() => {
      this.vm.adaptiveVideoSize()
    })

    // 网络是否可用
    this.handlerNetwork()
    this.vm.handleAVSession(this.getUIContext().getHostContext() as Context);

    // 绑定控制器
    this.vm.videoCardPlayerController = this.videoCardPlayerController;
    this.videoCardPlayerController.pause = (): void => this.pause();
    this.videoCardPlayerController.play = (): void => this.play();
    this.videoCardPlayerController.reset = (): void => {
      this.vm.avPlayerController?.reset();
    };
    this.videoCardPlayerController.seek = (seekTime: number): void => this.seek(seekTime);
    this.videoCardPlayerController.switchPlayPause = (): void => this.switchPlayPause();
    this.videoCardPlayerController.videoUrlChange =
      (videoData: VideoPlayerData): void => this.videoUrlChange(videoData);
    this.videoCardPlayerController.getAvplayer = (): media.AVPlayer | undefined => this.vm.avPlayerController.avPlayer
  }

  aboutToDisappear(): void {
    Logger.debug(TAG, 'aboutToDisappear, news title: ' + this.videoData.getVideoTitle());
    this.vm.handlerDisappear();
  }

  pause() {
    this.vm.avPlayerController?.pause()
  }

  seek(seekTime: number) {
    this.vm.avPlayerController?.seek(seekTime)
  }

  play() {
    this.vm.avPlayerController?.play()
  }

  // 处理无网络情况
  handlerNetwork() {
    // 无网络且没有提示过，则提示
    if (this.videoNetwork && !this.videoNetwork.hasNet && !this.videoNetwork.hasOfflineTip) {
      toast(this.vm.uiContext!, {
        message: '网络连接不可用',
        alignment: Alignment.Center,
        textColor: Color.Red,
      })
      this.videoNetwork.hasOfflineTip = true
    }
  }

  onChangeListIndex() {
    // 当前是移动流量，且不允许使用移动流量播放
    let disabledPlay = this.videoNetwork && this.videoNetwork.isCellular && !this.videoNetwork.canUseMobileData
    if (this.index !== this.currentIndex || disabledPlay) {
      this.vm.isPause = true;
      this.vm.avPlayerController.pause();
      return;
    }
    this.vm.isPause = false;
    if (this.vm.avPlayerController.getAVPlayer()) {
      let canPlayStates = [
        AVPlayerState.PREPARED,
        AVPlayerState.PAUSED,
        AVPlayerState.COMPLETED,
      ] as media.AVPlayerState[]
      if (canPlayStates.includes(this.vm.avPlayerController.avPlayer?.state!)) {
        this.vm.avPlayerController.avPlayer?.setSpeed(1);
        this.vm.avPlayerController.play();
        return
      }
      // 有网络
      if (this.videoNetwork?.hasNet) {
        this.vm.avPlayerController.avPlayer!.url = this.videoData.getVideoUrl();
      }
    }
  }

  // 视频播放
  async onClickVideo() {
    if (this.vm.isPause && this.videoNetwork && !this.videoNetwork.hasNet) {
      toast(this.getUIContext(), {
        message: '网络连接不可用',
        alignment: Alignment.Center,
      })
      return;
    }
    if (this.vm.isPause && this.videoNetwork?.hasNet) {
      this.pauseAVPlayer(this.vm.avPlayerManager.getAVPlayer(this.currentIndex))
      this.onPlayItem?.(this.index);

      if (this.vm.avPlayerController.getAVPlayer()) {
        let playerState = this.vm.avPlayerController.avPlayer?.state;
        // idle状态
        if (playerState === AVPlayerState.IDLE) {
          this.vm.avPlayerController.avPlayer!.url = this.videoData.getVideoUrl();
          return;
        }
        await this.vm.avPlayerController.play()
      } else {
        await this.vm.initAVPlayer();
      }
    }
  }

  // 跳转详情页
  pushToVideoDetailPage() {
    let avPlayer = this.vm.avPlayerController?.avPlayer;
    let callback = async () => {
      if (this.index === this.currentIndex) {
        avPlayer!.surfaceId = this.vm.surfaceId;
        this.vm.avPlayerController!.avPlayer = avPlayer
        this.vm.showCover = false;
        this.vm.isPause = false;
        this.vm.onCompletionListener(this.completedListeners);
        this.vm.initPlayerListener(this.vm.avPlayerController.avPlayer!)
        // 退出详情页时，推荐页面需要播放视频
        await this.vm.avPlayerController?.pause();
        await this.vm.avPlayerController?.play();
      }
    }
    this.onClickEvent?.(this.vm.avPlayerController, callback)
  }

  // 处理点击卡片title
  async handleClickItemCard() {
    await this.onClickVideo()
    this.pushToVideoDetailPage()
  }

  switchPlayPause() {
    if (!this.vm.isBuffering && this.isFromDetailCard) {
      let playerState = this.vm.avPlayerController.avPlayer?.state;
      if (playerState === AVPlayerState.PLAYING) {
        this.vm.avPlayerController.pause()
      } else {
        this.onClickVideo()
      }
    }
  }

  videoUrlChange(videoData: VideoPlayerData) {
    if (this.vm.avPlayerController.avPlayer) {
      this.vm.avPlayerController.avPlayer!.reset().then(() => {
        if (videoData.getVideoUrl().startsWith('http')) {
          this.vm.avPlayerController.avPlayer!.url = videoData.getVideoUrl();
        } else {
          this.vm.avPlayerController.avPlayer!.url = 'fd://' + handleSandboxVideoUrl(videoData.getVideoUrl());
        }
        this.vm.setVideoData(videoData);
      }).catch((e: BusinessError) => {
        Logger.error(TAG, 'reset fail, error: ' + JSON.stringify(e));
      });
    }
  }

  // 处理横屏按钮事件
  async handleFullScreen(isSetOrientation: boolean = true) {
    let param: Record<string, Object | VideoCardPlayerController | AVPlayerController
      | BreakpointModel | boolean | WrappedBuilder<[() => void]>> = {};
    param.avPlayerController = this.vm.avPlayerController;
    param.surfaceId = this.vm.surfaceId;
    param.videoWidth = this.vm.videoWidth;
    param.videoHeight = this.vm.videoHeight;
    param.videoTitle = this.videoData.getVideoTitle();
    param.breakpointModel = this.vm.breakpointModel;
    param.isMute = this.isMute;
    param.isHideSlide = this.isHideSlide;
    param.videoCardPlayerController = this.videoCardPlayerController;
    param.isFromDetailCard = this.isFromDetailCard;
    if (this.membershipBuilder) {
      param.membershipBuilder = this.membershipBuilder;
    }
    // 视频播放，跨页面流转
    this.vm.pipWindowModel.navDestinationUpdateListeners.clear();
    this.vm.pipWindowModel.navDestinationUpdateListeners.set('landscapeListener', (info) => {
      if (info.name === PageNameEnum.VIDEO_LANDSCAPE_PAGE && info.state === 3) {
        let avPlayer = (param.avPlayerController as AVPlayerController).getAVPlayer() as media.AVPlayer;
        if (avPlayer) {
          avPlayer.surfaceId = param.surfaceId as string;
        }
      }
    })
    if (isSetOrientation) {
      await this.vm.handleOrientation();
      this.vm.isClickFullScreenBtn = true;
    }
    this.vm.breakpointModel.isLandscapeAuto = !isSetOrientation;
    this.vm.pushToLandscapePage(param, 'videoCard' + this.index);
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        // 视频播放
        XComponent({
          id: this.vm.xComponentId,
          type: XComponentType.SURFACE,
          controller: this.xComponentController,
        })
          .aspectRatio(Number(this.vm.videoWidth) / Number(this.vm.videoHeight))
          .onLoad(() => {
            let surfaceId = this.xComponentController.getXComponentSurfaceId();
            // 设置视频窗口ID
            this.vm.setSurfaceId(surfaceId)
            // 初始化
            this.vm.initAVPlayer();
            this.xComponentReadyCallback?.(this.xComponentController);
          })

        // 封面
        if (this.vm.showCover && this.videoData.getCoverUrl()) {
          BaseImage({
            url: this.videoData.getCoverUrl(),
            videoNetwork: this.videoNetwork,
            videoNetworkSetting: this.videoNetworkSetting,
          })
            .width(Constants.FULL_PERCENT)
            .onAreaChange((_ov: Area, nv: Area) => {
              this.vm.coverImgHeight = nv.height
            })
        }
        if (this.isFromDetailCard && this.vm.isCompleted) {
          this.completedBtnBuilder?.builder(this.vm.avPlayerController)
        } else {
          if (this.vm.isPause) {
            Image($r('app.media.ic_paused'))
              .width(44)
              .height(44)
          }
        }
        // 缓冲中
        if (this.vm.isBuffering && this.index === this.currentIndex) {
          Column() {
            LoadingProgress()
              .width(40)
              .height(40)
              .color($r('sys.color.icon_on_primary'));
            Text('缓冲中...')
              .fontSize(12)
              .fontColor(Color.White)
          }
        }

        RelativeContainer() {
          // 进度条
          Column() {
            // 视频的进度控制器
            VideoProgressBar({
              avPlayerController: this.vm.avPlayerController,
              canChangeSlide: this.canChangeSlide,
              isHideSlide: this.isHideSlide,
              isProgressFullWidth: !this.isFromDetailCard,
              showSlideBlock: this.isFromDetailCard,
              selectedColor: this.isFromDetailCard ? Color.White : $r('app.color.slide_selected_color'),
              showProgressBarLeft: this.isFromDetailCard,
              showProgressBarRight: this.isFromDetailCard,
              trackColor: this.isFromDetailCard ?
                $r('app.color.landscape_slide_track_color') : $r('app.color.slide_default_track_color'),
              slideHeight: this.isFromDetailCard ? 20 : 14,
              fullScreenIcon: this.fullScreenIcon,
              isNeedMuteIcon: this.isNeedMuteIcon,
              isMute: this.isMute,
              onMute: (value) => {
                this.onMute(value)
              },
              onSwitchPlayCallback: () => {
                this.switchPlayPause()
              },
              onSwitchFullScreenCallback: async () => {
                Logger.debug(TAG, 'start switch full screen');
                // 状态锁 如果详情页触发了返回，则屏蔽全屏按钮点击事件
                if (this.isDetailBack) {
                  Logger.debug(TAG, 'switch full screen block: isDetailBack is true');
                  return;
                }

                this.onFullScreenOperation(true);

                try {
                  await this.vm.pipWindowModel?.pipController?.stopPiP();
                } catch (e) {
                  Logger.error(TAG, 'Fail to stopPiP, error: ' + JSON.stringify(e));
                }

                // 延迟进入全屏页面，等待pip对应的VideoCard销毁
                setTimeout(() => {
                  if (this.isFromDetailCard && this.pathStack) {
                    Logger.debug(TAG, 'hand fullscreen');
                    this.handleFullScreen();
                  }
                }, 100);
              },
            })
          }
          .visibility(this.index === this.currentIndex ? Visibility.Visible : Visibility.Hidden)
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            middle: { anchor: '__container__', align: HorizontalAlign.Center },
          })

          if (!this.isFromDetailCard) {
            Text(this.durationStringTime)
              .fontSize(10)
              .fontColor($r('sys.color.white'))
              .padding(4)
              .borderRadius(4)
              .backgroundColor($r('app.color.color_black_40'))
              .offset({ bottom: 8, right: 12 })
              .visibility(this.vm.isPause ? Visibility.Visible : Visibility.Hidden)
              .alignRules({
                bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
                right: { anchor: '__container__', align: HorizontalAlign.End },
              })
          }
        }
        .aspectRatio(Number(this.vm.videoWidth) / Number(this.vm.videoHeight))
        .onClick(() => {
          let playerState = this.vm.avPlayerController.avPlayer?.state;
          if (playerState === AVPlayerState.PLAYING) {
            this.pushToVideoDetailPage()
          } else {
            this.onClickVideo()
          }
        })

        // 流量提示
        if (this.currentIndex === this.index && this.videoNetwork &&
          this.videoNetwork.isCellular && !this.videoNetwork.canUseMobileData
        ) {
          Column({ space: Constants.SPACE_M }) {
            Row({ space: Constants.SPACE_S }) {
              Image($r('app.media.ic_playback')).width(12).height(13)
              Text('继续播放')
                .fontSize(14)
                .fontColor(Color.White)
                .lineHeight(20)
            }
            .padding({
              left: 10,
              right: 10,
              top: 4,
              bottom: 4,
            })
            .borderRadius(20)
            .backgroundColor('#1b1a1b')
            .onClick(() => {
              this.setUseMobileData && this.setUseMobileData()
              this.vm.playVideoWithMobileData()
            })

            Text('当前非Wi-Fi网络，继续播放将产生流量费用')
              .fontSize(14)
              .fontColor(Color.White)
              .lineHeight(20)
          }
          .width(Constants.FULL_PERCENT)
          .height(this.vm.coverImgHeight)
          .backgroundColor(Color.Black)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width(Constants.FULL_PERCENT)
      .onSizeChange(() => {
        this.vm.adaptiveVideoSize()
      })

      // 视频信息view
      if (this.videoInfoViewBuilder) {
        Row() {
          this.videoInfoViewBuilder()
        }
        .onClick(() => {
          this.handleClickItemCard()
        })
      }
    }
    .width(Constants.FULL_PERCENT)
    .id('videoCard' + this.index)
  }
}