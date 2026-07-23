import { AbilityConstant, common } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { harmonyShare, systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppConstants, ContinueModel, FileUtils, Logger, RouterMap, RouterUtils } from 'lib_common';
import { MineServiceApi, NewsEnum } from 'lib_news_api';
import { ShareUtils } from 'lib_widget';
import { AVSessionUtils } from 'lib_av_details';
import { AVPlayerManager, AVPlayerController, SwipePlayerController, VideoPlayerData } from 'module_swipeplayer';
import { LongTakeAnimationProperties, LongTakeTransitionParam } from 'module_transition';
import { VideoService } from '../services/VideoService';
import { BaseParamType } from '../types/Index';
import { VideoSwipePageVM } from '../viewmodels/VideoSwipePageVM';

const TAG = '[VideoDetailPageModel]';

@ObservedV2
export class VideoDetailPageModel extends VideoSwipePageVM {
  // 滑动播放控制器
  swipePlayerController: SwipePlayerController = new SwipePlayerController();
  avPlayerManager: AVPlayerManager = new AVPlayerManager();
  videoItemAVPlayerController: AVPlayerController | undefined;
  // 用户
  userId: string = '';
  // 视频列表总数
  @Trace totalCount: number = 0;
  // 是否需要无限滚动
  isInfiniteScroll: boolean = false;
  // 页面上手势滑动距离
  @Trace offsetX: number = 0;
  @Trace continueModel: ContinueModel = AppStorageV2.connect(ContinueModel, () => new ContinueModel())!;
  // 是否需要释放播放资源
  @Trace needReleasePlayer: boolean = true
  // 页面是否显示
  @Trace isShown: boolean = false;
  @Trace needLongTake: boolean = true;
  videoData: VideoPlayerData | undefined = undefined;
  uiContext: UIContext | undefined = undefined;
  shareUtils: ShareUtils = new ShareUtils();
  videoCoverUri: string = '';

  public setUIContext(uiContext: UIContext) {
    this.uiContext = uiContext
  }

  initAVPlayerMgr(param: Record<string, string | number | AVPlayerController | undefined | Object>) {
    let avPlayerController = param.avPlayerController as AVPlayerController
    if (avPlayerController) {
      this.videoItemAVPlayerController = avPlayerController
      this.needReleasePlayer = false
      this.needLongTake = false;
    }
    if (!param.longTakeTransitionParam) {
      this.needLongTake = false;
    }
    this.swipePlayerController.setAVPlayerMgr(this.avPlayerManager)
  }

  async initVideoListDataSource(param: Record<string, string | number | AVPlayerController | undefined | Object>) {
    const videoId = param.newsId as string;
    this.userId = param.authorId as string;
    this.isInfiniteScroll = !this.userId;
    let type = param.type as number;
    let videoList = await VideoService.queryVideoList(this.userId || '', type);
    if (videoId) {
      videoList = videoList.filter((item) => item.id !== videoId);
      const videoDetailInfo = await VideoService.queryVideoDataById(videoId);
      if (videoDetailInfo) {
        videoList.unshift(videoDetailInfo);
      }
    }
    // 模拟无限上滑
    this.totalCount = this.isInfiniteScroll ? Number.POSITIVE_INFINITY : videoList.length;
    this.videoDataSources.setData(videoList);
  }

  // 处理swiper动画开始事件
  async handleSwiperAnimationStart(_index: number, targetIndex: number) {
    let totalNum = this.videoDataSources.totalCount();
    // 加载更多，无限上滑
    if (this.isInfiniteScroll || totalNum < this.totalCount) {
      if (totalNum - targetIndex <= 5) {
        let videoList = await VideoService.queryVideoList(this.userId);
        this.videoDataSources.pushDataArray(...videoList);
        this.totalCount = this.videoDataSources.totalCount();
      }
    }
  }

