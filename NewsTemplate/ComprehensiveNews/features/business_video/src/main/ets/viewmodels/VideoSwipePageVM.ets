import { BaseViewModel, BreakpointNameEnum, Logger } from 'lib_common';
import { MineServiceApi } from 'lib_news_api';
import { AVPlayerManager, PlayerDataSource, SwipePlayerController } from 'module_swipeplayer';
import { VideoNewsData } from '../models/VideoModel';
import { VideoService } from '../services/VideoService';
import { TabPageType } from '../types/Index';

const TAG = '[VideoSwipePageVM]'

@ObservedV2
export class VideoSwipePageVM extends BaseViewModel {
  // 数据源
  videoDataSources = new PlayerDataSource<VideoNewsData>()
  // 记录swiper切换前的index
  @Trace preIndex: number = 0;
  // 下拉刷新
  @Trace isRefreshing: boolean = false;
  // 下拉距离
  @Trace refreshOffset: number = 0;
  // 跟手滑动系数
  @Trace ratio: number = 1
  // 下拉刷新组件的状态
  @Trace refreshStatus: RefreshStatus = RefreshStatus.Inactive;
  // 是否显示侧边评论
  @Trace isShowSideComment: boolean = false
  // 是否展示网络异常页
  @Trace showExceptionPage: boolean = false;
  @Trace loading: boolean = false;
  @Trace pageType: TabPageType = TabPageType.FEATURED
  // 下拉最到高度
  maxRefreshingHeight: number = 100
  // 展示刷新动画的状态
  status: RefreshStatus[] = [RefreshStatus.Drag, RefreshStatus.OverDrag, RefreshStatus.Refresh]
  // 播放控制器
  swipePlayerController: SwipePlayerController = new SwipePlayerController();
  // 播放管理
  avPlayerManager: AVPlayerManager = new AVPlayerManager();
  @Trace swiperPlayerIdx: number[] = [0, 1];

  @Monitor('videoExtraInfoModel.isDisplayChange', 'breakPointModel.currentBreakpoint')
  onShowSideCommentChange() {
    this.isShowSideComment = this.videoExtraInfoModel.isDisplayChange &&
      ((this.breakPointModel.currentBreakpoint === BreakpointNameEnum.MD &&
        this.displayModel.isFoldable) || this.breakPointModel.currentBreakpoint === BreakpointNameEnum.LG)
  }

  async initVideoDataSource() {
    let videoList: VideoNewsData[] = []
    // 关注 tab
    if (this.pageType === TabPageType.FOLLOW) {
      videoList = await VideoService.queryFollowedUserVideoList(this.userInfoModel.authorId)
    } else {
      videoList = await VideoService.queryVideoList();
    }
    this.videoDataSources.setData(videoList);
  }

  // 处理swiper动画开始事件
  async handleSwiperAnimationStart(index: number, targetIndex: number) {
    this.preIndex = index;
    // 加载更多，无限上滑
    let totalNum = this.videoDataSources.totalCount();
    if (totalNum - targetIndex <= 5) {
      let videoList: VideoNewsData[] = []
      if (this.pageType === TabPageType.FOLLOW) {
        videoList = await VideoService.queryFollowedUserVideoList(this.userInfoModel.authorId)
      } else {
        videoList = await VideoService.queryVideoList();
      }
      this.videoDataSources.pushDataArray(...videoList);
    }
  }

  async refreshList() {
    this.swipePlayerController.getAVPlayerMgr()?.clear()
    await this.initVideoDataSource();
    this.isRefreshing = false;
  }

  offsetChanged(offset: number) {
    // 下拉距离
    this.refreshOffset = offset;
    // 越接近最大距离，下拉跟手系数越小
    this.ratio = 1 - Math.pow(offset / this.maxRefreshingHeight, 3);
  }

  // 监听播放状态
  onPlayerStateListen(state: string, id: string) {
    // 如果是播放状态，则添加到历史记录
    if (state === 'playing') {
      // 添加到浏览历史
      this.addHistoryList(id)
    }
  }

  addHistoryList(id: string) {
    MineServiceApi.addToHistory(id)
  }

  // 是否使用侧边评论
  checkUseSideComment(): boolean {
    if (this.videoExtraInfoModel.isDisplayChange) {
      return false;
    }
    // 折叠屏使用侧边评论
    if (this.breakPointModel.currentBreakpoint === BreakpointNameEnum.MD) {
      return this.displayModel.isFoldable;
    }
    if (this.breakPointModel.currentBreakpoint === BreakpointNameEnum.LG) {
      return true;
    }
    return false;
  }
}