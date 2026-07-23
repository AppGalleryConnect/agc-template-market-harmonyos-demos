import {
  BaseViewModel,
  BreakpointType,
  CalendarUtils,
  CommonConfirmDialog,
  GlobalContextUtils,
  LoadingModel,
  Logger,
} from 'lib_common';
import { MineServiceApi, NewsModel, NewsResponse } from 'lib_news_api';

const TAG = '[LiveReservationVM]';

@ObservedV2
export class LiveReservationListVM extends BaseViewModel {
  @Trace isEditMode: boolean = false;
  @Trace toDeleteList: NewsModel[] = [];
  @Trace list: NewsModel[] = [];
  @Trace loadingModel: LoadingModel<NewsResponse[]> = new LoadingModel(MineServiceApi.queryMyReservations);
  @Trace isRefresh: boolean = false;
  @Trace refreshCard: boolean = false;
  public scroller: ListScroller = new ListScroller();
  public calendarUtils: CalendarUtils = new CalendarUtils(GlobalContextUtils.globalContext);
  public lanesMap: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  });

  constructor() {
    super();
    this.queryList(false, true);
  }

  @Computed
  get allowDelete() {
    return this.toDeleteList.length > 0;
  }

  @Computed
  get allowEnterEdit() {
    return this.list.length > 0;
  }

  /**
   * 查询列表
   * @param refreshCard 是否刷新卡片
   * @param showLoading 是否显示页面loading
   * @returns
   */
  queryList(refreshCard: boolean = true, showLoading: boolean = false) {
    return this.loadingModel.callApi({
      pageLoading: showLoading,
      dialogLoading: false,
    }).then((list) => {
      this.isRefresh = false;
      this.list = list.map(v => new NewsModel(v));
      if (refreshCard) {
        this.refreshCard = true;
        setTimeout(() => {
          this.refreshCard = false;
        }, 100);
      }
    })
  }

  refresh() {
    this.isRefresh = true;
    this.queryList();
  }

  deleteAllConfirm() {
    CommonConfirmDialog.show({
      content: '是否删除全部预约记录',
      secBtnV: '删除',
      secBtnFg: $r('sys.color.warning'),
      confirm: () => {
        MineServiceApi.deleteReservations(this.list.map(v => v.id));
        this.calendarUtils.removeEventsFromCalendar(this.list.map(v => v.extraInfo?.eventId as number));
        this.quitEdit();
        this.queryList(false, false);
        this.contextModel.showToast({ message: '已清空' });
      },
    })
  }

  deleteConfirm() {
    const dialogText: string =
      this.toDeleteList.length === 1 ? '是否删除此条预约记录？' :
        `是否删除 ${this.toDeleteList.length} 条预约记录？`;
    CommonConfirmDialog.show({
      content: dialogText,
      secBtnV: '删除',
      secBtnFg: $r('sys.color.warning'),
      confirm: () => {
        MineServiceApi.deleteReservations(this.toDeleteList.map(v => v.id));
        this.calendarUtils.removeEventsFromCalendar(this.toDeleteList.map(v => v.extraInfo?.eventId as number));
        this.quitEdit();
        this.queryList();
        this.contextModel.showToast({ message: '已删除' });
      },
    })
  }

  deleteSingleConfirm(v: NewsModel) {
    CommonConfirmDialog.show({
      content: '是否删除此条预约记录？',
      secBtnV: '删除',
      secBtnFg: $r('sys.color.warning'),
      confirm: () => {
        MineServiceApi.deleteReservations([v.id]);
        this.calendarUtils.removeEventsFromCalendar([v.extraInfo?.eventId as number]);
        this.queryList();
        this.contextModel.showToast({ message: '已删除' });
      },
      cancel: () => {
        try {
          this.scroller.closeAllSwipeActions();
        } catch (error) {
          Logger.error(TAG, `Fail to closeAllSwipeActions, code: ${error.code}, message: ${error.message}`);
        }
      },
    })
  }

  enterEdit() {
    this.isEditMode = true;
  }

  quitEdit() {
    this.isEditMode = false;
    this.toDeleteList = [];
  }

  onChange(value: boolean, v: NewsModel) {
    if (value) {
      this.toDeleteList.push(v);
    } else {
      const index = this.toDeleteList.findIndex(item => item.id === v.id);
      if (index !== -1) {
        this.toDeleteList.splice(index, 1);
      }
    }
  }

  onBackPressed() {
    if (this.isEditMode) {
      this.quitEdit();
      return true;
    }
    return false;
  }
}