  // 处理从右向左滑的手势事件
  handleSwiperRightAction() {
    if (this.offsetX < 0) {
      const idx = this.swipePlayerController.getCurrentIndex();
      const data = this.videoDataSources.getData(idx);
      const userId = data?.author?.authorId;
      if (userId) {
        RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, userId);
      }
    }
  }

  // 监听播放状态
  onPlayerStateListen(state: string, id: string) {
    if (state === 'playing') {
      this.addHistoryList(id)
      this.videoSeek();
    }
  }

  // 添加到历史记录
  addHistoryList(id: string) {
    MineServiceApi.addToHistory(id);
  }

  // 设置播放进度
  videoSeek() {
    if (!this.continueModel.isTargetDevice) {
      return;
    }
    // 对端还原参数
    if (this.continueModel.playerProgress) {
      this.swipePlayerController.seek(this.continueModel.playerProgress);
      Logger.info(TAG, 'onPlayerStateListen seek: ' + this.continueModel.playerProgress);
    }
    this.continueModel.isTargetDevice = false;
  }

  // 开启迁移能力
  enableContinue(context: common.UIAbilityContext) {
    context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE).then(() => {
      Logger.info(TAG, 'setMissionContinueState ACTIVE result: ACTIVE');
    }).catch((e: BusinessError) => {
      Logger.error(TAG, 'setMissionContinueState fail, error: ' + JSON.stringify(e));
    });
  }

  // 设置流转数据
  setContinueData(video: VideoPlayerData, progress: number) {
    if (this.continueModel.isTargetDevice) {
      return;
    }
    // 源端保存参数
    this.continueModel.newsId = video.getVideoId();
    this.continueModel.newsType = NewsEnum.Video;
    this.continueModel.playerProgress = progress;
    this.continueModel.breakpoint = this.breakPointModel.currentBreakpoint;
    Logger.debug(TAG, 'continueModel avPlayer progress: ' + this.continueModel.playerProgress);
  }

  async setVideoData(video: VideoPlayerData) {
    this.videoData = video;
    const coverImg = this.videoData.getCoverUrl();
    if (coverImg?.startsWith('file')) {
      this.videoCoverUri = coverImg;
    } else if (coverImg?.startsWith('http')) {
      const buf = await FileUtils.downloadImage(coverImg);
      this.videoCoverUri = FileUtils.saveBufferToSandbox(buf);
    } else {
      this.videoCoverUri = '';
    }
  }

  private gestureCallback: Callback<harmonyShare.SharableTarget> = (target: harmonyShare.SharableTarget) => {
    // 构造分享数据
    const shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.HYPERLINK,
      // 设置为AppLinking链接
      content: `${AppConstants.APP_LINKING_URL}/newsDetail?id=${this.videoData?.getVideoId()}&type=1`,
      title: this.videoData?.getVideoTitle(),
      description: this.videoData?.getAuthorName?.(),
      thumbnailUri: this.videoCoverUri,
    });
    target.share(shareData);
  }

  public onGestureShare() {
    const context = this.uiContext?.getHostContext();
    if (context) {
      this.shareUtils.registerGestureShareListener(context, this.gestureCallback);
    }
  }

  public offGestureShare() {
    const context = this.uiContext?.getHostContext();
    if (context) {
      this.shareUtils.unRegisterGestureShareListener(context, this.gestureCallback);
    }
  }

  async destroyAVSession() {
    await AVSessionUtils.destroyAudioSession();
    await AVSessionUtils.destroyReaderSession();
  }

  // 初始化一镜到底参数
  registerCustomTransition(param: Record<string, AVPlayerController | BaseParamType | Object>,
    longTakeSession: LongTakeAnimationProperties, context: NavDestinationContext) {
    let longTakeTransitionParam: LongTakeTransitionParam | undefined = undefined;
    longTakeTransitionParam = param.longTakeTransitionParam as LongTakeTransitionParam;
    if (longTakeTransitionParam) {
      longTakeSession.init(context, longTakeTransitionParam, {
        pop: () => {
          context.pathStack.pop()
        },
      });
    }
  }
}