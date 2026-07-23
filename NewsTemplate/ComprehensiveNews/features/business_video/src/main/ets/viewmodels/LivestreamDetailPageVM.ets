import { BaseViewModel, CalendarUtils, GlobalContextUtils, Logger, OptimizeUtils, TimeUtils } from 'lib_common';
import { CommentServiceApi, MineServiceApi, NewsResponse } from 'lib_news_api';
import { MakeObCommentServed, CommentInfo } from 'lib_news_feed_details';
import { LongTakeAnimationProperties, LongTakeTransitionParam } from 'module_transition';
import { TabNav } from '../models/VideoModel';

const TAG = '[LivestreamDetailPageVM]';

@ObservedV2
export class LivestreamDetailPageVM extends BaseViewModel {
  tabController: TabsController = new TabsController();
  tabNavs: TabNav[] = [
    new TabNav('introduction', '介绍', $r('app.color.color_tab_blue')),
    new TabNav('comment', '评论', $r('app.color.color_tab_blue')),
  ]
  calendarUtils: CalendarUtils = new CalendarUtils(GlobalContextUtils.globalContext);
  @Trace livestreamInfo: NewsResponse = {} as NewsResponse;
  @Trace commentList: CommentInfo[] = [];
  // 当前tab下标
  @Trace currentTabIndex: number = 0;
  // 当前indicator的下标
  @Trace indicatorIndex: number = 0;
  // 预约状态
  @Trace isReserved: boolean = false;
  // 倒计时文本
  @Trace countdownText: string = '';
  // 倒计时定时器ID
  @Trace countdownTimerId: number = -1;
  // 直播开始时间监听定时器
  @Trace liveStartTimerId: number = -1;
  // 直播结束时间监听定时器
  @Trace liveEndTimerId: number = -1;
  // 直播开始时间
  @Trace liveStartTime: number = 0;
  // 直播结束时间
  @Trace liveEndTime: number = 0;
  // 直播是否已结束
  @Trace isLiveEnded: boolean = false;
  // 直播时长
  @Trace liveDuration: string = '';
  // 日历事件ID
  @Trace eventId: number = 0;

  async init() {
    let commentInfo = await CommentServiceApi.queryCommentList(this.livestreamInfo.id) as CommentInfo[]
    this.commentList = commentInfo?.map((value: CommentInfo) => {
      return new MakeObCommentServed(value)
    }) ?? [];
  }

  // 初始化一镜到底参数
  registerCustomTransition(longTakeSession: LongTakeAnimationProperties, context: NavDestinationContext) {
    let longTakeTransitionParam: LongTakeTransitionParam | undefined = undefined;
    let param = context.pathInfo?.param as Record<string, Object>;
    longTakeTransitionParam = param.longTakeTransitionParam as LongTakeTransitionParam;
    if (longTakeTransitionParam) {
      longTakeSession.init(context, longTakeTransitionParam, {
        pop: () => {
          context.pathStack.pop()
        },
      });
    }
  }

  handleAnimationStart(_index: number, targetIndex: number) {
    this.indicatorIndex = targetIndex;
  }

  /**
   * 切换预约状态
   * @param newsId
   * @param isReserved
   * @param eventId
   */
  async toggleReservation(newsId: string, isReserved: boolean, eventId: number): Promise<void> {
    if (isReserved) {
      await MineServiceApi.cancelReservation(newsId);
    } else {
      await MineServiceApi.addReservation(newsId, this.liveStartTime, eventId);
    }
  }

