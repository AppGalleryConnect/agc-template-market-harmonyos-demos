import { AppStorageV2, display, PiPWindow, window } from '@kit.ArkUI';
import { ShortDramaDetailListVM, ContinueVideoData } from '../viewmodels/ShortDramaDetailListVM';
import { VideoDetailComponent as VideoDetailComponent } from '../components/VideoDetailMask';
import {
  AiBarHeight,
  AppStorageKeys,
  BreakPoint,
  BreakPointValue,
  StatusBarHeight,
  UserInfoModel
} from '@agctemplate/widgets';
import { VideoSwiper, PlayerLayoutSize, PlayController, NetWorkModel, NetworkUtil } from 'video_swiper';
import { NAV_PAGE_NAME } from '@agctemplate/resources';
import {
  appRouter,
  container,
  Logger,
  NavParams,
  PreferConstant,
  PreferenceUtil,
  WindowManager
} from '@agctemplate/utils';
import { DramaInfo, MyWatchRecordRes, RequestAPI } from '@agctemplate/server';
import { MyStorage } from '../models/SpeedData';
import {
  getDramaInfo,
  setMyWatchRecord,
  unsetMyWatchRecord
} from '@agctemplate/server/src/main/ets/api/mock/mockData/mockDramaFactory';
import { emitter, request } from '@kit.BasicServicesKit';
import { CastListenerImpl } from '../listener/CastListenerImpl';
import { CastService, CastStatusModel } from 'module_cast';
import { VideoData } from 'module_cast/src/main/ets/model/VideoData';
import { Params, PromptActionClass } from '../components/PromptActionClass';
import { PipManager, PipVideoConfig } from 'module_pip';
import { MediaSource } from 'video_swiper/src/main/ets/constant/MediaSource';
import { DetailVideoData } from '../models/DetailVideoData';
import { JSON } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { ImmersiveListener } from '../listener/ImmersiveListener';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { CardLongTakeDelegate, LongTakeAnimationProperties, LongTakeTransitionParam } from 'module_transition';

const TAG: string = 'ShortVideo';

@ObservedV2
class DetailPageStatus {
  @Trace isQuit: boolean

  constructor(isQuit: boolean) {
    this.isQuit = isQuit
  }
}

