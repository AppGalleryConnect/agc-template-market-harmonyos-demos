import { BaseViewModel, BreakpointType, CommonConfirmDialog, LoadingModel } from 'lib_common';
import { MineServiceApi, NewsModel, NewsResponse } from 'lib_news_api';

@ObservedV2
export class HistoryViewModel extends BaseViewModel {
  @Trace isEditMode: boolean = false;
  @Trace toDeleteList: string[] = [];
  @Trace list: NewsModel[] = [];
  @Trace loadingModel: LoadingModel<NewsResponse[]> = new LoadingModel(MineServiceApi.queryMyHistory);
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
      this.list = list.map(v => new NewsModel(v));
    })
  }

  callDeleteApi(isDelAll: boolean, toDeleteList: string[]) {
    if (isDelAll) {
      this.list.forEach(v => {
        MineServiceApi.deleteFromHistory(v.id);
      })
    } else {
      toDeleteList.forEach(v => {
        MineServiceApi.deleteFromHistory(v);
      })
    }

    this.toDeleteList = [];
  }

  onChange(value: boolean, v: NewsModel) {
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
      content: '删除动作不可恢复，是否删除全部历史记录',
      secBtnV: '删除',
      secBtnFg: $r('sys.color.warning'),
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
      this.toDeleteList.length === 1 ? '删除动作不可恢复，是否删除此条浏览记录？' :
        `删除动作不可恢复，是否删除 ${this.toDeleteList.length} 条浏览记录？`;
    CommonConfirmDialog.show({
      primaryTitle: '温馨提示',
      content: dialogText,
      secBtnV: '删除',
      secBtnFg: $r('sys.color.warning'),
      confirm: () => {
        this.callDeleteApi(false, this.toDeleteList);
        this.quitEdit();
        this.queryList(false);
        this.contextModel.showToast({ message: '已删除' });
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