  /**
   * 计算倒计时
   * @param startTime 开始时间（毫秒时间戳）
   * @returns 格式化的倒计时文本
   */
  calculateCountdown(startTime: number): string {
    const now = Date.now();
    const diff = startTime - now;

    if (diff <= 0) {
      return '00:00:00';
    }

    const hours = Math.floor(diff / (1000 * 60 * 60));
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((diff % (1000 * 60)) / 1000);

    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString()
      .padStart(2, '0')}`;
  }

  /**
   * 初始化预约状态
   * @param newsId
   */
  async initReservationStatus(newsId: string): Promise<void> {
    try {
      const reservations = await MineServiceApi.queryMyReservations();
      const item = reservations.find(item => item.id === newsId);
      this.isReserved = Boolean(item);
      this.eventId = item?.extraInfo?.eventId as number;
    } catch (e) {
      Logger.error(TAG, 'Fail to checkReservationStatus, error: ' + JSON.stringify(e));
    }
  }

  /**
   * 启动倒计时
   */
  startCountdown(): void {
    this.countdownText = this.calculateCountdown(this.liveStartTime);

    this.countdownTimerId = setInterval(() => {
      this.countdownText = this.calculateCountdown(this.liveStartTime);
    }, 1000);
  }

  /**
   * 清除定时器
   */
  clearCountdownTimer(): void {
    if (this.countdownTimerId !== -1) {
      clearInterval(this.countdownTimerId);
      this.countdownTimerId = -1;
    }
  }

  /**
   * 清除直播开始时间监听定时器
   */
  clearLiveStartTimer(): void {
    if (this.liveStartTimerId !== -1) {
      clearInterval(this.liveStartTimerId);
      this.liveStartTimerId = -1;
    }
  }

  /**
   * 启动直播开始时间监听
   * @param callback 直播开始时的回调函数
   */
  startLiveStartTimer(callback: () => void): void {
    this.clearLiveStartTimer();
    const now = Date.now();
    const timeUntilStart = this.liveStartTime - now;

    if (timeUntilStart <= 0) {
      // 已经开始，立即执行回调
      callback();
      return;
    }

    // 在直播开始时间到达时执行回调
    this.liveStartTimerId = setTimeout(() => {
      callback();
    }, timeUntilStart);
  }

  /**
   * 清除直播结束时间监听定时器
   */
  clearLiveEndTimer(): void {
    if (this.liveEndTimerId !== -1) {
      clearTimeout(this.liveEndTimerId);
      this.liveEndTimerId = -1;
    }
  }

  /**
   * 计算直播时长
   */
  calculateLiveDuration(): void {
    if (this.liveEndTime > 0 && this.liveStartTime > 0 && this.liveEndTime > this.liveStartTime) {
      const duration = this.liveEndTime - this.liveStartTime;
      this.liveDuration = TimeUtils.handleDuration(duration);
    }
  }

  /**
   * 启动直播结束时间监听
   * @param callback 直播结束时的回调函数
   */
  startLiveEndTimer(callback: () => void): void {
    this.clearLiveEndTimer();
    const now = Date.now();
    const timeUntilEnd = this.liveEndTime - now;

    if (timeUntilEnd <= 0) {
      callback();
      return;
    }

    // 在直播结束时间到达时执行回调
    this.liveEndTimerId = setTimeout(() => {
      callback();
    }, timeUntilEnd);
  }

  /**
   * 处理预约点击事件
   * @param newsId 新闻ID
   * @param title 直播标题
   * @param isReserved 当前预约状态
   */
  async handleReservationClick(newsId: string, title: string, isReserved: boolean): Promise<void> {
    await OptimizeUtils.throttleAsync(async () => {
      try {
        if (this.isReserved) {
          // 取消预约：先删除日历事件，再调用API
          await this.calendarUtils.removeEventsFromCalendar([this.eventId]);
          await this.toggleReservation(newsId, isReserved, this.eventId);
          this.contextModel.showToast({ message: '已取消预约' });
        } else {
          // 添加预约：先添加日历事件获取eventId，再调用API
          const eventId = await this.calendarUtils.addEventToCalendar(
            `【直播预约】${title}`,
            this.liveStartTime,
            this.liveStartTime + 2 * 60 * 60 * 1000,
            5,
          );
          await this.toggleReservation(newsId, isReserved, eventId);
          this.eventId = eventId;
          this.contextModel.showToast({ message: '预约成功，直播开始5分钟前提醒您' });
        }
        this.isReserved = !isReserved;
      } catch (e) {
        this.contextModel.showToast({ message: '操作失败，请重试' });
      }
    }, 1000);
  }
}