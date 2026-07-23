import { mediaquery } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';
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
import { IncognitoSwitch } from '../components/IncognitoSwitch';
import { IncognitoCard } from '../components/IncognitoCard';

@ComponentV2
export struct SearchView {
  @Param presentationType: PresentationType = PresentationType.SEARCH_ICON
  @Param entranceText: string[] = ['Search'];
  @Param routerStack: NavPathStack = new NavPathStack();
  @Param placeholder: string = '搜索';
  @Param themeColor: ResourceColor = '#0A59F7';
  @Param showFilterTag: boolean = true;
  @Param showGuessLike: boolean = true;
  @Param showHotSearch: boolean = true;
  @Param showIncognitoMode: boolean = true;
  @Param isShallowWindow: boolean = false;
  @Param popupHeight: number = 0;
  @Param tabBarScroller: Scroller = new Scroller();
  @Param searchResultScroller: Scroller = new Scroller();
  @Param controller: SearchViewController = new SearchViewController();
  @Param suggestionItemBuilderParam: WrappedBuilder<[string, number]> | undefined = undefined;
  @Param guessItemBuilderParam: WrappedBuilder<[string]> | undefined = undefined;
  @Param hotItemBuilderParam: WrappedBuilder<[SearchItem, number]> | undefined = undefined;
  @Param resultItemBuilderParam: WrappedBuilder<[SearchItem]> | undefined = undefined;
  @Event handleSearch: (keyWord: string | SearchWordItem | SearchItem,
    searchSource: SearchSource, isIncognitoMode: boolean) => Promise<FilterTagAndList[]> =
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
  @Local vm: SearchViewModel = SearchViewModel.getInstance(true);
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
      routerStack: this.routerStack,
      placeholder: this.placeholder,
      themeColor: this.themeColor,
      showFilterTag: this.showFilterTag,
      showGuessLike: this.showGuessLike,
      showHotSearch: this.showHotSearch,
      showIncognitoMode: this.showIncognitoMode,
      isShallowWindow: this.isShallowWindow,
      popupHeight: this.popupHeight,
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
        vm: this.vm,
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
          this.vm.pushResultPage(value, SearchSource.USER_INPUT, this.vm.isIncognitoMode);
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
            UtilLog.info('onStateChange========' + event.isVisible);
          },
          onWillDismiss: () => {
            this.vm.closePop();
          }
        })
    } else {
      if (this.presentationType === PresentationType.SEARCH_BOX) {
        Stack() {
          Search()
            .focusable(false)
            .margin(0)
            .constraintSize({ maxWidth: 400, minWidth: 40 })
            .placeholderFont({ size: $r('sys.float.Body_L') })
            .onAreaChange((_oldValue, _newValue) => {
              this.vm.calFontScale(this.uiContext.getHostContext() as common.UIAbilityContext)
            })

          Swiper() {
            ForEach(this.entranceText, (item: string) => {
              Text(item.toString())
                .textAlign(TextAlign.Start)
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_secondary'))
                .maxLines(1)
                .maxFontScale(2)
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
          .width('calc(100% - 48vp)')
          .offset({ x: 36 + (this.vm.fontScale - 1) * 10 })
          .constraintSize({ maxWidth: 352, minWidth: 40 })
        }
        .alignContent(Alignment.Start)
        .onClick(() => {
          this.vm.placeholderContent = this.entranceText[this.searchWordIndex];
          this.vm.isTabletBar = false;
          this.vm.initSearchParam();
          const params: Record<string, Object | SearchViewModel> = {
            'vm': this.vm,
          };
          this.routerStack.pushPathByName('ResultPage', params);
        })
      } else {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontColor([$r('sys.color.icon_primary')])
            .fontSize(Constants.SEARCH_ICON_WIDTH)
            .maxFontScale(1)
        }
        .width(Constants.BACK_BACKGROUND_WIDTH)
        .height(Constants.BACK_BACKGROUND_HEIGHT)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.vm.placeholderContent = this.placeholder;
          this.vm.isTabletBar = false;
          this.vm.initSearchParam();
          const params: Record<string, Object | SearchViewModel> = {
            'vm': this.vm,
          };
          this.routerStack.pushPathByName('ResultPage', params);
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
          vm: this.vm,
          breakpoint: 'sm',
          themeColor: this.themeColor,
          itemBuilderParam: this.suggestionItemBuilderParam,
          selectSuggestionItem: (value) => {
            this.vm.pushResultPage(value, SearchSource.SUGGESTION, this.vm.isIncognitoMode);
          },
        })
          .constraintSize({
            maxHeight: this.popupHeight === 0 ? `calc(100% - 108vp - ${this.vm.searchBarHeight}vp)` : this.popupHeight
          })

      } else if (!this.vm.showSearchSuggestionRsp && !this.vm.showSearchRsp) {
        Column() {
          Scroll() {
            Column() {
              if (!this.vm.isIncognitoMode) {
                HistorySearch({
                  historyList: this.vm.historyList,
                  breakpoint: 'sm',
                  maxLen: 2 * ((400 - 56) / 4) + 8,
                  columnWidth: (400 - 56) / 4,
                  deleteHistoryList: async () => {
                    this.vm.historyList = await this.vm.deleteHistoryList();
                  },
                  selectHistoryItem: (value) => {
                    this.vm.pushResultPage(value, SearchSource.HISTORY, this.vm.isIncognitoMode);
                  },
                })

                if (this.showGuessLike) {
                  GuessLike({
                    vm: this.vm,
                    guessLikeList: this.vm.guessLikeList,
                    breakpoint: 'sm',
                    itemBuilderParam: this.guessItemBuilderParam,
                    selectGuessLikeItem: (value) => {
                      this.vm.pushResultPage(value, SearchSource.RECOMMEND, this.vm.isIncognitoMode);
                    },
                    queryGuessList: async () => {
                      this.vm.guessLikeList = await this.vm.queryGuessList(true);
                    }
                  })
                }
              } else {
                IncognitoCard()
              }

              if (this.showHotSearch) {
                HotSearch({
                  hotSearchList: this.vm.hotSearchList,
                  breakpoint: 'sm',
                  itemBuilderParam: this.hotItemBuilderParam,
                  getMore: this.onClickGetMore,
                  selectHotSearchItem: (value) => {
                    this.vm.pushResultPage(value, SearchSource.HOT_SEARCH, this.vm.isIncognitoMode);
                  },
                })
              }
            }
          }
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .layoutWeight(1)
          .margin({
            left: Constants.PADDING_XL,
            right: Constants.PADDING_XL,
          })

          if (this.showIncognitoMode) {
            IncognitoSwitch({ themeColor: this.themeColor, vm: this.vm })
              .margin({
                left: Constants.PADDING_XL,
                right: Constants.PADDING_XL,
              })
          }
        }
        .constraintSize({
          maxHeight: this.popupHeight === 0 ? `calc(100% - 108vp - ${this.vm.searchBarHeight}vp)` : this.popupHeight
        })
      }
    }
  }
}
