import { AppStorageV2, uiObserver, window } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import {
  BaseViewModel,
  CardTvHeightSizeConstants,
  PreloadInfo,
  PreloadStatus,
  televisionHeightSize,
  televisionLanes,
  WindowModel,
} from 'lib_common';
import { AvModel, HomeServiceApi } from 'lib_tv_apis';
import { VideoPipViewModel } from 'lib_tv_details';
import { PiPWindowModel, VideoCardPlayerController } from 'module_swipeplayer';
import { VideoProgramSheet } from '../utils/VideoProgramSheet';
import { VideoData } from '../model/VideoModel';

const TAG = '[TelevisionViewModel]'

@ObservedV2
export class TelevisionViewModel extends BaseViewModel {
  @Trace televisionList: AvModel[] = []
  @Trace televisionExtraList: AvModel[] = []
  @Trace currentPage: number = 0;
  @Trace currentIndex: number = 10;
  @Trace televisionIndex: number = 0;
  context: UIContext
  @Trace sectionIndex: number = 0
  @Trace detailData: VideoData | undefined
  videoCardPlayerController: VideoCardPlayerController = new VideoCardPlayerController();
  @Trace pipWindowModel: PiPWindowModel = AppStorageV2.connect(PiPWindowModel, () => new PiPWindowModel())!;
  @Trace preloadInfo: PreloadInfo = AppStorageV2.connect<PreloadInfo>(PreloadInfo, () => new PreloadInfo())!;
  @Trace videoPipModel: VideoPipViewModel = new VideoPipViewModel()
  @Trace isMute: boolean = true
  @Trace title: string = '猜你喜欢'
  @Trace loading: boolean = true
  @Trace isRefreshing: boolean = false
  @Trace videoAspectRatio: number = 1920 / 1080;
  private landscapeListener = (info: uiObserver.NavDestinationInfo) => {
    this.pipWindowModel.navDestinationUpdateListeners.forEach((callback, key) => {
      if (key === 'landscapeListener') {
        callback(info)
      }
    })
  }

  constructor(context: UIContext) {
    super()
    this.context = context
  }

  @Monitor('preloadInfo.status')
  preloadChange() {
    this.getTelevisionData()
  }

  /*
   * 初始化电视数据
   * */
  public async requestTelevision() {
    // 无感监听路由变化
    emitter.on('stop_video_play', () => {
      this.videoCardPlayerController.pause()
    })
    uiObserver.on('navDestinationUpdate', this.landscapeListener);
    if (this.preloadInfo.status === PreloadStatus.FAILED) {
      this.getTelevisionData()
    }
    this.windowStageModel.windowStageEventListeners.set('HomeVideoBackground', (type) => {
      if ([window.WindowStageEventType.HIDDEN,window.WindowStageEventType.PAUSED].includes(type)) {
        this.videoCardPlayerController.pause()
      }
    });
  }


  public tabIndexChange() {
    this.videoCardPlayerController.pause()
  }

  public async getTelevisionData() {
    this.loading = true
    if (this.preloadInfo.status === PreloadStatus.SUCCESS) {
      this.televisionList = this.preloadInfo.data as AvModel[]
    } else {
      this.televisionList = await HomeServiceApi.queryTelevisionList(this.currentIndex, this.currentPage)
    }

    this.loading = false
    this.detailData = new VideoData(this.televisionList[this.televisionIndex].section[this.sectionIndex])
  }

  /*
   * 初始化电视猜你喜欢数据
   * */
  public async requestTelevisionLike() {
    this.televisionExtraList = await HomeServiceApi.queryTelevisionLikes()
  }

  public getTitle() {
    return this.televisionList[this.televisionIndex]?.title
  }


  public openProgram() {
    VideoProgramSheet.openProgram(this.televisionList[this.televisionIndex]?.id)
  }

  public setIndex(index: number, item: AvModel) {
    this.televisionIndex = index;
    const videoData = new VideoData(item.section[this.sectionIndex], item.title);
    this.videoCardPlayerController.videoUrlChange(videoData);
  }

  public setMute(value: boolean) {
    this.isMute = value
  }

  destroyListener() {
    uiObserver.off('navDestinationUpdate', this.landscapeListener)
    emitter.off('stop_video_play')
  }

  public geVideoHeight() {
    return televisionHeightSize.getValue(this.breakPointModel.currentBreakpoint) ?? CardTvHeightSizeConstants.xlSize
  }

  /**
   * 获取猜您喜欢格栅
   * */
  public getTelevisionLanes() {
    return televisionLanes.getValue(this.breakPointModel.currentBreakpoint) ?? 2
  }

  public async refreshData() {
    this.isRefreshing = true
    this.televisionList = await HomeServiceApi.queryTelevisionList(this.currentIndex, this.currentPage)
    this.isRefreshing = false
  }

  @Computed
  get videoBoxAspectRatio() {
    return this.videoAspectRatio;
  }
}