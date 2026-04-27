export interface SearchItem {
  title: string;
  index?: string;
  id?: number | string;
  image?: ResourceStr;
  hotRate?: number;
  intro?: string;
  subTitle?: string;
  price?: number;
  vipPrice?: number;
  soldNum?: number;
  type?: string;
  classId?: string;
  subIndex?: number;
  rawData?: Object;
  setting?: string
}

@ObservedV2
export class SearchWordItem {
  @Trace content: string = '';
  @Trace id: number | string = '';
}

export interface FilterTagAndList {
  label: string;
  id: string;
  itemList: SearchItem[]
  abstract?: string
}

export interface SearchSuggestionDeTail {
  title: string;
  pinyin: string;
  pinyinList: string[];
}

export interface SearchSuggestionMatched {
  title: string;
  matchedStr: string[];
}

// 定义文本片段数据结构
export interface TextSegment {
  text: string;
  isHighlight: boolean;
}

export class SearchViewController {
  onBackPressed: () => boolean = () => false;
  closePop: () => void = () => {
  };
}

// 搜索类型
export enum SearchSource {
  USER_INPUT, // 来自用户输入
  HISTORY, // 历史搜索
  RECOMMEND, // 猜你想搜
  HOT_SEARCH, // 热搜榜
  SUGGESTION, // 联想词条
}

export interface SetValueParams {
  routerStack?: NavPathStack;
  placeholder?: string;
  searBarFgColor?: ResourceColor;
  searchBarPlaceholderColor?: ResourceColor;
  searchBarBgColor?: ResourceColor;
  themeColor?: ResourceColor;
  showFilterTag?: boolean;
  showGuessLike?: boolean;
  showHotSearch?: boolean;
  isShallowWindow?: boolean;
  tabBarScroller?: Scroller;
  scroller?: Scroller;
  controller?: SearchViewController;
  handleSearch?: (keyWord: string | SearchWordItem | SearchItem,
    searchSource: SearchSource) => Promise<FilterTagAndList[]>;
  searchSuggestion?: (keyWord: string) => Promise<[SearchWordItem[], string[]]>;
  getMore?: () => void;
  onClickResultItem?: (listItem: SearchItem) => void;
  queryHistoryList?: () => Promise<SearchWordItem[]>;
  queryGuessList?: (isRefresh: boolean) => Promise<SearchWordItem[]>;
  queryHotSearchList?: () => Promise<SearchItem[]>;
  deleteHistoryList?: () => Promise<SearchWordItem[]>;
  suggestionItemBuilderParam?: WrappedBuilder<[string, number]>;
  guessItemBuilderParam?: WrappedBuilder<[string]>;
  hotItemBuilderParam?: WrappedBuilder<[SearchItem, number]>;
  resultItemBuilderParam?: WrappedBuilder<[SearchItem, string]>;
  searchAbstractBuilderParam?: WrappedBuilder<[string, string]>;
}

export enum PresentationType {
  SEARCH_BOX,
  SEARCH_ICON,
}
