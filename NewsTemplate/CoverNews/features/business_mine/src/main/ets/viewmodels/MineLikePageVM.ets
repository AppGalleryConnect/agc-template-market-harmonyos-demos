import {
  BaseViewModel,
  BreakpointType,
  CommonConfirmDialog,
  HttpServiceApi,
  INewsItem,
  LoadingModel,
  Logger,
  NewsItem,
} from 'lib_common';

const TAG = '[MineLikePageVM]';

@ObservedV2
export class MineLikePageVM extends BaseViewModel {
  @Trace isEditMode: boolean = false;
  @Trace toDeleteList: string[] = [];
  @Trace list: NewsItem[] = [];
  @Trace isRefreshing: boolean = false;
  @Trace loadingModel: LoadingModel<INewsItem[]> = new LoadingModel(HttpServiceApi.queryMyLikes);
  public scroller: ListScroller = new ListScroller();
  public lanesMap: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  });

  constructor() {
    super();
    this.queryList();
  }

  queryList(showLoading: boolean = true) {
    this.loadingModel.callApi({
      pageLoading: showLoading,
      dialogLoading: false,
    }).then((list) => {
      this.list = list.map(v => NewsItem.create(v));
    }).finally(() => {
      this.isRefreshing = false;
    })
  }

  refresh() {
    this.isRefreshing = true;
    this.queryList(false);
  }

  callDeleteApi(isDelAll: boolean, toDeleteList: string[]) {
    if (isDelAll) {
      HttpServiceApi.batchCancelLike(this.list.map(v => v.id).join(','));
    } else {
      HttpServiceApi.batchCancelLike(toDeleteList.join(','));
    }
  }

  onChange(value: boolean, v: NewsItem) {
    if (value) {
      this.toDeleteList.push(v.id);
    } else {
      const index = this.toDeleteList.findIndex(item => item === v.id);
      if (index !== -1) {
        this.toDeleteList.splice(index, 1);
      }
    }
  }

  deleteAllConfirm() {
    CommonConfirmDialog.show({
      primaryTitle: '温馨提示',
      content: '删除动作不可恢复，是否删除全部点赞记录',
      confirmButton: '删除',
      cancelButton: '取消',
      confirm: () => {
        this.callDeleteApi(true, []);
        this.quitEdit();
        this.queryList(false);
        this.contextModel.showToast({ message: '已清空' });
      },
    })
  }

  deleteConfirm() {
    const dialogText: string =
      this.toDeleteList.length === 1 ? '删除动作不可恢复，是否删除此条点赞记录？' :
        `删除动作不可恢复，是否删除 ${this.toDeleteList.length} 条点赞记录？`;
    CommonConfirmDialog.show({
      primaryTitle: '温馨提示',
      content: dialogText,
      confirmButton: '删除',
      cancelButton: '取消',
      confirm: () => {
        this.callDeleteApi(false, this.toDeleteList);
        this.quitEdit();
        this.queryList(false);
        this.contextModel.showToast({ message: '已删除' });
      },
      cancel: () => {
        try {
          this.toDeleteList = [];
          this.scroller.closeAllSwipeActions();
        } catch (error) {
          Logger.error(TAG, `Fail to closeAllSwipeActions, code: ${error.code}, message: ${error.message}`);
        }
      },
    })
  }

  deleteSingleConfirm(item: NewsItem) {
    this.toDeleteList = [item.id];
    this.deleteConfirm();
  }

  enterEdit() {
    this.isEditMode = true;
  }

  quitEdit() {
    this.isEditMode = false;
    this.toDeleteList = [];
  }

  onBackPressed() {
    if (this.isEditMode) {
      this.quitEdit();
      return true;
    }
    return false;
  }

  @Computed
  get allowDelete() {
    return this.toDeleteList.length > 0;
  }

  @Computed
  get allowEnterEdit() {
    return this.list.length > 0;
  }
}