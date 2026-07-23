import { BaseViewModel, BreakpointNameEnum, CommonDataSource } from 'lib_common';
import { MineServiceApi } from 'lib_news_api';
import { AVPlayerManager } from 'module_swipeplayer';
import { VideoNewsData } from '../models/VideoModel';
import { VideoService } from '../services/VideoService';

@ObservedV2
export class RecommendPageVM extends BaseViewModel {
  // List显示区域内第一个子组件索引值
  @Trace startIndex: number = 0;
  // List显示区域内中间子组件索引值
  @Trace centerIndex: number = 0;
  // 当前播放的index
  @Trace currentIndex: number = 0;
  // 下拉刷新
  @Trace isRefreshing: boolean = false;
  // 跟手滑动系数
  @Trace ratio: number = 1
  // 下拉最到高度
  @Trace maxRefreshingHeight: number = 160.0
  // 下拉刷新组件的状态
  @Trace refreshStatus: RefreshStatus = RefreshStatus.Inactive;
  // 上拉加载
  @Trace isLoadingMore: boolean = false;
  // 滑动的距离
  @Trace yOffset: number = 0
  // 是否滑动到起始位置
  @Trace isScrollStart: boolean = true;
  // 是否滑动到底部
  @Trace isScrollEnd: boolean = false;
  // 是否是手动点击item播放滚动
  @Trace isListScrollByUserClick: boolean = false;
  // 手动点击播放的index
  @Trace playIndex: number = 0
  // 是否手动触发滑动事件
  @Trace isUserActionScroll: boolean = false;
  // 是否展示网络异常页
  @Trace showExceptionPage: boolean = false;
  @Trace loading: boolean = false;
  // 组件是否在前台活跃状态
  @Trace isActive: boolean = true;
  @Trace lanesCount: number = 1;
  // 懒加载数据
  videoListDataSource = new CommonDataSource<VideoNewsData>();
  // 视频播放控制
  listScroller: Scroller = new Scroller();
  // 播放管理
  avPlayerManager: AVPlayerManager = AVPlayerManager.getInstance()

  async initVideoListDataSource() {
    let videoList = await VideoService.queryVideoList();
    this.videoListDataSource.setData(videoList);
  }

  async refreshList() {
    this.avPlayerManager.clear();
    await this.initVideoListDataSource();
    //  重置
    this.currentIndex = 0;
    this.isRefreshing = false;
  }

  offsetChanged(offset: number) {
    // 越接近最大距离，下拉跟手系数越小
    this.ratio = 1 - Math.pow(offset / this.maxRefreshingHeight, 3);
  }

  async loadMore() {
    this.isScrollEnd = true
    this.isLoadingMore = true;
    let videoList = await VideoService.queryVideoList();
    this.videoListDataSource.pushDataArray(...videoList)
    this.isLoadingMore = false;
  }

  // 处理滚动事件
  handleScrollIndex(first: number, last: number) {
    this.startIndex = first;
    if (this.isUserActionScroll) {
      this.centerIndex = this.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ? first + 1 : first + 2;
    } else {
      this.centerIndex = this.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ? first : first + 1;
    }
    if (first > 0 && last < this.videoListDataSource.totalCount()) {
      this.isScrollStart = false;
      this.isScrollEnd = false
    }
  }

  // 处理滚动停止
  handleScrollStop() {
    if (this.isRefreshing) {
      return
    }
    if (this.isListScrollByUserClick) {
      this.currentIndex = this.playIndex
    } else {
      // 推荐视频自动播放开关
      if (this.settingInfo.network.autoPlayTabRecommend) {
        if (this.isScrollStart) {
          this.currentIndex = this.yOffset > 120 ? this.centerIndex : 0
        } else if (this.isScrollEnd) {
          this.currentIndex = this.centerIndex
        } else {
          this.currentIndex = this.centerIndex;
        }
      }
    }

    this.yOffset = 0;
    this.isListScrollByUserClick = false;
    this.isScrollStart = false;
    this.isScrollEnd = false;
  }

  // 点击视频item触发的滚动
  handleListScrollByUserClick(index: number) {
    this.isListScrollByUserClick = true;
    this.playIndex = index;
    this.listScroller.scrollToIndex(index, true);
    this.currentIndex = index;
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

  @Monitor('breakPointModel.currentBreakpoint', 'isActive')
  setLanes() {
    if (!this.isActive) {
      return;
    }
    this.lanesCount = this.getListLanes();
  }

  // 一多适配
  getListLanes(): number {
    let lanesValue = 1
    switch (this.breakPointModel.currentBreakpoint) {
      case BreakpointNameEnum.SM:
        lanesValue = 1;
        break;
      case BreakpointNameEnum.MD:
        lanesValue = 2;
        break;
      case BreakpointNameEnum.LG:
      case BreakpointNameEnum.XL:
        lanesValue = 3;
        break;
    }

    return lanesValue
  }

  getListPadding(): number {
    let paddingNum = 0
    switch (this.breakPointModel.currentBreakpoint) {
      case BreakpointNameEnum.SM:
        paddingNum = 0;
        break;
      case BreakpointNameEnum.MD:
      case BreakpointNameEnum.LG:
      case BreakpointNameEnum.XL:
        paddingNum = 24;
        break;
    }
    return paddingNum;
  }
}