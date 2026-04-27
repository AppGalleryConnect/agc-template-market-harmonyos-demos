import { ValueType } from '@kit.ArkData';
import { AppStorageV2, uiObserver, window } from '@kit.ArkUI';
import { AVCastPicker } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  CircleButtonModifier,
  CommonConstants,
  GridRowColSetting,
  Logger,
  RouterMap,
  RouterUtils,
} from 'lib_common';
import { AvModel, AvSection, HomeServiceApi } from 'lib_news_api';
import {
  PageNameEnum,
  PiPWindowModel,
  VideoCard,
  VideoNetworkModel,
  VideoNetworkSetting,
} from 'module_swipeplayer';
import { VideoData } from '../model/VideoModel';
import { VideoVM } from '../viewmodel/VideoViewModel';
import { VideoPipViewModel } from '../viewmodel/VideoPipViewModel';
import { VideoAxisList } from '../components/VideoAxisList';
import { AvViewModel } from '../viewmodel/AvViewModel';
import { membershipOverlayBuilder } from '../components/MembershipOverlay';
import { AVSessionUtils } from '../utils/AVSessionUtils';

@Builder
export function VideoProgramDetailsBuilder() {
  VideoProgramDetails()
}

const TAG = '[VideoProgramDetails]';

@ComponentV2
export struct VideoProgramDetails {
  @Local detailData: VideoData | undefined
  @Local videoDetails: AvModel | undefined
  @Local seek: number = 0
  @Local currentProgress: number = 0;
  @Local videoPipModel: VideoPipViewModel = new VideoPipViewModel()
  @Local pipWindowModel: PiPWindowModel = AppStorageV2.connect(PiPWindowModel, () => new PiPWindowModel())!;
  @Local sectionIndex: number = -1
  @Local isHideSlide: boolean = true
  @Local videoId: string = ''
  @Local isDetailBack: boolean = false; // 状态锁：是否正在触发页面返回
  @Local isEnteringFullScreen: boolean = false // 状态锁：是否正在进入全屏
  videoVM: VideoVM = new VideoVM(this.getUIContext())
  avViewModel: AvViewModel = new AvViewModel()
  buttonModifier: CircleButtonModifier = new CircleButtonModifier();
  private landscapeListener = (info: uiObserver.NavDestinationInfo) => {
    this.pipWindowModel.navDestinationUpdateListeners.forEach((callback, key) => {
      if (key === 'landscapeListener') {
        callback(info)
      }
    })
  }

  @Monitor('sectionIndex')
  sectionIndexChange() {
    this.detailData = new VideoData(this.videoDetails!.section[this.sectionIndex], this.detailData?.title)
  }

  @Monitor('canPlay')
  handlePlayAndPause() {
    // 处理视频播放暂停
    if (!this.canPlay) {
      this.videoPipModel.getVideoCardPlayerController().pause();
    }
    this.videoPipModel.getVideoCardPlayerController().setMembershipOverlay(!this.canPlay);

    // 更新画中画
    this.videoPipModel.updatePip(this.canPlay);

    // 停留在详情页时，不能播放的场景需要屏蔽自由横竖屏旋转
    const lastName = RouterUtils.getLastPathName();
    if (lastName !== PageNameEnum.VIDEO_LANDSCAPE_PAGE) {
      if (this.canPlay) {
        this.videoVM.setOrientation();
      } else {
        this.videoVM.resetOrientation();
      }
    }
  }

