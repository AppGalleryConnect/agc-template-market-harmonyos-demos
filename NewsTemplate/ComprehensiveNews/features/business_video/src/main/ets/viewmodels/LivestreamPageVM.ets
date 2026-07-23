import { BaseViewModel, BreakpointType, CommonDataSource } from 'lib_common';
import { VideoNewsData } from '../models/VideoModel';
import { VideoService } from '../services/VideoService';

@ObservedV2
export class LivestreamPageVM extends BaseViewModel {
  // 下拉刷新
  @Trace isRefreshing: boolean = false;
  // 跟手滑动系数
  @Trace ratio: number = 1
  // 下拉最到高度
  @Trace maxRefreshingHeight: number = 160.0
  // 下拉刷新组件的状态
  @Trace refreshStatus: RefreshStatus = RefreshStatus.Inactive;
  // banner懒加载数据
  liveBannerListDataSource = new CommonDataSource<VideoNewsData>();
  // banner列表
  @Trace liveBannerList: VideoNewsData[] = [];
  // 直播预约列表
  @Trace liveReservationList: VideoNewsData[] = [];
  // 正在直播列表
  @Trace liveList: VideoNewsData[] = [];
  // 精彩回放懒加载数据
  @Trace liveHighlightsList: VideoNewsData[] = [];
  // 直播预告数据
  @Trace livestreamPreviewList: string[] = [];
  // 是否展示网络异常页
  @Trace showExceptionPage: boolean = false;
  @Trace loading: boolean = false;
  @Trace pageLoading: boolean = false;
  countOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  });
  lanesOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 2,
    md: 4,
    lg: 6,
    xl: 6,
  });

  async init() {
    // 直播预告数据
    this.livestreamPreviewList = [
      '【直播预告】"小白主播"打台球-十堰晚报主播探店DK台球俱乐部专场',
      '【直播预告】果园满园，新疆万亩沙漠葡萄迎丰收',
    ]
    // 正在直播数据
    this.liveList = await VideoService.queryLiveList();

    // 精彩回放数据
    this.liveHighlightsList = await VideoService.queryLiveHighlights();

    // 直播预约列表数据
    this.liveReservationList = await VideoService.queryLiveReservationList();

    // banner数据
    this.liveBannerList = [];
    this.liveList.length && this.liveBannerList.push(this.liveList[0]);
    this.liveReservationList.length && this.liveBannerList.push(this.liveReservationList[0]);
    this.liveHighlightsList.length && this.liveBannerList.push(this.liveHighlightsList[0]);
  }

  async refreshList() {
    await this.init();
    this.isRefreshing = false;
  }

  offsetChanged(offset: number) {
    // 越接近最大距离，下拉跟手系数越小
    this.ratio = 1 - Math.pow(offset / this.maxRefreshingHeight, 3);
  }

  getDisplayCount() {
    const count = this.countOptions.getValue(this.breakPointModel.currentBreakpoint);
    return count;
  }
}