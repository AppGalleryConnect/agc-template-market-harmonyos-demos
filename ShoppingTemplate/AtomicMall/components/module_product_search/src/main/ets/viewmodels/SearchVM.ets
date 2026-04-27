import { ToastDialog } from '@hw-agconnect/ui-toast';
import { HistorySearchItem, HotSearchItem } from '../commons/Types';
import { ProductSearchApis } from '../https/Apis';

@ObservedV2
export class SearchVM {
  @Trace
  isLoading: boolean = false;
  @Trace
  historyList: HistorySearchItem[] = [];
  @Trace
  guessLikeList: string[] = [];
  @Trace
  hotSearchList: HotSearchItem[] = [];
  @Trace
  searchWords: string = '';
  uiContext: UIContext;

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
  }

  async initData() {
    this.isLoading = true;
    const promises = [
      this.getHistoryList(),
      this.getGuessLikeList(),
      this.getHotSearchList(),
    ];
    Promise.all(promises).then(() => {
      this.isLoading = false;
    });
  }

  async getHistoryList() {
    this.historyList = await ProductSearchApis.getSearchHistoryList();
  }

  async getGuessLikeList() {
    this.guessLikeList = await ProductSearchApis.getGuessLikeList();
  }

  async getHotSearchList() {
    this.hotSearchList = await ProductSearchApis.getHotSearchList();
    this.hotSearchList.sort((a, b) => b.hotRate - a.hotRate);
  }

  async addHistoryList(value: string) {
    await ProductSearchApis.addSearchHistory(value);
    this.historyList = await ProductSearchApis.getSearchHistoryList();
  }

  async updateHistoryList(list: HistorySearchItem[]) {
    await ProductSearchApis.updateSearchHistoryList(list);
    this.historyList = await ProductSearchApis.getSearchHistoryList();
  }

  async submitSearch(keyword: string, callback?: Callback<string>) {
    if (!keyword) {
      ToastDialog.showToast({
        message: '请输入搜索内容~',
      });
      return;
    }
    this.searchWords = keyword;
    callback?.(keyword);
    await ProductSearchApis.addSearchHistory(keyword);
    this.historyList = await ProductSearchApis.getSearchHistoryList();
  }
}