  // WindowStage生命周期变化的监听回调函数
  private windowStageEventCallback = (type: window.WindowStageEventType) => {
    const allPathStack = RouterUtils.getStack().getAllPathName()
    const lastPathName = allPathStack[allPathStack.length - 1];
    if (lastPathName === RouterMap.VIDEO_PROGRAM_DETAILS) {
      // 展示画中画时，判断是否是回到后台
      if (this.videoVM.settingInfo.network.enableLivePiP) {
        if (type === window.WindowStageEventType.RESUMED || type === window.WindowStageEventType.SHOWN) {
          this.pipWindowModel.isBackgroundPip = false;
          this.pipWindowModel.pipController?.setAutoStartEnabled(this.pipWindowModel.isEnablePiP);
          this.pipWindowModel.pipController?.stopPiP().catch((e: BusinessError) => {
            Logger.error(TAG, `Failed to stopPiP. Code: ${e.code}, message: ${e.message}`);
          });
          Logger.debug(TAG, 'WindowStageEventType.SHOWN');
        } else if (type === window.WindowStageEventType.PAUSED || type === window.WindowStageEventType.HIDDEN) {
          this.pipWindowModel.isBackgroundPip = true;
          this.pipWindowModel.isPipStop = false;
          this.pipWindowModel.pipController?.setAutoStartEnabled(this.pipWindowModel.isEnablePiP);
          Logger.debug(TAG, 'WindowStageEventType.HIDDEN, setAutoStartEnabled: ' + this.pipWindowModel.isEnablePiP);
        }
      } else {
        // 不展示画中画时，保持原有逻辑
        if (type === window.WindowStageEventType.RESUMED || type === window.WindowStageEventType.SHOWN) {
          this.videoPipModel.getVideoCardPlayerController().play()
        } else if (type === window.WindowStageEventType.PAUSED || type === window.WindowStageEventType.HIDDEN) {
          this.videoPipModel.getVideoCardPlayerController().pause()
        }
      }
    }
  }

  async aboutToAppear(): Promise<void> {
    // 无感监听路由变化
    uiObserver.on('navDestinationUpdate', this.landscapeListener);
    this.videoPipModel.setContext(this.getUIContext().getHostContext() as Context)
    this.videoVM.windowStageModel.windowStageEventListeners.delete('VideoProgramDetails');
    this.videoVM.windowStageModel.windowStageEventListeners.set('VideoProgramDetails', (type) => {
      this.windowStageEventCallback(type)
    });
    // 销毁应用中其他AVSession
    await AVSessionUtils.destroyAudioSession();
    await AVSessionUtils.destroyReaderSession();
  }

  aboutToDisappear(): void {
    Logger.debug(TAG, 'aboutToDisappear');
    uiObserver.off('navDestinationUpdate', this.landscapeListener);
    this.isEnteringFullScreen = false;
    this.isDetailBack = false;
  }

  backIntercept() {
    Logger.debug(TAG, 'start backIntercept');
    // 避免重复触发返回
    if (this.isDetailBack) {
      Logger.debug(TAG, 'backIntercept blocked: isDetailBack: true');
      return;
    }
    this.isDetailBack = true;

    // 检查全局标志位，如果正在进行全屏操作，阻止返回操作
    if (this.isEnteringFullScreen) {
      Logger.debug(TAG, 'backIntercept blocked: isEnteringFullScreen is true');
      return;
    }

    this.videoPipModel.enableVideoPip(this.videoDetails!.id);
    RouterUtils.pop(this.videoDetails);
  }

  @Computed
  get canPlay() {
    // 隐藏进度条表示电视直播的场景
    if (this.isHideSlide) {
      return true;
    }
    // 非vip视频
    if (!this.detailData?.needVip) {
      return true;
    }
    // 登录且开通了会员
    if (this.videoVM.userInfoModel.isLogin && this.videoVM.userInfoModel.isMembership) {
      return true;
    }
    // 免费看前30s
    if (this.currentProgress <= 30 * 1000) {
      return true;
    }

    return false;
  }

