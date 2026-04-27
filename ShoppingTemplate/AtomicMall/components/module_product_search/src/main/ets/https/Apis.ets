import { AppStorageV2 } from '@kit.ArkUI';
import {
  GUESS_LIKE_LIST1,
  GUESS_LIKE_LIST2,
  HISTORY_SEARCH_MOCK,
  HOT_SEARCH_MOCK,
} from './MockData';
import { HistoryModel } from '../commons/Models';
import { HistorySearchItem, HotSearchItem } from '../commons/Types';

// todo: 商品搜索组件的API定义,当前为纯端数据mock
@ObservedV2
export class ProductSearchApis {
  @Trace
  private static _history: HistoryModel = AppStorageV2.connect(
    HistoryModel,
    () => new HistoryModel(),
  )!;
  private static _isInit: boolean = false;
  private static _refreshTimes: number = 0;

  static getSearchHistoryList(): Promise<HistorySearchItem[]> {
    if (!ProductSearchApis._isInit) {
      ProductSearchApis._history.list = HISTORY_SEARCH_MOCK;
      ProductSearchApis._isInit = true;
    }
    return ProductSearchApis._simulateDelay(ProductSearchApis._history.list);
  }

  static addSearchHistory(label: string) {
    const newSearch: HistorySearchItem = {
      label,
      latestSearch: new Date().getTime(),
    };
    const idx = ProductSearchApis._history.list.findIndex(
      (item) => item.label === label,
    );
    if (idx >= 0) {
      ProductSearchApis._history.list.splice(idx, 1);
    }
    ProductSearchApis._history.list.unshift(newSearch);
    return Promise.resolve();
  }

  static updateSearchHistoryList(list: HistorySearchItem[]) {
    ProductSearchApis._history.list = list;
    return Promise.resolve();
  }

  static getGuessLikeList(): Promise<string[]> {
    let list: string[] = [];
    ProductSearchApis._refreshTimes++;
    if (ProductSearchApis._refreshTimes % 2) {
      list = GUESS_LIKE_LIST1;
    } else {
      list = GUESS_LIKE_LIST2;
    }
    return ProductSearchApis._simulateDelay(list);
  }

  static getHotSearchList(): Promise<HotSearchItem[]> {
    const list = HOT_SEARCH_MOCK;
    return ProductSearchApis._simulateDelay(list);
  }

  private static _simulateDelay<T>(data: T, delay: number = 500): Promise<T> {
    return new Promise<T>((resolve) => {
      setTimeout(() => {
        resolve(data);
      }, delay);
    });
  }
}
