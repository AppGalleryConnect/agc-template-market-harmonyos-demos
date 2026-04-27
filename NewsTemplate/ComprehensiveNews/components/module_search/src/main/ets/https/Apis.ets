import { PersistenceV2, Type } from '@kit.ArkUI';
import { FilterTagAndList, SearchItem, SearchSource, SearchWordItem } from '../types/Type';
import {
  GUESS_LIKE_LIST1,
  GUESS_LIKE_LIST2,
  HISTORY_MOCK,
  HOT_SEARCH_MOCK,
  SEARCH_RESULTS_MOCK,
} from './MockData';


@ObservedV2
class PersistenceData {
  @Type(SearchWordItem)
  @Trace historyData: SearchWordItem[] = []
}

// todo: 搜索组件的API定义,当前为纯端数据mock
@ObservedV2
export class SearchApis {
  @Trace static _history: PersistenceData =
    PersistenceV2.connect(PersistenceData, 'HistoryData', () => new PersistenceData())!
  private static _isInit: boolean = false;
  private static _refreshTimes: number = 0;

  static getHistoryList(): Promise<SearchWordItem[]> {
    if (!SearchApis._isInit) {
      SearchApis._history.historyData = HISTORY_MOCK;
      SearchApis._isInit = true;
    }
    return SearchApis._simulateDelay(SearchApis._history.historyData);
  }

  static addHistoryList(historyWord: string, searchId?: number | string): Promise<void> {
    const historyData = SearchApis._history.historyData;
    const recordIndex = historyData.findIndex(item => item.content === historyWord);
    if (recordIndex === -1) {
      historyData.unshift({ content: historyWord, id: searchId ?? Date.now() });
    } else {
      const record = historyData[recordIndex];
      historyData.splice(recordIndex, 1); // 移除旧位置的记录
      historyData.unshift(record); // 将记录移动到数组开头
    }
    return Promise.resolve();
  }

  static deleteHistoryList(): Promise<SearchWordItem[]> {
    SearchApis._history.historyData = [];
    return SearchApis._simulateDelay(SearchApis._history.historyData);
  }

  static getGuessLikeList(isRefresh: boolean): Promise<SearchWordItem[]> {
    let list: SearchWordItem[] = [];
    SearchApis._refreshTimes = isRefresh ? (SearchApis._refreshTimes + 1) : SearchApis._refreshTimes;
    if (SearchApis._refreshTimes % 2) {
      list = GUESS_LIKE_LIST1;
    } else {
      list = GUESS_LIKE_LIST2;
    }
    return SearchApis._simulateDelay(list);
  }

  static getHotSearchList(): Promise<SearchItem[]> {
    const list = HOT_SEARCH_MOCK;
    return SearchApis._simulateDelay(list);
  }

  static getSearchResultsList(value: string | SearchWordItem | SearchItem,
    searchSource: SearchSource): Promise<FilterTagAndList[]> {
    let content = '';
    switch (searchSource) {
      case SearchSource.USER_INPUT:
        content = value as string;
        break;
      case SearchSource.HISTORY:
      case SearchSource.SUGGESTION:
      case SearchSource.RECOMMEND:
        content = (value as SearchWordItem).content;
        break;
      default:
        content = (value as SearchItem).title;
        break;
    }
    SearchApis.addHistoryList(content);
    return content === '搜索' ? SearchApis._simulateDelay(SEARCH_RESULTS_MOCK) : SearchApis._simulateDelay([]);
  }

  static getSearchSuggestion(value: string): Promise<[SearchWordItem[], string[]]> {
    return SearchApis._simulateDelay([SearchApis.generateSearchSuggestions(value), [`${value}`]]);
  }

  static generateSearchSuggestions(value: string): SearchWordItem[] {
    // 如果输入为空，返回空列表
    if (!value) {
      return [];
    }

    // 生成搜索建议列表
    const suggestions: SearchWordItem[] = [
      {
        content: `搜索${value}`,
        id: `001-${value}`
      },
      {
        content: `搜索${value}单行内容展示不换行，超长文本显示省略号`,
        id: `002-${value}`
      },
      {
        content: `搜索词${value}支持联想词`,
        id: `003-${value}`
      },
      {
        content: `搜索${value}关键词高亮显示`,
        id: `004-${value}`
      },
      {
        content: `${value}是什么`,
        id: `005-${value}`
      },
      {
        content: `从哪里可以获取${value}相关信息`,
        id: `006-${value}`
      },
      {
        content: `搜${value}相关的什么内容都可以`,
        id: `007-${value}`
      },
      {
        content: `如果没有${value}，会怎么样`,
        id: `008-${value}`
      }
    ];
    return suggestions;
  }

  private static _simulateDelay<T>(data: T, delay: number = 200): Promise<T> {
    return new Promise<T>((resolve) => {
      setTimeout(() => {
        resolve(data);
      }, delay);
    });
  }
}