  @Builder
  videoInfo() {
    Column({ space: 12 }) {
      Column({ space: 4 }) {
        Text(this.detailData?.title)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(16 * this.videoVM.settingInfo.fontSizeRatio)
          .fontWeight(FontWeight.Medium)
        Text(this.detailData?.updateTime)
          .fontColor($r('sys.color.font_tertiary'))
          .fontSize(12 * this.videoVM.settingInfo.fontSizeRatio)
          .fontWeight(FontWeight.Regular)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row({ space: 12 }) {
          Image(this.videoDetails?.coverUrl)
            .width(40)
            .height(40)
            .borderRadius('50%')
            .clip(true)
          Text(this.videoDetails?.title)
            .fontColor($r('sys.color.font_primary'))
            .fontSize(16 * this.videoVM.settingInfo.fontSizeRatio)
            .fontWeight(FontWeight.Medium)
        }

        Button(this.videoDetails?.isFollow ? '已订阅' : '订阅')
          .fontColor(this.videoDetails?.isFollow ? $r('sys.color.font_emphasize') : $r('sys.color.font_on_primary'))
          .fontSize(14 * this.videoVM.settingInfo.fontSizeRatio)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.videoDetails?.isFollow ? $r('sys.color.comp_background_tertiary') : '#5C79D9')
          .width(72)
          .height(28)
          .padding(0)
          .onClick(() => {
            this.avViewModel.followOperation(this.videoDetails!)
          })

      }
    }
    .width('100%')
    .margin({ top: 8, bottom: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  customCastBuilder() {
    Button() {
      SymbolGlyph($r('sys.symbol.wireless_projection'))
        .fontColor([$r('sys.color.font_on_primary')])
        .fontWeight(FontWeight.Normal)
        .fontSize(24)
    }
    .attributeModifier(this.buttonModifier)
    .backgroundColor($r('app.color.circle_btn_bg'))
    .accessibilityText('投屏')
  }

  @Builder
  titleBar() {
    Row({ space: CommonConstants.SPACE_S }) {
      Row({ space: 2 }) {
        Button() {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontColor([$r('sys.color.font_on_primary')])
            .fontWeight(FontWeight.Normal)
            .fontSize(24 * this.videoVM.settingInfo.fontSizeRatio)
        }
        .attributeModifier(this.buttonModifier)
        .backgroundColor($r('app.color.circle_btn_bg'))
        .accessibilityText('返回')
        .onClick(() => {
          this.backIntercept()
        })
      }

      Blank()

      AVCastPicker({
        customPicker: () => this.customCastBuilder(),
      })
        .width(40)
        .height(40)
        .visibility(this.canPlay ? Visibility.Visible : Visibility.Hidden)
    }
    .padding({
      left: CommonConstants.PADDING_L,
      right: CommonConstants.PADDING_L,
      top: CommonConstants.PADDING_S,
    })
    .width(CommonConstants.FULL_PERCENT)
  }

  @Builder
  ContentBuilder() {
    Column() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({
          span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
        }) {
          Column() {
            Stack({ alignContent: Alignment.TopStart }) {
              Column() {
                if (this.videoDetails) {
                  VideoCard({
                    currentIndex: 0,
                    index: 0,
                    videoData: this.detailData,
                    isShown: true,
                    isLandscape: this.videoVM.displayModel.isLandscape,
                    videoNetwork: this.videoVM.networkModel as VideoNetworkModel,
                    videoNetworkSetting: this.videoVM.settingInfo.network as VideoNetworkSetting,
                    currentBreakpoint: this.videoVM.breakPointModel.currentBreakpoint,
                    videoCardPlayerController: this.videoPipModel.getVideoCardPlayerController(),
                    membershipBuilder: wrapBuilder(membershipOverlayBuilder),
                    isFromDetailCard: true,
                    canChangeSlide: true,
                    isHideSlide: this.isHideSlide,
                    pathStack: RouterUtils.getStack(),
                    themeColor: $r('app.color.app_theme'),
                    enableAVSession: true,
                    enableCastPlay: true,
                    canPlay: this.canPlay,
                    fullScreenIcon: $r('app.media.ic_sys_full_screen'),
                    isNeedMuteIcon: true,
                    isMute: this.videoVM.isMute,
                    isDetailBack: this.isDetailBack,
                    onMute: (value) => {
                      this.videoVM.setMute(value)
                    },
                    playerStateCallback: (state: string, id: string) => {
                      if (id === this.detailData?.id && state === 'prepared') {
                        if (this.seek) {
                          this.videoPipModel.videoCardPlayerController.seek(this.seek);
                          this.currentProgress = this.seek;
                        }
                      }
                    },
                    timeUpdateCallback: (timeMs: number) => {
                      this.currentProgress = timeMs;
                    },
                    xComponentReadyCallback: (controller: XComponentController) => {
                      this.videoPipModel.setMXComponentController(controller)
                      this.videoPipModel.handlePip()
                    },
                    onFullScreenOperation: (isStarting: boolean) => {
                      this.isEnteringFullScreen = isStarting;
                    },
                  })
                }
              }
              .width(CommonConstants.FULL_PERCENT)
              .height(this.videoVM.videoBoxHeight)
              .aspectRatio(this.videoVM.videoBoxAspectRatio)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .backgroundColor(Color.Black)

              if (!this.canPlay) {
                Column() {
                  membershipOverlayBuilder(() => {
                    this.currentProgress = 0;
                    this.videoPipModel.getVideoCardPlayerController().seek(0);
                    this.videoPipModel.getVideoCardPlayerController().play();
                  })
                }
                .width(CommonConstants.FULL_PERCENT)
                .height(this.videoVM.videoBoxHeight)
                .aspectRatio(this.videoVM.videoBoxAspectRatio)
              }

              this.titleBar()
            }
            .priorityGesture(
              GestureGroup(GestureMode.Exclusive,
                // 双击暂停或播放
                TapGesture({ count: 2 })
                  .onAction((event: GestureEvent) => {
                    if (!event) {
                      return
                    }
                    this.videoPipModel.getVideoCardPlayerController().switchPlayPause()
                  }),
              ),
            )
          }
        }

        GridCol({
          span: {
            sm: 8,
            md: 8,
            lg: 4,
            xl: 4,
          },
        }) {
          Column() {
            this.videoInfo()
            Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
              Text('往期节目')
                .fontColor($r('sys.color.font_primary'))
                .fontSize(18 * this.videoVM.settingInfo.fontSizeRatio)
                .fontWeight(FontWeight.Bold)
              Row() {
                Text('全部')
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize(14 * this.videoVM.settingInfo.fontSizeRatio)
                  .fontWeight(FontWeight.Regular)
                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontColor([$r('sys.color.font_secondary')])
                  .fontWeight(FontWeight.Normal)
                  .fontSize(14 * this.videoVM.settingInfo.fontSizeRatio)
              }
              .onClick(() => {
                this.videoPipModel.videoCardPlayerController.pause()
                const params: Record<string, ValueType> = {
                  'videoId': this.videoDetails!.id,
                  'sectionIndex': this.sectionIndex,
                }
                RouterUtils.pushPathByName(RouterMap.VIDEO_PROGRAM_HISTORY, params, (popInfo: PopInfo) => {
                  const result = popInfo.result as AvSection;
                  const videoData = new VideoData(result, this.videoDetails?.title);
                  this.videoPipModel.videoCardPlayerController.videoUrlChange(videoData);
                  this.sectionIndex = this.videoDetails?.section.findIndex(val => val.id === result.id) ?? -1
                })
              })
            }
            .margin({ bottom: 8 })

            VideoAxisList({
              videoDetails: this.videoDetails,
              fontSizeRatio: this.videoVM.settingInfo.fontSizeRatio,
              isTvDetails: true,
              sectionIndex: this.sectionIndex!!,
              onVideoChange: (item: AvSection) => {
                const videoData = new VideoData(item, this.videoDetails?.title);
                this.videoPipModel.videoCardPlayerController.videoUrlChange(videoData);
                this.isHideSlide = false;
              },
            })
          }
          .layoutWeight(1)
          .padding({ left: 16, right: 16 })
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)
    }
    .backgroundColor($r('sys.color.background_primary'))
  }

