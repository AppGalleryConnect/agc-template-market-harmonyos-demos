import { uiObserver, UIUtils, window, AppStorageV2 } from '@kit.ArkUI';
import { Context } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  BreakpointNameEnum,
  CircleButtonModifier,
  CommonConstants,
  CommonDataSource,
  RouterMap,
  RouterUtils,
  GridRowColSetting,
  Logger,
  GlobalContextUtils,
} from 'lib_common'
import { AVSessionUtils, VideoPipViewModel } from 'lib_av_details';
import {
  AVPlayerController,
  PiPWindowModel,
  VideoCard,
  VideoNetworkModel,
  VideoNetworkSetting,
} from 'module_swipeplayer';
import { LongTakeAnimationProperties } from 'module_transition';
import { CommentInfo } from 'module_feedcomment';
import { TabNav } from '../models/VideoModel';
import { VideoNewsData } from '../models/VideoModel';
import { LivestreamDetailPageVM } from '../viewmodels/LivestreamDetailPageVM';
import { IntroductionView } from '../views/IntroductionView';
import { LiveCommentView, LivestreamCommentListScroller } from '../views/LiveCommentView';
import { LivestreamFooterView } from '../components/LivestreamFooterView';
import { setOrientation } from '../commons/Util';

@Builder
export function LivestreamDetailPageBuilder() {
  LivestreamDetailPage()
}

const TAG = '[LivestreamDetailPage]';

@ComponentV2
export struct LivestreamDetailPage {
  @Local detailData: VideoNewsData | undefined = undefined;
  // 是否直播中
  @Local isLivestream: boolean = false;
  // 是否即将直播
  @Local isReservation: boolean = false;
  @Local videoAspectRatio: number = 1920 / 1080;
  @Local isDetailBack: boolean = false; // 状态锁：是否正在触发页面返回
  @Local isEnteringFullScreen: boolean = false // 状态锁：是否正在进入全屏
  // 路由栈
  pathStack = new NavPathStack()
  @Local pipWindowModel: PiPWindowModel = AppStorageV2.connect(PiPWindowModel, () => new PiPWindowModel())!;
  // 评论的懒加载数据源
  @Provider() commentListDataSource: CommonDataSource<CommentInfo> = new CommonDataSource<CommentInfo>();
  @Local longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Local commentListScroller: LivestreamCommentListScroller = new LivestreamCommentListScroller()
  vm: LivestreamDetailPageVM = new LivestreamDetailPageVM();
  @Local buttonModifier: CircleButtonModifier = new CircleButtonModifier();
  @Local videoPipModel: VideoPipViewModel = new VideoPipViewModel()
  private landscapeListener = (info: uiObserver.NavDestinationInfo) => {
    this.pipWindowModel.navDestinationUpdateListeners.forEach((callback, key) => {
      if (key === 'landscapeListener') {
        callback(info)
      }
    })
  }
  // WindowStage生命周期变化的监听回调函数
  private windowStageEventCallback = (type: window.WindowStageEventType) => {
    const allPathStack = RouterUtils.getStack().getAllPathName()
    const lastPathName = allPathStack[allPathStack.length - 1];
    if (lastPathName === RouterMap.LIVESTREAM_DETAIL_PAGE) {
      // 展示画中画时，判断是否是回到后台
      if (this.vm.settingInfo.network.enableLivePiP) {
        if (type === window.WindowStageEventType.RESUMED || type === window.WindowStageEventType.SHOWN) {
          this.pipWindowModel.isBackgroundPip = false;
          this.pipWindowModel.pipController?.setAutoStartEnabled(this.pipWindowModel.isEnablePiP);
          this.pipWindowModel.pipController?.stopPiP().catch((e: BusinessError) => {
            Logger.error(TAG, 'stopPiP fail, error: ' + JSON.stringify(e));
          });
        } else if (type === window.WindowStageEventType.PAUSED || type === window.WindowStageEventType.HIDDEN) {
          this.pipWindowModel.isBackgroundPip = true;
          this.pipWindowModel.isPipStop = false;
          this.pipWindowModel.pipController?.setAutoStartEnabled(this.pipWindowModel.isEnablePiP);
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

  @Computed
  get isTablet() {
    return [BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.vm.breakPointModel.currentBreakpoint);
  }

  @Computed
  get videoBoxHeight() {
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.vm.breakPointModel.currentBreakpoint)) {
      return '100%';
    }
    return 'auto';
  }

  @Computed
  get videoBoxAspectRatio() {
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.vm.breakPointModel.currentBreakpoint)) {
      return -1;
    }
    return this.videoAspectRatio;
  }

