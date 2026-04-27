import { PersistenceV2 } from '@kit.ArkUI';
import { BaseViewModel, Logger, SearchHistory, TextSpanInfo } from 'lib_common';
import {
  BaseNewsServiceApi,
  HomeServiceApi,
  RequestListData,
  AbstractRequestListData,
  NewsResponse,
} from 'lib_news_api';
import { FilterTagAndList, SearchItem, SearchWordItem } from 'module_search';

const TAG = '[NewsSearchViewModel]';

@ObservedV2
export class NewsSearchViewModel extends BaseViewModel {
  @Trace searchHistory: SearchHistory = PersistenceV2.connect(SearchHistory, () => new SearchHistory())!;
  @Trace hotSearchList: SearchItem[] = [];
  @Trace guessLikeList: SearchWordItem[] = [];

  async init(): Promise<void> {
    await this.loadHotSearchList();
    await this.loadGuessLikeList();
  }

  /**
   * 处理搜索
   */
  async handleSearch(keyWord: string | SearchWordItem | SearchItem): Promise<FilterTagAndList[]> {
    let searchKey = '';
    if (typeof keyWord === 'string') {
      searchKey = keyWord;
    } else if (keyWord instanceof SearchWordItem) {
      searchKey = keyWord.content;
    } else {
      searchKey = keyWord.title;
    }

    if (!searchKey.trim()) {
      return [];
    }

    this.addHistory(searchKey);

    try {
      const result = await BaseNewsServiceApi.querySearchResultList(searchKey);
      return this.convertSearchResultToFilterTag(result);
    } catch (error) {
      Logger.error(TAG, `handleSearch error: ${JSON.stringify(error)}`);
      return [];
    }
  }

  /**
   * 获取纯文本的标题
   * @param title
   * @returns
   */
  handleTitle(title: string): string {
    try {
      return (JSON.parse(title || '[]') as TextSpanInfo[]).map(v => v.text).join('');
    } catch (e) {
      return title || '';
    }
  }

  /**
   * 搜索联想
   */
  async searchSuggestion(keyWord: string): Promise<[SearchWordItem[], string[]]> {
    if (!keyWord.trim()) {
      return [[], []];
    }

    try {
      const result = await BaseNewsServiceApi.querySearchResultList(keyWord);
      const suggestions: SearchWordItem[] = result.list.flatMap(item =>
      item.articles.map(article => {
        const searchWordItem = new SearchWordItem();
        searchWordItem.content = this.handleTitle(article.title);
        searchWordItem.id = article.id || '';
        return searchWordItem;
      }),
      ).slice(0, 10);

      return [suggestions, [keyWord]];
    } catch (error) {
      Logger.error(TAG, `searchSuggestion error: ${JSON.stringify(error)}`);
      return [[], []];
    }
  }

  /**
   * 查询历史搜索列表
   */
  async queryHistoryList(): Promise<SearchWordItem[]> {
    return this.convertHistoryListToSearchWordItems(this.searchHistory.historyList);
  }

  /**
   * 删除历史搜索列表
   */
  async deleteHistoryList(): Promise<SearchWordItem[]> {
    this.searchHistory.historyList = [];
    return [];
  }

  /**
   * 添加到历史搜索列表
   * @param searchValue
   */
  private addHistory(searchValue: string) {
    if (this.searchHistory.historyList.includes(searchValue) || searchValue.trim() === '') {
      return;
    }
    this.searchHistory.historyList.unshift(searchValue);
  }

  /**
   * 查询猜你想搜列表
   */
  async queryGuessList(isRefresh: boolean): Promise<SearchWordItem[]> {
    if (isRefresh) {
      await this.loadGuessLikeList();
    }
    return this.guessLikeList;
  }

  /**
   * 查询热搜榜列表
   */
  async queryHotSearchList(): Promise<SearchItem[]> {
    if (this.hotSearchList.length === 0) {
      await this.loadHotSearchList();
    }
    return this.hotSearchList;
  }

  /**
   * 加载热搜榜数据
   */
  private async loadHotSearchList(): Promise<void> {
    try {
      const hotDataList = await HomeServiceApi.queryHomeRecommendList('hotTopChart');
      this.hotSearchList = this.convertRequestListToSearchItems(hotDataList);
    } catch (error) {
      Logger.error(TAG, `loadHotSearchList error: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 加载猜你想搜数据
   */
  private async loadGuessLikeList(): Promise<void> {
    try {
      const hotDataList = await HomeServiceApi.queryHomeRecommendList('random');
      this.guessLikeList = hotDataList.slice(0, 5).flatMap(item =>
      item.articles.map(article => {
        const searchWordItem = new SearchWordItem();
        searchWordItem.content = this.handleTitle(article.title || '');
        searchWordItem.id = article.id || '';
        return searchWordItem;
      }),
      );
    } catch (error) {
      Logger.error(TAG, `loadGuessLikeList error: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 将新闻数据转换为SearchItem
   */
  private convertNewsToSearchItem(article: NewsResponse): SearchItem {
    const title = this.handleTitle(article.title || '');
    return {
      title: title,
      id: article.id || '',
      image: article.coverUrl || '',
      intro: article.postBody || '',
      subTitle: article.author?.authorNickName || '',
      type: String(article.type) || '',
      rawData: article,
    };
  }

  /**
   * 将RequestListData数组转换为SearchItem数组
   */
  private convertRequestListToSearchItems(dataList: RequestListData[]): SearchItem[] {
    const searchItems: SearchItem[] = [];
    dataList.forEach((item, index) => {
      item.articles.forEach(article => {
        const searchItem = this.convertNewsToSearchItem(article);
        searchItem.index = (index + 1).toString();
        searchItems.push(searchItem);
      });
    });
    return searchItems;
  }

  /**
   * 将搜索结果转换为FilterTagAndList
   */
  private convertSearchResultToFilterTag(result: AbstractRequestListData): FilterTagAndList[] {
    const filterTagAndList: FilterTagAndList[] = [];

    if (result.list && result.list.length > 0) {
      const searchItems: SearchItem[] = [];
      result.list.forEach((item: RequestListData) => {
        item.articles.forEach(article => {
          const convertItem = this.convertNewsToSearchItem(article);
          convertItem.setting = item.navInfo.setting;
          searchItems.push(convertItem);
        });
      });

      filterTagAndList.push({
        label: '全部',
        id: 'all',
        itemList: searchItems,
        abstract: result.abstract,
      });
    }

    return filterTagAndList;
  }

  /**
   * 将历史搜索列表转换为SearchWordItem数组
   */
  private convertHistoryListToSearchWordItems(historyList: string[]): SearchWordItem[] {
    return historyList.map((item, index) => {
      const searchWordItem = new SearchWordItem();
      searchWordItem.content = this.handleTitle(item);
      searchWordItem.id = index.toString();
      return searchWordItem;
    });
  }
}