  build() {
    NavDestination() {
      this.ContentBuilder()
    }
    .hideTitleBar(true)
    .onReady(async (context) => {
      const params = context.pathStack.getParamByName('VideoProgramDetails')[0] as Record<string, ValueType>
      this.videoId = params.avId as string
      this.seek = params.seek as number
      const videoDetails = await HomeServiceApi.queryHomeTelevisionDetails(this.videoId) as AvModel
      this.videoDetails = new AvModel(videoDetails)
      this.detailData = new VideoData(this.videoDetails.section[0], this.videoDetails.title)
      this.videoPipModel.initVideoPip()
    })
    .onBackPressed(() => {
      this.backIntercept()
      return true
    })
    .padding({
      top: this.videoVM.windowModel.windowTopPadding,
    })
    .onWillShow(() => {
      this.pipWindowModel.isBackPiP = false;
      this.isEnteringFullScreen = false;
      this.isDetailBack = false;
      if (this.canPlay) {
        this.videoVM.setOrientation();
      } else {
        this.videoVM.resetOrientation();
      }
    })
    .onWillDisappear(() => {
      if (!this.videoVM.settingInfo.network.enableLivePiP) {
        this.videoPipModel.getVideoCardPlayerController().pause();
        this.pipWindowModel.pipController?.setAutoStartEnabled(false);
      }
      this.pipWindowModel.isBackPiP = true;
      this.videoVM.resetOrientation();
    })
  }
}