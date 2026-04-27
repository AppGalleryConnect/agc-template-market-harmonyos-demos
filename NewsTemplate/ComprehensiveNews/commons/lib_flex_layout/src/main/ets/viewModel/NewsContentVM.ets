import { emitter } from '@kit.BasicServicesKit';
import {
  BaseViewModel,
  CommonBreakpoint,
  CommonDataSource,
  EventEnum,
  NetworkUtil,
  BreakpointNameEnum,
  LanesPinchGestureUtils,
  GlobalContextUtils,
} from 'lib_common';
import { HomeServiceApi, NewsEnum, RequestListData } from 'lib_news_api';
import { RendNewsInfo } from '../model/Model';
import { noTemplateTabList } from '../constants/ExtraChannel';

@ObservedV2
export class NewsContentVM extends BaseViewModel {
  @Trace isRefreshing: boolean = false
  @Trace resource: string = 'recommend'
  @Trace rendNewsInfoList: RendNewsInfo[] = []
  @Trace bgColor: ResourceStr = $r('sys.color.background_primary')
  @Trace isLoading: boolean = false;
  @Trace currentPage: number = 0;
  @Trace currentIndex: number = 10;
  @Trace lanesCount: CommonBreakpoint<number> = new CommonBreakpoint<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  });
  @Trace dynamicLanesCount: number = 0;
  @Trace showExceptionPage: boolean = false;
  @Trace scroller: Scroller = new Scroller();
  @Trace lanesGestureUtils: LanesPinchGestureUtils = new LanesPinchGestureUtils(this.lanesCount.getLanes(), 1, 4, 0.3);

  @Computed
  get getLanesPoint() {
    return this.resource === 'hotService' ? 1 : this.lanesCount.getLanes()
  }

  @Monitor('breakPointModel.currentBreakpoint')
  onBreakpointChange(): void {
    this.updateLanesRangeByBreakpoint();
  }

  public init(resource: string, rendNewsInfoList: RendNewsInfo[]) {
    this.showExceptionPage = !this.networkModel.isNetworkAvailable;
    this.rendNewsInfoList = rendNewsInfoList
    this.resource = resource
    this.isRefreshing = true
    // 初始化时设置列数范围
    this.updateLanesRangeByBreakpoint()
    this.setOnLanesChange()
    emitter.on(EventEnum.HOME_FOLLOW_REFRESH, () => {
      this.refresh()
    })
    emitter.on(EventEnum.LOCAL_REFRESH, () => {
      this.isRefreshing = true;
      this.refresh()
    })
    emitter.on(EventEnum.TAB_HOME_DOUBLE_CLICK, () => {
      this.scroller.scrollEdge(Edge.Top);
      this.isRefreshing = true;
      this.refresh();
    });
  }

  public emitterOff() {
    emitter.off(EventEnum.HOME_FOLLOW_REFRESH)
    emitter.off(EventEnum.LOCAL_REFRESH)
    emitter.off(EventEnum.TAB_HOME_DOUBLE_CLICK)
  }

  public async getNewsDynamicData(resource: string) {
    let newsInfoList: RequestListData[] = []
    switch (resource) {
      case 'recommend':
        newsInfoList = await this.handleRecommend(resource)
        break
      case 'follow':
        newsInfoList = await this.handleFollow()
        break
      default:
        newsInfoList = await this.handleRecommend(resource)
    }
    let list = this.rendNewsInfoList.find(item => item.id === resource)
    if (list) {
      list.newsList.setData(newsInfoList)
    }
    this.isRefreshing = false
  }

  public async handleFollow() {
    let newsInfoList: RequestListData[] =
      await HomeServiceApi.queryHomeFollowList([NewsEnum.Article], this.currentIndex)
    /**
     * 处理extraInfo
     */
    newsInfoList.forEach(item => {
      item.extraInfo.isFollow = true
      item.extraInfo.isNeedAuthor = false
    })
    return newsInfoList
  }

  public async handleRecommend(resource: string) {
    let recommendData = AppStorage.get('recommendList') ? AppStorage.get('recommendList') as RequestListData[] :
      await HomeServiceApi.queryHomeRecommendList(resource, this.currentIndex)
    if (AppStorage.get('recommendList')) {
      /**
       * 再次刷新不需要从AppStorage取
       */
      AppStorage.setOrCreate('recommendList', '')
    }
    return recommendData
  }

  public async loadMore(newsList: CommonDataSource<RequestListData>) {
    this.isLoading = true
    let isNetworkAvailable = await this.checkNetworkAvailable()
    if (isNetworkAvailable) {
      let currentPage = this.currentIndex
      let currentIndex = this.currentIndex + 5
      let newsInfoList: RequestListData[] =
        await HomeServiceApi.queryNextPageData(this.resource, currentIndex, currentPage);
      if (!newsInfoList.length) {
        this.emptyToast()
      } else {
        this.currentPage = this.currentIndex
        this.currentIndex += 5
        newsInfoList.forEach(item => newsList.pushData(item))
      }
      this.isLoading = false
    } else {
      this.isLoading = false;
      this.toast()
    }
  }

  public async refresh() {
    // 模拟请求判断网络能否使用
    let isNetworkAvailable = await this.checkNetworkAvailable()
    if (isNetworkAvailable) {
      this.showExceptionPage = false;
      await this.getNewsDynamicData(this.resource)
    } else {
      this.isRefreshing = false;
      this.toast()
    }
  }

  public reloadData() {
    this.isRefreshing = true;
  }

  public checkNetworkAvailable(): Promise<boolean> {
    // 模拟请求判断网络能否使用
    let networkUtil = NetworkUtil.getInstance()
    networkUtil.handleNetworkAvailable();

    return new Promise((resolve) => {
      setTimeout(() => {
        resolve(this.networkModel.isNetworkAvailable)
      }, 500)
    })
  }

  public toast() {
    if (!this.showExceptionPage) {
      this.contextModel.showToast({
        message: '网络连接不可用',
        alignment: Alignment.Center,
        textColor: Color.Red,
      })
    }
  }

  public emptyToast() {
    this.contextModel.showToast({
      message: '暂无更新数据',
      alignment: Alignment.Bottom,
    })
  }

  public throttle(func: Function, interval: number) {
    let lastTime = 0;
    return () => {
      const nowTime = Date.now();
      const remainTime = interval - (nowTime - lastTime);
      if (remainTime <= 0) {
        lastTime = nowTime;
        func();
      }
    };
  }

  /**
   * 判断当前tab在瀑布流下是否需要分栏
   * @param id tab栏id
   * @returns
   */
  public isNeedTemplate(id: string): string {
    if (!noTemplateTabList.includes(id)) {
      const lanes = this.dynamicLanesCount > 0 ? this.dynamicLanesCount : this.getLanesPoint;
      return `repeat(${lanes}, 1fr)`
    }
    return ''
  }

  /**
   * 更新动态列数
   * @param lanes 新的列数
   */
  public updateDynamicLanes(lanes: number): void {
    if (lanes < this.dynamicLanesCount) {
      GlobalContextUtils.showToast({ message: '已显示更少内容' });
    }

    if (lanes > this.dynamicLanesCount) {
      GlobalContextUtils.showToast({ message: '已显示更多内容' });
    }
    this.dynamicLanesCount = lanes;
  }

  /**
   * 设置列数变化回调
   */
  public setOnLanesChange(): void {
    this.lanesGestureUtils
      .setOnLanesChange((lanes: number) => {
        this.updateDynamicLanes(lanes)
      })
      .setOnReachMinLanes(() => {
        GlobalContextUtils.showToast({ message: '已放至最大' });
      })
      .setOnReachMaxLanes(() => {
        GlobalContextUtils.showToast({ message: '已缩至最小' });
      })
  }

  /**
   * 根据当前断点设置列数范围
   */
  private updateLanesRangeByBreakpoint(): void {
    let minLanes = 1;
    let maxLanes = 4;

    switch (this.breakPointModel.currentBreakpoint) {
      case BreakpointNameEnum.SM:
        minLanes = 1;
        maxLanes = 1;
        break;
      case BreakpointNameEnum.MD:
        minLanes = 1;
        maxLanes = 2;
        break;
      case BreakpointNameEnum.LG:
      case BreakpointNameEnum.XL:
        minLanes = 2;
        maxLanes = 4;
        break;
      default:
        minLanes = 1;
        maxLanes = 4;
        break;
    }
    this.lanesGestureUtils.setLanesRange(minLanes, maxLanes);
  }
}