  async aboutToAppear(): Promise<void> {
    // 无感监听路由变化
    uiObserver.on('navDestinationUpdate', this.landscapeListener);
    this.videoPipModel.setContext(this.getUIContext().getHostContext() as Context)
    this.vm.windowStageModel.windowStageEventListeners.delete('livestreamDetailPage');
    this.vm.windowStageModel.windowStageEventListeners.set('livestreamDetailPage', (type) => {
      this.windowStageEventCallback(type)
    })
    // 销毁应用中其他AVSession
    await AVSessionUtils.destroyAudioSession();
    await AVSessionUtils.destroyReaderSession();
  }

  aboutToDisappear(): void {
    uiObserver.off('navDestinationUpdate', this.landscapeListener)
    this.isEnteringFullScreen = false;
    this.isDetailBack = false;
    // 清除定时器
    this.vm.clearCountdownTimer();
    this.vm.clearLiveStartTimer();
    this.vm.clearLiveEndTimer();
  }

  getTextColor(item: TabNav, index: number): ResourceColor {
    if (this.vm.indicatorIndex === index) {
      return item.activeColor
    }
    return $r('sys.color.font_primary')
  }

  onBack() {
    // 针对非即将直播类型（直播中、查看回放）开启画中画
    if (!this.isReservation) {
      this.videoPipModel.enableVideoPip(this.detailData!.id)
    }
    RouterUtils.pop(1);
  }

