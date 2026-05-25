import { mediaquery } from '@kit.ArkUI';
import { Constants } from '../common/Constant';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { HistorySearch } from '../components/HistorySearch';
import { SearchAutoComplete } from '../components/SearchAutoComplete';
import { SearchBar } from '../components/SearchBar';
import { SearchApis } from '../https/Apis';
import {
  FilterTagAndList,
  PresentationType,
  SearchItem,
  SearchSource,
  SearchViewController,
  SearchWordItem,
  SetValueParams,
  StoreInfo
} from '../types/Type';
import { SearchViewModel } from '../viewmodel/SearchViewModel';
import { Logger } from 'external_interactions';

const TAG: string = '[SearchView]';

@ComponentV2
export struct SearchView {
  @Param presentationType: PresentationType = PresentationType.SEARCH_ICON
  @Param entranceText: string[] = ['搜索门店...'];
  @Param routerStack: NavPathStack = new NavPathStack();
  @Param placeholder: string[] = ['搜索门店...'];
  @Param themeColor: ResourceColor = '#0A59F7';
  @Param showFilterTag: boolean = true;
  @Param showGuessLike: boolean = true;
  @Param showHotSearch: boolean = true;
  @Param isShallowWindow: boolean = false;
  @Param tabBarScroller: Scroller = new Scroller();
  @Param searchResultScroller: Scroller = new Scroller();
  @Param controller: SearchViewController = new SearchViewController();
  @Param storeSearchResult: StoreInfo[] = []
  @BuilderParam suggestionItemBuilderParam: WrappedBuilder<[string, number]>;
  @BuilderParam guessItemBuilderParam: WrappedBuilder<[string]>;
  @BuilderParam hotItemBuilderParam: WrappedBuilder<[SearchItem, number]>;
  @BuilderParam resultItemBuilderParam: WrappedBuilder<[SearchItem]>;
  @Event handleSearch: (keyWord: string | SearchWordItem | SearchItem,
    searchSource: SearchSource) => Promise<FilterTagAndList[]> =
    SearchApis.getSearchResultsList;
  @Event searchSuggestion: (keyWord: string) => Promise<[SearchWordItem[], string[]]> = SearchApis.getSearchSuggestion;
  @Event queryHistoryList: () => Promise<SearchWordItem[]> = SearchApis.getHistoryList;
  @Event deleteHistoryList: () => Promise<SearchWordItem[]> = SearchApis.deleteHistoryList;
  @Event queryGuessList: () => Promise<SearchWordItem[]> = SearchApis.getGuessLikeList;
  @Event queryHotSearchList: () => Promise<SearchItem[]> = SearchApis.getHotSearchList;
  @Event onClickGetMore: () => void = () => {
  }
  @Event onClickResultItem: (searchWord: SearchItem) => void = () => {
  }
  @Local vm: SearchViewModel = SearchViewModel.getInstance();
  @Local searchWordIndex: number = 0;
  @Local timerID: number | null = null;
  @Local columnWidth: number = 0;
  @Local maxLen: number = 0;
  @Local containerWidth: number = 0;
  @Local breakpoint: string = 'sm'
  @Local params: SetValueParams = {};
  uiContext: UIContext = this.getUIContext();
  breakpointList = ['xs', 'sm', 'md', 'lg', 'xl']
  listener: mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(width>=840vp)');

  onPortrait(mediaQueryResult: mediaquery.MediaQueryResult) {
    if (mediaQueryResult.matches as boolean) {
      this.breakpoint = 'lg'
    } else {
      this.breakpoint = this.breakpointList[this.uiContext.getWindowWidthBreakpoint()]
    }
  }

  @Monitor('breakpoint')
  onChange() {
    this.vm.closePop();
    this.vm.breakpoint = this.breakpoint;
  }

