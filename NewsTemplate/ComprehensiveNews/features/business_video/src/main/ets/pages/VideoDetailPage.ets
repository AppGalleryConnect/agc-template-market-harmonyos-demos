import { common } from '@kit.AbilityKit';
import { uiObserver, window } from '@kit.ArkUI'
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import {
  CircleButtonModifier,
  CommonConstants,
  GlobalContextUtils,
  GridRowColSetting,
  Logger,
  NetworkUtil,
  RouterMap,
  RouterUtils,
  SystemBarOperation,
} from 'lib_common';
import { NewsResponse } from 'lib_news_api';
import { NetworkExceptionView } from 'lib_widget';
import { NewsSearchEntry } from 'lib_search';
import {
  AVPlayerController,
  EventKey,
  VideoNetworkModel,
  VideoNetworkSetting,
  VideoPlayerData,
  VideoSwipePlayer,
} from 'module_swipeplayer';
import { CardLongTakeDelegate, LongTakeAnimationProperties } from 'module_transition';
import { VideoNewsData } from '../models/VideoModel';
import { VideoLayerViewBuilder } from '../components/VideoLayerView';
import { VideoDetailPageModel } from '../models/VideoDetailPageModel';
import { BaseParamType } from '../types/Index';
import { CommentView } from '../components/CommentView';

@Builder
export function VideoDetailBuilder() {
  VideoDetailPage()
}

const TAG = '[VideoDetailPage]';

@ComponentV2
export struct VideoDetailPage {
  pathStack = new NavPathStack()
  // 数据源
  @Local videoList: VideoNewsData[] = [];
  @Local longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  buttonModifier: CircleButtonModifier = new CircleButtonModifier();
  vm: VideoDetailPageModel = new VideoDetailPageModel()
  // WindowStage生命周期变化的监听回调函数
  private windowStageEventCallback = (type: window.WindowStageEventType) => {
    const allPathStack = this.pathStack.getAllPathName()
    const lastPathName = allPathStack[allPathStack.length - 1];
    if (lastPathName === RouterMap.VIDEO_DETAIL_PAGE) {
      if (type === window.WindowStageEventType.RESUMED || type === window.WindowStageEventType.SHOWN) {
        this.vm.swipePlayerController.play();
        emitter.emit(EventKey.ENABLE_PREVIOUS_NEXT);
      } else if (type === window.WindowStageEventType.PAUSED || type === window.WindowStageEventType.HIDDEN) {
        this.vm.swipePlayerController.pause();
        emitter.emit(EventKey.DISABLE_PREVIOUS_NEXT);
      }
    }
  }

  aboutToAppear(): void {
    this.vm.setUIContext(this.getUIContext());
    this.vm.onGestureShare();
    // 销毁应用中其他AVSession
    this.vm.destroyAVSession();
    // 模拟首次进入页面时，判断是否展示网络异常页面
    this.vm.showExceptionPage = !this.vm.networkModel.isNetworkAvailable
    // 监听 windowStageEvent
    this.vm.windowStageModel.windowStageEventListeners.delete('videoDetailPage');
    this.vm.windowStageModel.windowStageEventListeners.set('videoDetailPage', (type) => {
      this.windowStageEventCallback(type)
    })
    // 记录路由跳转之前视频的播放状态
    let avPlayerState = ''
    // 监听页面跳转
    this.vm.navRouteModel.navDestinationUpdateListeners.delete('leaveVideoDetailPageListener')
    this.vm.navRouteModel.navDestinationUpdateListeners.set('leaveVideoDetailPageListener', (info) => {
      if (this.vm.navRouteModel.videoPauseByRoutePage.includes(info.name) &&
        this.pathStack.getIndexByName(RouterMap.VIDEO_DETAIL_PAGE).length &&
        info.state === uiObserver.NavDestinationState.ON_WILL_SHOW
      ) {
        avPlayerState = this.vm.swipePlayerController.getAVPlayer()?.state as string
        this.vm.swipePlayerController.pause();
        return;
      }

      if (info.name === RouterMap.VIDEO_DETAIL_PAGE &&
        info.state === uiObserver.NavDestinationState.ON_WILL_SHOW
      ) {
        // 如果跳转之前是播放状态，则返回时继续播放，否则暂停
        if (avPlayerState === 'playing') {
          this.vm.swipePlayerController.play();
        }
      }
    });
  }