  build() {
    NavDestination() {
      // 头部
      this.headerBuilderView();
      GridRow({
        columns: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS,
      }) {
        GridCol({
          span: {
            sm: 4,
            md: 8,
            lg: 8,
          },
        }) {
          Column() {
            Stack({ alignContent: Alignment.Bottom }) {
              Stack({ alignContent: Alignment.TopStart }) {
                Column() {
                  if (this.detailData && this.isReservation) {
                    Image(this.detailData?.coverUrl)
                      .width(CommonConstants.FULL_PERCENT)
                  }
                  if (this.detailData && !this.isReservation) {
                    VideoCard({
                      currentIndex: 0,
                      index: 0,
                      videoData: this.detailData,
                      isShown: true,
                      enableAVSession: true,
                      videoNetwork: this.vm.networkModel as VideoNetworkModel,
                      videoNetworkSetting: this.vm.settingInfo.network as VideoNetworkSetting,
                      currentBreakpoint: this.vm.breakPointModel.currentBreakpoint,
                      videoCardPlayerController: this.videoPipModel.getVideoCardPlayerController(),
                      isFromDetailCard: true,
                      completedBtnBuilder: this.isLivestream ? undefined : wrapBuilder(completedBtnView),
                      onStateComplete: () => {
                        this.vm.isLiveEnded = true;
                      },
                      canChangeSlide: !this.isLivestream,
                      isHideSlide: this.isLivestream,
                      pathStack: this.pathStack,
                      isDetailBack: this.isDetailBack,
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
                .width('100%')
                .height(this.videoBoxHeight)
                .aspectRatio(this.videoBoxAspectRatio)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .backgroundColor(Color.Black)

                Column() {
                  // 头部
                  this.tabletHeaderView()
                  // 状态标志
                  this.indicatorView()
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)

                // 直播结束蒙层
                if (this.vm.isLiveEnded && this.isLivestream) {
                  this.liveEndedOverlayBuilder()
                }
              }

              Column() {
                // 预约区域
                if (this.isTablet && this.isReservation) {
                  this.reservationAreaBuilder()
                }
              }
              .width('100%')
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

            // 预约区域
            if (!this.isTablet && this.isReservation) {
              this.reservationAreaBuilder()
            }

            if (!this.isTablet) {
              // tab页签
              this.tabHeaderView()
              // tab内容
              this.tanContentView()
              // 底部区域
              LivestreamFooterView({
                livestreamInfo: this.vm.livestreamInfo,
                commentListScroller: this.commentListScroller,
              })
            }
          }
          .padding({
            top: this.isTablet ? this.vm.windowModel.windowTopPadding : 0,
            bottom: this.isTablet ? this.vm.windowModel.windowBottomPadding : 0,
          })
        }

        if (this.isTablet) {
          GridCol({
            span: {
              lg: 4,
            },
          }) {
            Column() {
              // tab页签
              this.tabHeaderView()
              // tab内容
              this.tanContentView()
              // 底部区域
              LivestreamFooterView({
                livestreamInfo: this.vm.livestreamInfo,
                commentListScroller: this.commentListScroller,
              })
            }
            .padding({
              top: this.vm.windowModel.windowTopPadding,
              bottom: this.vm.windowModel.windowBottomPadding,
            })
            .backgroundColor($r('sys.color.comp_background_primary'))
          }
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor(this.isTablet ? '#000000' : $r('sys.color.comp_background_primary'))
    .onReady(async (context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      let param = context.pathInfo?.param as Record<string, boolean | number | VideoNewsData>
      this.detailData = param.detailData as VideoNewsData;
      this.vm.liveStartTime = this.detailData.liveStartTime;
      this.vm.liveEndTime = this.detailData.liveEndTime;
      this.vm.calculateLiveDuration();
      this.vm.livestreamInfo = UIUtils.makeObserved(this.detailData)
      this.isLivestream = this.detailData.liveStartTime <= Date.now() && this.detailData.liveEndTime > Date.now();
      this.isReservation = this.detailData.liveStartTime > Date.now();
      this.vm.init()
      this.commentListDataSource.setData(this.vm.commentList)
      // 检查预约状态
      if (this.detailData?.id) {
        await this.vm.initReservationStatus(this.detailData.id);
      }
      // 启动倒计时
      if (Date.now() < this.detailData.liveStartTime) {
        this.vm.startCountdown();
        // 启动直播开始时间监听
        this.vm.startLiveStartTimer(() => {
          // 直播开始，切换到直播状态并开始播放
          this.isLivestream = true;
          this.isReservation = false;
          this.videoPipModel.getVideoCardPlayerController().play();
          GlobalContextUtils.showToast({ message: '直播已开始' });
          // 启动直播结束时间监听
          this.vm.startLiveEndTimer(() => {
            // 直播结束，暂停视频并显示结束蒙层
            this.videoPipModel.getVideoCardPlayerController().pause();
            this.vm.isLiveEnded = true;
          });
        });
      } else if (this.isLivestream) {
        // 如果当前已经是直播状态，启动直播结束时间监听
        this.vm.startLiveEndTimer(() => {
          // 直播结束，暂停视频并显示结束蒙层
          this.videoPipModel.getVideoCardPlayerController().pause();
          this.vm.isLiveEnded = true;
        });
      }
      this.vm.registerCustomTransition(this.longTakeSession, context)
    })
    .onBackPressed(() => {
      this.onBack();
      return true;
    })
    .onWillShow(() => {
      this.pipWindowModel.isBackPiP = false;
      this.isEnteringFullScreen = false;
      this.isDetailBack = false;
      setOrientation(window.Orientation.FOLLOW_DESKTOP);
    })
    .onShown(() => {
      this.videoPipModel.initVideoPip()
    })
    .onWillDisappear(() => {
      if (!this.vm.settingInfo.network.enableLivePiP) {
        this.videoPipModel.getVideoCardPlayerController().pause();
        this.pipWindowModel.pipController?.setAutoStartEnabled(false);
      }
    })
  }

  @Builder
  headerBuilderView() {
    Row() {
      Row({ space: CommonConstants.SPACE_S }) {
        Button() {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontColor([$r('sys.color.font_primary')])
            .fontWeight(FontWeight.Normal)
            .fontSize($r('app.float.normal_img_size'))
        }
        .attributeModifier(this.buttonModifier)
        .accessibilityText('返回')
        .onClick(() => {
          this.onBack();
        })

        Text(this.detailData?.title)
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
      }
      .height($r('app.float.nav_header_height'))
    }
    .padding({
      left: this.vm.breakPointModel.pagePadding,
      right: this.vm.breakPointModel.pagePadding,
      top: this.vm.windowModel.windowTopPadding,
    })
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor(Color.Transparent)
    .visibility(this.isTablet ? Visibility.None : Visibility.Visible)
  }

  @Builder
  tabletHeaderView() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontColor([$r('sys.color.white')])
          .fontWeight(FontWeight.Normal)
          .fontSize($r('app.float.normal_img_size'))
      }
      .attributeModifier(this.buttonModifier)
      .accessibilityText('返回')
      .onClick(() => {
        this.onBack();
      })
    }
    .height(56)
    .padding({ left: CommonConstants.PADDING_L })
    .alignItems(VerticalAlign.Center)
    .visibility(this.isTablet ? Visibility.Visible : Visibility.None)
  }

  @Builder
  indicatorView() {
    Row({ space: CommonConstants.SPACE_S }) {
      Row({ space: 2 }) {
        Image(this.isLivestream ? $r('app.media.ic_live') : $r('app.media.ic_playback_expired'))
          .width(this.isLivestream ? 12 : 11)
          .height(this.isLivestream ? 12 : 7)
        Text(this.isLivestream ? '直播中' : '精彩回顾')
          .fontSize(10)
          .fontColor(Color.White)
          .lineHeight(13)
      }
      .padding({
        left: 8,
        top: 3,
        right: 8,
        bottom: 3,
      })
      .borderRadius(4)
      .backgroundColor(this.isLivestream ? $r('sys.color.warning') : '#33000000')

      if (this.isLivestream) {
        Text('2078人观看')
          .fontSize(10)
          .fontColor(Color.White)
          .lineHeight(13)
          .padding({
            left: 8,
            top: 3,
            right: 8,
            bottom: 3,
          })
          .borderRadius(4)
          .backgroundColor('#33000000')
      }
    }
    .padding({ left: CommonConstants.PADDING_L, top: CommonConstants.PADDING_L })
    .visibility(this.isReservation ? Visibility.None : Visibility.Visible)

    Row() {
      Text('即将开始')
        .fontSize(10)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.app_theme'))
        .borderRadius(4)
        .width(48)
        .height(16)
        .textAlign(TextAlign.Center)
    }
    .padding({ left: CommonConstants.PADDING_L, top: CommonConstants.PADDING_L })
    .visibility(this.isReservation ? Visibility.Visible : Visibility.None)
  }

  @Builder
  tabHeaderView() {
    List({ space: CommonConstants.SPACE_L }) {
      ForEach(this.vm.tabNavs, (item: TabNav, index: number) => {
        ListItem() {
          this.tabBuilder(item, index)
        }
      }, (item: TabNav, index: number) => item.id + index)
    }
    .height(56)
    .width(CommonConstants.FULL_PERCENT)
    .listDirection(Axis.Horizontal)
    .padding({ left: CommonConstants.PADDING_L, right: CommonConstants.PADDING_L })
    .alignListItem(ListItemAlign.Start)
    .border({
      width: { bottom: 0.5 },
      color: '#33000000',
      style: BorderStyle.Solid,
    })
  }

  @Builder
  tabBuilder(item: TabNav, index: number) {
    Column() {
      Text(item.name)
        .fontColor(this.getTextColor(item, index))
        .fontSize(16)
        .fontWeight(this.vm.indicatorIndex === index ? 600 : 400)

      Row() {
      }
      .width(16)
      .height(2)
      .borderRadius(1)
      .backgroundColor(this.vm.indicatorIndex === index ? item.activeColor : '')
      .position({ left: CommonConstants.PADDING_S, bottom: CommonConstants.PADDING_S })
    }
    .justifyContent(FlexAlign.Center)
    .height(CommonConstants.FULL_PERCENT)
    .onClick(() => {
      this.vm.indicatorIndex = index;
      this.vm.currentTabIndex = index;
    })
  }

  @Builder
  tanContentView() {
    Tabs({ controller: this.vm.tabController, index: this.vm.currentTabIndex }) {
      TabContent() {
        IntroductionView()
      }

      TabContent() {
        LiveCommentView({
          commentListScroller: this.commentListScroller,
        })
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .layoutWeight(1)
    .barHeight(0)
    .scrollable(!this.vm.videoExtraInfoModel.isDisplayChange)
    .animationDuration(100)
    .onAnimationStart((_index: number, targetIndex: number, _event: TabsAnimationEvent) => {
      this.vm.handleAnimationStart(_index, targetIndex)
    })
    .onChange((index: number) => {
      this.vm.currentTabIndex = index;
    })
  }

  @Builder
  reservationAreaBuilder() {
    Row() {
      Text(`距离开播：`)
        .fontSize(12)
        .fontColor(this.isTablet ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))

      Text(`${this.vm.countdownText}`)
        .fontSize(18)
        .fontColor(this.isTablet ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .margin({ left: 4 })

      Blank()

      Button(this.vm.isReserved ? '已预约' : '预约')
        .height(28)
        .constraintSize({ minWidth: 72 })
        .fontColor(this.vm.isReserved ? $r('sys.color.font_emphasize') : $r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Body_M'))
        .backgroundColor(this.vm.isReserved ? $r('sys.color.comp_background_tertiary') : $r('app.color.app_theme'))
        .borderRadius(14)
        .padding({
          left: 8,
          right: 8,
        })
        .onClick(() => {
          if (this.detailData?.id) {
            this.vm.handleReservationClick(this.detailData.id, this.detailData.title || '', this.vm.isReserved);
          }
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.isTablet ? '#19FFFFFF' : $r('sys.color.comp_background_tertiary'))
  }

  @Builder
  liveEndedOverlayBuilder() {
    Column() {
      Text('直播已结束')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontColor($r('sys.color.font_on_primary'))
        .fontWeight(FontWeight.Medium)

      Text() {
        Span('时长:  ')
        Span(this.vm.liveDuration)
      }
      .fontSize($r('sys.float.Body_S'))
      .fontColor($r('sys.color.font_on_secondary'))
      .margin({ top: 4 })

      Button('精彩回顾')
        .width(88)
        .height(28)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor('#19FFFFFF')
        .borderRadius(14)
        .margin({ top: 16 })
        .onClick(() => {
          // 切换到回放状态
          this.isLivestream = false;
          this.vm.isLiveEnded = false;
          // 从头开始播放
          this.videoPipModel.getVideoCardPlayerController().seek(0);
          this.videoPipModel.getVideoCardPlayerController().play();
        })
    }
    .width('100%')
    .height(this.videoBoxHeight)
    .aspectRatio(this.videoBoxAspectRatio)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.Black)
  }
}

@Builder
export function completedBtnView(avPlayerController: AVPlayerController) {
  Row({ space: 8 }) {
    Image($r('app.media.ic_replay')).width(12).height(12)
    Text('重新播放')
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
  .zIndex(9)
  .onClick(() => {
    avPlayerController.play()
  })
}

@Builder
export function liveCompletedBtnView(avPlayerController: AVPlayerController) {
  Row({ space: 8 }) {
    Image($r('app.media.ic_replay')).width(12).height(12)
    Text('查看回放')
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
  .zIndex(9)
  .onClick(() => {
    avPlayerController.play()
  })
}