  aboutToAppear(): void {
    this.params = {
      routerStack: this.routerStack,
      placeholder: this.placeholder,
      themeColor: this.themeColor,
      showFilterTag: this.showFilterTag,
      showGuessLike: this.showGuessLike,
      showHotSearch: this.showHotSearch,
      isShallowWindow: this.isShallowWindow,
      tabBarScroller: this.tabBarScroller,
      scroller: this.searchResultScroller,
      controller: this.controller,
      handleSearch: this.handleSearch,
      searchSuggestion: this.searchSuggestion,
      getMore: this.onClickGetMore,
      onClickResultItem: this.onClickResultItem,
      queryHistoryList: this.queryHistoryList,
      queryGuessList: this.queryGuessList,
      queryHotSearchList: this.queryHotSearchList,
      deleteHistoryList: this.deleteHistoryList,
      suggestionItemBuilderParam: this.suggestionItemBuilderParam,
      guessItemBuilderParam: this.guessItemBuilderParam,
      hotItemBuilderParam: this.hotItemBuilderParam,
      resultItemBuilderParam: this.resultItemBuilderParam
    };
    this.listener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.onPortrait(mediaQueryResult)
    });
    this.breakpoint = this.breakpointList[this.uiContext.getWindowWidthBreakpoint()]
    this.controller.onBackPressed = () => {
      if (this.vm.searchWords.length) {
        this.vm.searchWords = '';
        return true;
      }
      return false;
    }

    this.controller.closePop = () => {
      if ((['lg', 'xl'].includes(this.breakpoint)) && this.vm.isShallowWindow) {
        this.vm.closePop();
      }
    };
    this.vm.setValue(this.params);
    this.vm.isResultPopup = false;
    this.timerID = setInterval(() => {
      this.searchWordIndex = (this.searchWordIndex + 1) % this.entranceText.length;
    }, 2000);
  }

  aboutToDisappear(): void {
    this.listener.off('change');
    this.vm.initSearchParam();
    clearInterval(this.timerID);
  }

  build() {
    if ((['lg', 'xl'].includes(this.breakpoint)) && this.isShallowWindow) {
      SearchBar({
        placeholder: this.placeholder,
        searchWords: this.vm.searchWords,
        themeColor: this.themeColor,
        controller: this.vm.searchController,
        isResult: this.vm.isResultPopup,
        updateSearchWords: (value) => {
          if (!this.vm.isResultPopup) {
            this.vm.searchQuery(value, this.searchSuggestion);
          }
        },
        submitSearch: (value) => {
          this.vm.pushResultPage(this.uiContext, value, SearchSource.USER_INPUT);
        },
      })
        .width('100%')
        .bindPopup(this.vm.showPopup, {
          builder: this.searchWindowBuilder(),
          width: GridRowColSetting.DIALOG_MAX_WIDTH,
          targetSpace: Constants.SPACE_S,
          placement: Placement.Bottom,
          enableArrow: false,
          mask: false,
          autoCancel: false,
          onStateChange: (event) => {
            Logger.info(TAG, `onStateChange======== ${JSON.stringify(event.isVisible)}`);
          },
          onWillDismiss: () => {
            this.vm.closePop();
          }
        })
    } else {
      if (this.presentationType === PresentationType.SEARCH_BOX) {
        Search({
          placeholder: this.entranceText[this.searchWordIndex],
        })
          .placeholderFont({
            size: $r('sys.float.Body_L'),
            weight: FontWeight.Regular,
            family: 'HarmonyHeiTi'
          })
          .margin(0)
          .placeholderColor($r('sys.color.font_secondary'))
          .focusable(false)
          .onClick(() => {
            this.vm.isTabletBar = false;
            this.vm.initSearchParam();
            this.routerStack.pushPathByName('ResultPage', null);
          })
      } else {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontColor([$r('sys.color.icon_primary')])
            .fontSize(Constants.SEARCH_ICON_WIDTH)
        }
        .width(Constants.BACK_BACKGROUND_WIDTH)
        .height(Constants.BACK_BACKGROUND_HEIGHT)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.vm.isTabletBar = false;
          this.vm.initSearchParam();
          this.routerStack.pushPathByName('ResultPage', null);
        })
      }
    }
  }

  @Builder
  searchWindowBuilder() {
    if (this.vm.showSearchSuggestionRsp) {
      SearchAutoComplete({
        breakpoint: 'sm',
        themeColor: this.themeColor,
        itemBuilderParam: this.suggestionItemBuilderParam,
        selectSuggestionItem: (value) => {
          this.vm.pushResultPage(this.uiContext, value, SearchSource.SUGGESTION);
        },
      })
        .constraintSize({ maxHeight: 'calc(100% - 148vp)' })

    } else if (!this.vm.showSearchSuggestionRsp && !this.vm.showSearchRsp) {
      Scroll() {
        Column() {
          HistorySearch({
            breakpoint: 'sm',
            maxLen: 2 * ((400 - 56) / 4) + 8,
            columnWidth: (400 - 56) / 4,
            deleteHistoryList: this.deleteHistoryList,
            selectHistoryItem: (value) => {
              this.vm.pushResultPage(this.uiContext, value, SearchSource.HISTORY);
            },
            queryHistoryList: this.queryHistoryList
          })
        }
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .constraintSize({ maxHeight: 'calc(100% - 148vp)' })
      .margin({
        left: Constants.PADDING_XL,
        right: Constants.PADDING_XL,
      })
    }
  }
}