  aboutToDisappear(): void {
    this.vm.offGestureShare();
  }

  @Builder
  ContentBuilder() {
    Stack() {
      GridRow({
        columns: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS,
      }) {
        GridCol({
          span: {
            sm: 4,
            md: this.vm.isShowSideComment ? 4 : 8,
            lg: this.vm.isShowSideComment ? 8 : 12,
          },
        }) {
          Stack({ alignContent: Alignment.TopStart }) {
            if (this.vm.showExceptionPage) {
              if (!this.vm.loading) {
                NetworkExceptionView({
                  refreshNetwork: async () => {
                    this.vm.loading = true;
                    // 模拟请求判断网络能否使用
                    let networkUtil = NetworkUtil.getInstance()
                    networkUtil.handleNetworkAvailable();
                    if (this.vm.networkModel.isNetworkAvailable) {
                      await this.vm.initVideoDataSource()
                      this.vm.showExceptionPage = false;
                    } else {
                      this.vm.loading = false
                    }
                  },
                })
              }
            } else {
              VideoSwipePlayer({
                datasource: this.vm.videoDataSources,
                swipePlayerController: this.vm.swipePlayerController,
                videoItemAVPlayerController: this.vm.videoItemAVPlayerController,
                videoLayerBuilder: wrapBuilder(VideoLayerViewBuilder),
                videoNetwork: this.vm.networkModel as VideoNetworkModel,
                videoNetworkSetting: this.vm.settingInfo.network as VideoNetworkSetting,
                enableAVSession: true,
                pathStack: this.pathStack,
                isShown: this.vm.isShown,
                isLandscape: this.vm.displayModel.isLandscape,
                currentBreakpoint: this.vm.breakPointModel.currentBreakpoint,
                playerStateCallback: (state: string, id: string) => {
                  this.vm.onPlayerStateListen(state, id)
                },
                playerTimeUpdateCallback: (video: VideoPlayerData, timeMs: number) => {
                  this.vm.setVideoData(video)
                  this.vm.setContinueData(video, timeMs)
                },
                options: {
                  autoPlay: true,
                  totalCount: this.vm.totalCount,
                  bottomTabHeight: this.vm.tabModel.tabHeight,
                  swiperCallback: {
                    onAnimationStart: async (_index: number, targetIndex: number) => {
                      await this.vm.handleSwiperAnimationStart(_index, targetIndex)
                      // 判断是否到底
                      if (_index === targetIndex && this.vm.totalCount === targetIndex + 1) {
                        GlobalContextUtils.showToast({
                          message: '暂无更多视频',
                          alignment: Alignment.Center,
                        });
                      }
                    },
                  },
                },
              })
            }

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
                RouterUtils.pop(1)
              })

              NewsSearchEntry({
                name: 'videoDetail',
                colorMode: ThemeColorMode.DARK,
                searBarFgColor: '#99FFFFFF',
                searchBarPlaceholderColor: '#99FFFFFF',
                searchBarBgColor: '#393a3d',
                searchButtonFgColor: $r('sys.color.font_on_primary'),
              })
                .visibility(this.vm.showExceptionPage ? Visibility.Hidden : Visibility.Visible)
            }
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({
              left: CommonConstants.PADDING_S,
              right: CommonConstants.PADDING_L,
              top: this.vm.windowModel.windowTopPadding,
            })

            // 从右向左滑，进入用户信息界面
            Column() {
            }
            .width(CommonConstants.FULL_PERCENT)
            .height('75%')
            .backgroundColor(Color.Transparent)
            .hitTestBehavior(HitTestMode.Transparent)
            .gesture(
              PanGesture({ direction: PanDirection.Left })
                .onActionUpdate((event: GestureEvent) => {
                  if (event) {
                    this.vm.offsetX = event.offsetX;
                  }
                })
                .onActionCancel(() => {
                  this.vm.handleSwiperRightAction()
                })
                .onActionEnd(() => {
                  this.vm.handleSwiperRightAction()
                }),
            )
            .priorityGesture(
              PanGesture({ direction: PanDirection.Left })
                .onActionUpdate((event: GestureEvent) => {
                  if (event) {
                    this.vm.offsetX = event.offsetX;
                  }
                })
                .onActionEnd(() => {
                  this.vm.handleSwiperRightAction()
                }),
            )
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .backgroundColor(Color.Black)
          .padding({
            bottom: this.vm.windowModel.windowBottomPadding,
          })
        }
      }