@ComponentV2
export struct ShortDramaDetailPage {
  @Local longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Local currentBreakpoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint(BreakPointValue.SM))!;
  @Local aiBarHeight: AiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT,
    () => new AiBarHeight())!;
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  // 初始化当前视频的下标
  @Local currentVideoIndex: number = 0;
  // 首视频标志
  @Local firstFlag: boolean = true;
  // 当前播放视频的索引
  @Local layoutSize: PlayerLayoutSize = new PlayerLayoutSize()
  @Local storage: MyStorage = MyStorage.instance();
  @Param @Require continueVideoData: ContinueVideoData;
  @Local continueVideoDataTra: ContinueVideoData = this.continueVideoData
  @Provider('currentTime') currentTime: number = 0
  // 短视频数据
  @Local vm: ShortDramaDetailListVM = ShortDramaDetailListVM.instance;
  @Local playController: PlayController = new PlayController()
  @Local myWatchRecordRes: MyWatchRecordRes = new MyWatchRecordRes();
  @Local title: string = ''
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!
  @Local bonus: number = this.userInfo.bonus
  @Local castService: CastService = CastService.getInstance()
  @Local castStatusModel: CastStatusModel = CastService.getInstance().castStatusModel
  @Local netStatus: NetWorkModel =
    AppStorageV2.connect(NetWorkModel, 'netStatus', () => new NetWorkModel())!
  @Param pixelMapImg: PixelMap | undefined = undefined; //删除
  @Local filePath: string = '';
  @Local detailPageStatus: DetailPageStatus = AppStorageV2.connect(DetailPageStatus, () => new DetailPageStatus(false))!
  isBackground: boolean = false
  enablePip: boolean = false
  restoredFromPip: boolean = false
  castListener: CastListenerImpl = new CastListenerImpl(this.playController)
  isStart: boolean = false
  pipSurfaceId: string = ''
  surfaceId?: string = ''
  private pipStateCallback: Function = async (state: PiPWindow.PiPState) => {
    Logger.info(TAG, `pipStateChange: state ${state}`);
    if (state === PiPWindow.PiPState.ABOUT_TO_STOP) {
    }
    if (state === PiPWindow.PiPState.ABOUT_TO_START) {
      // 取消控制中心
      if (CastService.getInstance().getAvSessionController().getAvSession()) {
        Logger.info(TAG, `pipStateChange: deactive session`);
        CastService.getInstance().deinit()
      }
      // 这里需要重置下播放状态，因为这个小窗是单例的
      PipManager.getInstance().onPlaybackStatus(true)
    }
    if (state === PiPWindow.PiPState.ABOUT_TO_RESTORE) {
      this.restoredFromPip = true
    }
    if (state === PiPWindow.PiPState.ABOUT_TO_STOP) {
      Logger.info(TAG, 'pip stop')
      if (!this.restoredFromPip) {
        Logger.info(TAG, 'pip not restoredFromPip as stop')

        this.currentVideoIndex = PipManager.getInstance().getIndex()
        if (this.isBackground) {
          // during pip, click pip close
          await this.setAvMetaData()
          this.playController.playIndex(PipManager.getInstance().getIndex())
          this.playController.pause()
          CastService.getInstance().pause({
            elapsedTime: (this.playController.getAVPlayer()?.currentTime || 0) * 1000,
            updateTime: new Date().getTime()
          }, this.playController.getAVPlayer()?.duration)

        } else {
          // during pip, click app in launcher
          await this.setAvMetaData()
          this.playController.playIndex(PipManager.getInstance().getIndex())
          CastService.getInstance().play({
            elapsedTime: (this.playController.getAVPlayer()?.currentTime || 0) * 1000,
            updateTime: new Date().getTime()
          }, this.playController.getAVPlayer()?.duration)
        }

      } else {
        // during pip, click pip restore
        await this.setAvMetaData()
        Logger.info(TAG, 'pip playIndex')
        this.playController.playIndex(PipManager.getInstance().getIndex())
        CastService.getInstance().play({
          elapsedTime: (this.playController.getAVPlayer()?.currentTime || 0) * 1000,
          updateTime: new Date().getTime()
        }, this.playController.getAVPlayer()?.duration)
      }
      this.restoredFromPip = false
    }
  };

  @Monitor('currentTime')
  onTimeChange(monitor: IMonitor) {
    this.continueVideoDataTra.playTime = monitor.value()?.now as number
    this.vm.setContinueData(this.continueVideoDataTra)
  }

  @Monitor('playController.curentIndex',)
  onStrChange(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      Logger.info(TAG, `${path} changed from ${monitor.value(path)?.before} to ${monitor.value(path)?.now}`);
      if (path === 'playController.curentIndex') {
        this.setAvMetaData()
      }
    });
    this.continueVideoDataTra.currentIndex = monitor.value()?.now as number
    this.vm.setContinueData(this.continueVideoDataTra)
    ImmersiveListener.setCurrentIndex(monitor.value()?.now as number)
  }

  @Monitor('castStatusModel.isCasting')
  onCastChange(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      if (path === 'castStatusModel.isCasting') {
        let isCasting: boolean = monitor.value(path)?.now as boolean
        Logger.info(TAG, `isCasting:${isCasting}`)
        if (isCasting) {
          PipManager.getInstance().setAutoStart(false)
        } else {
          PipManager.getInstance().setAutoStart(true)
        }
      }
    });
  }

  async setAvMetaData() {
    let videoPlayData = this.vm.data.getData(this.currentVideoIndex)
    if (!videoPlayData) {
      Logger.warn(TAG, 'can not set av metadata, cast will not effect')
      return
    }
    let videoData: VideoData = {
      url: videoPlayData.getUrl() as string,
      head: videoPlayData.getPic(),
      name: videoPlayData.getName() + ` 第${this.playController.curentIndex + 1}集`,
      index: this.currentVideoIndex,
    }
    await CastService.getInstance()
      .setAVMetadata(videoData, this.playController.getAVPlayer()?.duration || videoPlayData.getDuration())
  }

  getFavoriteEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 5
    };
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      this.vm.init(this.continueVideoData)
    }
    try {
      emitter.on(event, callback);
    } catch (e) {
    }
  }

  // 视频数据初始化
  async aboutToAppear() {
    this.detailPageStatus.isQuit = false
    if (display.isFoldable()) {
      this.setOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED)
    }
    Logger.info(TAG, 'aboutToAppear')
    // 观看记录
    container.resolve(RequestAPI).getMyWatchRecord({
      pageSize: 1,
      pageNum: 20
    }).then((res) => {
      this.myWatchRecordRes = new MyWatchRecordRes(res.getBody());
    })
    this.enablePip = PreferenceUtil.getInstance(this.getUIContext().getHostContext())
      .get(PreferConstant.BACKGROUND_MINI_WINDOW_PLAYBACK, false) as boolean
    Logger.info(TAG, `enablePip:${this.enablePip}`)
    if (this.enablePip) {
      PipManager.getInstance().setAutoStart(true)
    }
    this.getFavoriteEmitter()
    this.storage.selectSpeed = PreferenceUtil.getInstance(this.getUIContext().getHostContext())
      .get(PreferConstant.PLAY_SPEED_SETTINGS, '1.0x') as string
    this.playController.autoPlay = true

    this.vm.deinit()
    await this.vm.init(this.continueVideoData)
    CastService.getInstance().registerSessionListener(this.castListener)
    this.currentVideoIndex = this.continueVideoData.currentIndex || 0

    WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6ffffff' })
    PipManager.getInstance().registerLifecycleCallback(this.pipStateCallback);
    PipManager.getInstance().registerPipStateChangeListener();
    this.registerEmitter()
    let mediaSource: MediaSource[] = [];
    this.vm.data.videoList.map(item => {
      mediaSource.push(new MediaSource(item.getId(), item.getUrl() as string, item.isLocked()))
    })
    this.playController.setPlayList(mediaSource)
    this.vm.setContinueData(this.continueVideoData)
    this.netStatus.inDetailPage = true
    this.netStatus.noReInit = false
    this.filePath = this.downloadCover()
    ImmersiveListener.immersiveListening(this.filePath)
    AppStorage.set('isDetailShow',true)
  }

  registerEmitter() {
    this.backEmitter()
    this.foreEmitter()
  }

  onForeground: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
    this.isBackground = false
    try {
      Logger.info(TAG, `onForeground: ${JSON.stringify(eventData)}`);
    } catch (e) {
    }
    this.playController.play()
  }
  onBackground: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
    try {
      Logger.info(TAG, `onBackground: ${JSON.stringify(eventData)}`);
    } catch (e) {
    }
    this.isBackground = true

    if (this.enablePip && !this.castStatusModel.isCasting) {
      Logger.info(TAG, `onBackground enablePip:${this.enablePip}`)
      PipManager.getInstance().setAutoStart(true)
      this.playController.play()
    }
    if (!this.enablePip) {
      this.playController.pause()
    }
  }

  backEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 1
    };
    try {
      emitter.on(event, this.onBackground);
    } catch (e) {
    }
  }

  foreEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 2
    };
    try {
      emitter.on(event, this.onForeground);
    } catch (e) {
    }
  }

  unEmitter() {
    try {
      Logger.info(TAG, 'on jump')
      emitter.off(1, this.onBackground)
      emitter.off(2, this.onForeground)
    } catch (e) {
    }
  }

  aboutToDisappear(): void {
    if (display.isFoldable()) {
      this.setOrientation(window.Orientation.UNSPECIFIED)
    }
    Logger.info(TAG, 'aboutToDisappear')
    this.unEmitter()
    PipManager.getInstance().setAutoStart(false)
    CastService.getInstance().unregisterSessionListener(this.castListener)
    CastService.getInstance().deinit()
    this.storage.selectSpeed =
      PreferenceUtil.getInstance(this.getUIContext().getHostContext())
        .get(PreferConstant.PLAY_SPEED_SETTINGS, '1.0x') as string
    fileIo.unlink(this.filePath).then(() => {
      console.info('remove file succeed');
    }).catch((err: Error) => {
      console.error('remove file failed with error message: ' + err.message);
    });
    // 观看记录
    let isWatched: boolean = false
    let isWatchedId: string = ''
    this.myWatchRecordRes.myWatchRecord.forEach((item) => {
      if (item.name === this.vm.dramaInfo.name) {
        isWatched = true
        isWatchedId = item.id
      }
    })
    const drama = getDramaInfo(this.vm.dramaInfo.id)
    drama.curIndex = this.playController.curentIndex
    if (isWatched) {
      container.resolve(RequestAPI).unsetMyWatchRecord(isWatchedId)
      container.resolve(RequestAPI).setMyWatchRecord(this.vm.dramaInfo)
    } else if (drama.id) {
      container.resolve(RequestAPI).setMyWatchRecord(drama)
    }
    PipManager.getInstance().unregisterPipStateChangeListener();
    PipManager.getInstance().unRegisterLifecycleCallback(this.pipStateCallback);
    this.vm.deinit()
    this.netStatus.inDetailPage = false
    ImmersiveListener.immersiveDisablingListening()
    this.detailPageStatus.isQuit = true
    AppStorage.set('isDetailShow',false)
  }

  @Builder
  ContentBuilder(){
    Stack({ alignContent: Alignment.Bottom }) {
      // 视频切换组件
      VideoSwiper({
        playController: this.playController,
        videoPlayDataSource: this.vm.data,
        contentBuilder: wrapBuilder(VideoDetailComponent),
        currentVideoIndex: this.currentVideoIndex,
        inPage: 'Detail',
        updateContinueModel: (index: number) => {
          this.vm.continueModel.currentIndex = index
        }
      })
        .width('100%')
        .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
    .padding({
      bottom: this.currentBreakpoint.value === BreakPointValue.LG ? 0 :
        `${this.getUIContext().px2vp(this.aiBarHeight.value)}vp`
    })
  }

  build() {
    NavDestination() {
      if (this.longTakeSession) {
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
    .onSizeChange((_oldValue: SizeOptions, newValue: SizeOptions) => {
      this.longTakeSession.setNewSize(newValue);
    })
    .backgroundColor(this.longTakeSession.navDestinationBgColor)
    .hideTitleBar(true)
    .onReady((navDestContext: NavDestinationContext)=>{
      let param = navDestContext.pathInfo?.param as Record<string, Object>;
      let longTakeTransitionParam = param.longTakeTransitionParam as LongTakeTransitionParam;
      if (longTakeTransitionParam) {
        this.longTakeSession.init(navDestContext, longTakeTransitionParam, {
          pop: () => {
            navDestContext.pathStack.pop()
          },
        });
      }
    })
    .onBackPressed(() => {
      if (CastService.getInstance().castStatusModel.isCasting) {
        this.onBack()
        return true
      }
      appRouter.back(true, {
        params: { id: this.vm.dramaInfo.id, curIndex: this.playController.curentIndex } as ParamsModel
      })
      return true
    })
    .onWillShow(() => {
      if (this.vm.ready === false) {
        this.vm.init(this.continueVideoData)
      }
    })
    .onShown(() => {
      this.vm.enableContinue(this.getUIContext().getHostContext() as common.UIAbilityContext);
      Logger.info(TAG, 'onShown')
      if (this.enablePip) {
        if (this.isStart) {
          Logger.info(TAG, 'pip stop')
          PipManager.getInstance().stopPip();
        } else {
          Logger.info(TAG, 'pip init')
          PipManager.getInstance().init(this.getUIContext().getHostContext() as Context);
          this.isStart = true
        }
      }
    })
    .onHidden(() => {
      if (!this.enablePip) {
        Logger.info(TAG, 'onHidden, no pip mode!')
        return
      }
      if ((this.vm.data.getData(this.currentVideoIndex) as DetailVideoData).isLocked()) {
        PipManager.getInstance().setAutoStart(false)
        Logger.info(TAG, 'onHidden, no locked pip mode!')
        return
      }
      // 如果是能小窗播放，设置播放列表到小窗管理器中，小窗管理器内复用播放器实现无缝播放
      let pipConfig: PipVideoConfig = new PipVideoConfig()
      this.vm.data.videoList.map(item => {
        pipConfig.mediaSource.push(new MediaSource(item.getId(), item.getUrl() as string, item.isLocked()))
      })
      pipConfig.index = this.playController.curentIndex
      PipManager.getInstance().startPip(pipConfig)
    })
    .onBackPressed(() => {
      appRouter.back();
      return true;
    })
  }

  onBack() {
    PromptActionClass.setParam(new Params('是否退出投屏？', [{
      content: '是', action: () => {
        PromptActionClass.closeDialog()
        CastService.getInstance().endCasting()
      }
    }, {
      content: '否', action: () => {
        PromptActionClass.closeDialog()
      }
    }
    ]));
    PromptActionClass.setOptions({ alignment: DialogAlignment.Center, maskColor: $r('sys.color.mask_fourth') });
    PromptActionClass.openDialog()
  }

  downloadCover(): string {
    let contextFaker: Context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    let filePath = `${contextFaker.cacheDir}/video_${new Date().getTime()}.png`; // 仅为示例 请替换正确的文件路径
    try {
      request.downloadFile(contextFaker, {
        filePath: filePath, // 文件将会保存在context.cacheDir目录下
        url: this.vm.dramaInfo.coverUrl  // 云侧文件路径，支持传入“文件目录/文件名”，或仅传入文件名
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag', `Failed to download file, code: ${err.code}, message: ${err.message}`);
      })
    } catch (err) {
      hilog.info(0x0000, 'testTag', `Failed to request the download. Code: ${err.code}, message: ${err.message}`);
    }
    return filePath
  }

  setOrientation(orientation: window.Orientation) {
    try {
      window.getLastWindow(this.getUIContext().getHostContext(), (err, data) => { // 获取window实例
        if (err.code) {
          console.error(TAG, 'Failed to obtain the top window. Cause: ' + JSON.stringify(err));
          return;
        }
        let windowClass = data;
        console.info(TAG, 'Succeeded in obtaining the top window. Data: ' + JSON.stringify(data));

        // 设置窗口方向为传感器自动旋转模式。
        try {
          windowClass.setPreferredOrientation(orientation, (err) => {
            if (err.code) {
              console.error(TAG, 'Failed to set window orientation. Cause: ' + JSON.stringify(err));
              return;
            }
            console.info(TAG, 'Succeeded in setting window orientation.');
          });
        } catch (exception) {
          console.error(TAG, 'Failed to set window orientation. Cause: ' + JSON.stringify(exception));
        }
        ;
      });
    } catch (exception) {
      try {
        console.error(TAG, 'Failed to obtain the top window. Cause: ' + JSON.stringify(exception));
      } catch (e) {
      }
    }
  }
}

@Builder
export function shortDramaDetailPageBuilder() {
  ShortDramaDetailPage({
    continueVideoData: {
      currentIndex: NavParams.getParams()?.currentIndex,
      playTime: NavParams.getParams()?.playTime,
      dramaInfo: NavParams.getParams()?.dramaInfo
    },
    pixelMapImg: NavParams.getParams()?.pixelMapImg
  });
}

export function jumpDetailPage(dramaInfo: DramaInfo, currentIndex?: number, playTime?: number,
  callback?: (popInfo: PopInfo) => void, pixelMapImg?: PixelMap) {
  appRouter.push({
    builderName: NAV_PAGE_NAME.ShortDramaDetailPage.name,
    params: {
      pixelMapImg: pixelMapImg,
      dramaInfo: dramaInfo,
      currentIndex: currentIndex,
      playTime: playTime
    },
    popCallback: callback
  })
}

export interface ParamsModel {
  id: string
  curIndex: number
}