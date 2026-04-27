import { mediaquery } from '@kit.ArkUI';
import { Constants } from '../common/Constant';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { PopViewUtils } from '../common/PopViewUtils';
import { GuessLike } from '../components/GuessLike';
import { HistorySearch } from '../components/HistorySearch';
import { HotSearch } from '../components/HotSearch';
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
  SetValueParams
} from '../types/Type';
import { SearchViewModel } from '../viewmodel/SearchViewModel';

@ComponentV2
export struct SearchView {
  @Param presentationType: PresentationType = PresentationType.SEARCH_ICON;
  @Param componentId: string = '';
  @Param entranceText: string[] = ['Search'];
  @Param routerStack: NavPathStack = new NavPathStack();
  @Param placeholder: string = 'Search';
  @Param themeColor: ResourceColor = '#0A59F7';
  @Param showFilterTag: boolean = true;
  @Param showGuessLike: boolean = true;
  @Param showHotSearch: boolean = true;
  @Param isShallowWindow: boolean = false;
  @Param tabBarScroller: Scroller = new Scroller();
  @Param searchResultScroller: Scroller = new Scroller();
  @Param controller: SearchViewController = new SearchViewController();
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
  @Event queryGuessList: (isRefresh: boolean) => Promise<SearchWordItem[]> = SearchApis.getGuessLikeList;
  @Event queryHotSearchList: () => Promise<SearchItem[]> = SearchApis.getHotSearchList;
  @Event onClickGetMore: () => void = () => {
  }
  @Event onClickResultItem: (listItem: SearchItem) => void = () => {
  }
  @Local vm: SearchViewModel = SearchViewModel.getInstance();
  @Local searchWordIndex: number = 0;
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

  @Computed
  get isWindowInLg() {
    return ((['lg', 'xl'].includes(this.breakpoint)) && this.vm.isShallowWindow);
  }

  @Monitor('breakpoint')
  onChange() {
    this.vm.closePop();
    this.vm.breakpoint = this.breakpoint;
  }

  @Monitor('vm.showPopup')
  onPopChange() {
    if ((this.vm.showPopup === true) && this.isWindowInLg) {
      this.vm.loadingData();
    }
    if ((this.vm.showPopup === false) && this.isWindowInLg) {
      this.vm.isLoading = true;
    }
  }

  aboutToAppear(): void {
    this.params = {
      componentId: this.componentId,
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
      if (this.isWindowInLg) {
        this.vm.closePop();
      }
    };
    PopViewUtils.initPopViewUtil(this.uiContext);
    this.vm.setValue(this.params);
    this.vm.isResultPopup = false;
  }

  aboutToDisappear(): void {
    this.listener.off('change');
    this.vm.initSearchParam();
  }

  build() {
    if (this.isWindowInLg) {
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
          this.vm.pushResultPage(value, SearchSource.USER_INPUT);
        },
      })
        .width(GridRowColSetting.DIALOG_MAX_WIDTH)
        .bindPopup(this.vm.showPopup, {
          builder: this.searchWindowBuilder(),
          width: GridRowColSetting.DIALOG_MAX_WIDTH,
          targetSpace: Constants.SPACE_S,
          placement: Placement.Bottom,
          enableArrow: false,
          mask: false,
          autoCancel: false,
          onStateChange: (event) => {
            console.log('onStateChange========' + event.isVisible);
          },
          onWillDismiss: () => {
            this.vm.closePop();
          }
        })
    } else {
      if (this.presentationType === PresentationType.SEARCH_BOX) {
        Stack({ alignContent: Alignment.Start }) {
          Search()
            .focusable(false)
            .margin(0)
            .constraintSize({ maxWidth: 400, minWidth: 40 })
            .placeholderFont({ size: $r('sys.float.Body_L') })

          Swiper() {
            ForEach(this.entranceText, (item: string) => {
              Text(item.toString())
                .textAlign(TextAlign.Start)
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_secondary'))
                .maxFontScale(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }, (item: string) => item);
          }
          .index($$this.searchWordIndex)
          .vertical(true)
          .autoPlay(true)
          .interval(2000)
          .loop(true)
          .indicator(false)
          .duration(500)
          .height(38)
          .width('calc(100% - 48vp)')
          .offset({ x: 36 })
          .constraintSize({ maxWidth: 352, minWidth: 40 })
        }
        .onClick(() => {
          this.vm.placeholderContent = this.entranceText[this.searchWordIndex];
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
          this.vm.placeholderContent = this.placeholder;
          this.vm.isTabletBar = false;
          this.vm.initSearchParam();
          this.routerStack.pushPathByName('ResultPage', null);
        })
      }
    }
  }

  @Builder
  searchWindowBuilder() {
    if (this.vm.isLoading) {
      Column() {
        LoadingProgress().size({ width: Constants.LOADING_SIZE, height: Constants.LOADING_SIZE })
      }.height(Constants.LOADING_HEIGHT).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center);
    } else {
      if (this.vm.showSearchSuggestionRsp) {
        SearchAutoComplete({
          breakpoint: 'sm',
          themeColor: this.themeColor,
          itemBuilderParam: this.suggestionItemBuilderParam,
          selectSuggestionItem: (value) => {
            this.vm.pushResultPage(value, SearchSource.SUGGESTION);
          },
        })
          .constraintSize({ maxHeight: 'calc(100% - 148vp)' })

      } else if (!this.vm.showSearchSuggestionRsp && !this.vm.showSearchRsp) {
        Scroll() {
          Column() {
            HistorySearch({
              historyList: this.vm.historyList,
              breakpoint: 'sm',
              maxLen: 2 * ((400 - 56) / 4) + 8,
              columnWidth: (400 - 56) / 4,
              deleteHistoryList: async () => {
                this.vm.historyList = await this.vm.deleteHistoryList();
              },
              selectHistoryItem: (value) => {
                this.vm.pushResultPage(value, SearchSource.HISTORY);
              },
            })

            if (this.showGuessLike) {
              GuessLike({
                guessLikeList: this.vm.guessLikeList,
                breakpoint: 'sm',
                itemBuilderParam: this.guessItemBuilderParam,
                selectGuessLikeItem: (value) => {
                  this.vm.pushResultPage(value, SearchSource.RECOMMEND);
                },
                queryGuessList: async () => {
                  this.vm.guessLikeList = await this.vm.queryGuessList(true);
                }
              })
            }

            if (this.showHotSearch) {
              HotSearch({
                hotSearchList: this.vm.hotSearchList,
                breakpoint: 'sm',
                itemBuilderParam: this.hotItemBuilderParam,
                getMore: this.onClickGetMore,
                selectHotSearchItem: (value) => {
                  this.vm.pushResultPage(value, SearchSource.HOT_SEARCH);
                },
              })
            }
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
}