      // 评论区适配双折叠和平板
      if (this.vm.isShowSideComment) {
        GridRow({
          columns: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS,
        }) {
          GridCol({
            span: {
              md: this.vm.isShowSideComment ? 4 : 8,
              lg: this.vm.isShowSideComment ? 8 : 12,
            },
          }) {
            Column() {
            }
            .width('100%')
            .height('100%')
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.vm.videoExtraInfoModel.isDisplayChange = false;
            })
          }
          .backgroundColor(Color.Transparent)

          GridCol({ span: { md: 4, lg: 4 } }) {
            Column() {
              CommentView({
                videoInfo: this.vm.videoExtraInfoModel.videoInfo as NewsResponse,
              })
            }
          }
        }
        .width('100%')
        .height('100%')
      }
    }
  }

  build() {
    NavDestination() {
      if (this.vm.needLongTake && this.longTakeSession) {
        CardLongTakeDelegate({
          longTakeSession: this.longTakeSession,
          contentBuilder: (): void => {
            this.ContentBuilder()
          },
        })
      } else {
        this.ContentBuilder()
      }
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      RouterUtils.pop(1);
      return true;
    })
    .onSizeChange((_oldValue: SizeOptions, newValue: SizeOptions) => {
      this.longTakeSession.setNewSize(newValue);
    })
    .backgroundColor(this.longTakeSession.navDestinationBgColor)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
      let param = context.pathInfo?.param as Record<string, AVPlayerController | BaseParamType | Object>
      // 初始化播放管理
      this.vm.initAVPlayerMgr(param)
      // 获取数据
      this.vm.initVideoListDataSource(param)
      if (this.vm.needLongTake) {
        this.vm.registerCustomTransition(param, this.longTakeSession, context)
      }
      this.vm.enableContinue(this.getUIContext().getHostContext() as common.UIAbilityContext);
    })
    .onDisAppear(() => {
      if (this.vm.needReleasePlayer ||
        (!this.vm.needReleasePlayer && this.vm.swipePlayerController.getCurrentIndex() !== 0)
      ) {
        this.vm.swipePlayerController.getAVPlayer()?.release().catch((e: BusinessError) => {
          Logger.error(TAG, 'release fail, error: ' + JSON.stringify(e));
        })
        this.vm.swipePlayerController.getAVPlayerMgr()?.clear()
        this.vm.continueModel.playerProgress = 0
      }
    })
    .onShown(() => {
      this.vm.isShown = true;
      setTimeout(() => {
        SystemBarOperation.setWindowSystemBarProp({
          statusBarContentColor: '#ffffff',
        })
      }, 300)
    })
    .onHidden(() => {
      this.vm.isShown = false;
      SystemBarOperation.setWindowSystemBarProp({
        statusBarContentColor: this.vm.settingInfo.darkSwitch ? '#ffffff' : '#ff090909',
      })
    })
  }
}

