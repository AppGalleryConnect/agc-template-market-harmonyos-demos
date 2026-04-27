import { Constants } from '../common/Constant';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { PopViewUtils } from '../common/PopViewUtils';
import { GuessLike } from '../components/GuessLike';
import { HistorySearch } from '../components/HistorySearch';
import { HotSearch } from '../components/HotSearch';
import { SearchAutoComplete } from '../components/SearchAutoComplete';
import { SearchBar } from '../components/SearchBar';
import { SearchResult } from '../components/SearchResult';
import { SearchSource } from '../types/Type';
import { SearchViewModel } from '../viewmodel/SearchViewModel';

@Builder
export function ResultPageBuilder() {
  ResultPage()
}

@ComponentV2
export struct ResultPage {
  @Local curTabIndex: number = 0;
  @Local vm: SearchViewModel = SearchViewModel.getInstance();
  @Local routerStack: NavPathStack = new NavPathStack();
  @Local columnWidth: number = 0;
  @Local maxLen: number = 0;
  @Local containerWidth: number = 0;
  @Local bp: string = 'sm';
  uiContext: UIContext = this.getUIContext();

  aboutToAppear(): void {
    PopViewUtils.initPopViewUtil(this.uiContext);
    this.vm.loadingData();
    this.vm.isResultPopup = true;
    this.vm.showPopupInResult = false;
    this.bp = this.vm.breakpoint;
  };

  aboutToDisappear(): void {
    this.vm.isResultPopup = false;
  }

  @Computed
  get isWindowInLg() {
    return ((['lg', 'xl'].includes(this.bp)) && this.vm.isShallowWindow);
  }

  @Monitor('bp')
  onChange() {
    this.calculateWidth();
    this.vm.closePop();
    this.vm.toggleState(this.bp);
  }

  @Monitor('vm.showSearchRsp')
  onHistoryChange() {
    this.vm.loadingData();
  }

  @Monitor('vm.showPopupInResult')
  onPopChange() {
    if ((this.vm.showPopupInResult === true) && this.isWindowInLg) {
      this.vm.loadingData();
    }
    if ((this.vm.showPopupInResult === false) && this.isWindowInLg) {
      this.vm.isLoadingInResult = true;
    }
  }

  build() {
    NavDestination() {
      Column() {
        GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
          GridCol({
            span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS,
          }) {
            Row() {
              SearchBar({
                placeholder: this.isWindowInLg ? this.vm.placeholder :
                  this.vm.placeholderContent,
                searchWords: this.vm.searchWords,
                themeColor: this.vm.themeColor,
                controller: this.vm.searchResultController,
                isResult: this.vm.isResultPopup,
                updateSearchWords: (value) => {
                  if (this.isWindowInLg) {
                    if (this.vm.isResultPopup) {
                      this.vm.searchQuery(value, this.vm.searchSuggestion)
                    }
                  } else {
                    this.vm.searchQuery(value, this.vm.searchSuggestion)
                  }
                },
                submitSearch: (value) => {
                  this.vm.submitSearch(value, SearchSource.USER_INPUT, this.vm.handleSearch);
                  if (this.isWindowInLg) {
                    this.vm.closePop();
                  }
                },
              })
                .layoutWeight(1)
                .constraintSize({
                  maxWidth: (this.isWindowInLg) ? GridRowColSetting.DIALOG_MAX_WIDTH : 'auto'
                })
                .bindPopup(this.vm.showPopupInResult, {
                  builder: this.searchWindowBuilder(),
                  width: GridRowColSetting.DIALOG_MAX_WIDTH,
                  targetSpace: Constants.SPACE_S,
                  placement: Placement.Bottom,
                  enableArrow: false,
                  mask: false,
                  autoCancel: false,
                  onWillDismiss: () => {
                    this.vm.closePop();
                  },
                  onStateChange: (event) => {
                    console.log('onStateChange========' + event.isVisible);
                  },
                })
            }
            .onSizeChange((oldSize, newSize) => {
              this.containerWidth = newSize.width as number
              this.calculateWidth()
            })
            .justifyContent(FlexAlign.SpaceBetween)
            .width(Constants.FULL_PERCENT)
          }
        }
        .margin({
          left: GridRowColSetting.getPageMargin(this.bp),
          right: GridRowColSetting.getPageMargin(this.bp),
        })
        .onBreakpointChange((bp) => {
          this.bp = bp;
          this.vm.breakpoint = bp;
        })

        if (this.isWindowInLg) {
          SearchResult({
            themeColor: this.vm.themeColor,
            breakpoint: 'lg',
            showFilterTag: this.vm.showFilterTag,
            tabBarScroller: this.vm.tabBarScroller,
            scroller: this.vm.scroller,
            itemBuilderParam: this.vm.resultItemBuilderParam,
            onClickResultItem: this.vm.onClickResultItem,
          })

        } else {
          if (this.vm.showSearchSuggestionRsp) {
            SearchAutoComplete({
              themeColor: this.vm.themeColor,
              breakpoint: this.bp,
              itemBuilderParam: this.vm.suggestionItemBuilderParam,
              selectSuggestionItem: (value) => {
                this.vm.submitSearch(value, SearchSource.SUGGESTION, this.vm.handleSearch);
              },
            })

          } else if (this.vm.showSearchRsp) {
            SearchResult({
              themeColor: this.vm.themeColor,
              breakpoint: this.bp,
              showFilterTag: this.vm.showFilterTag,
              tabBarScroller: this.vm.tabBarScroller,
              scroller: this.vm.scroller,
              itemBuilderParam: this.vm.resultItemBuilderParam,
              onClickResultItem: this.vm.onClickResultItem,
            })

          } else {
            Scroll() {
              Column() {
                HistorySearch({
                  historyList: this.vm.historyList,
                  breakpoint: this.bp,
                  maxLen: this.maxLen,
                  columnWidth: this.columnWidth,
                  deleteHistoryList: async () => {
                    this.vm.historyList = await this.vm.deleteHistoryList();
                  },
                  selectHistoryItem: (value) => {
                    this.vm.submitSearch(value, SearchSource.HISTORY, this.vm.handleSearch);
                  },
                })

                if (this.vm.showGuessLike) {
                  GuessLike({
                    guessLikeList: this.vm.guessLikeList,
                    breakpoint: this.bp,
                    itemBuilderParam: this.vm.guessItemBuilderParam,
                    selectGuessLikeItem: (value) => {
                      this.vm.submitSearch(value, SearchSource.RECOMMEND, this.vm.handleSearch);
                    },
                    queryGuessList: async () => {
                      this.vm.guessLikeList = await this.vm.queryGuessList(true);
                    }
                  })
                }

                if (this.vm.showHotSearch) {
                  HotSearch({
                    hotSearchList: this.vm.hotSearchList,
                    breakpoint: this.bp,
                    itemBuilderParam: this.vm.hotItemBuilderParam,
                    getMore: this.vm.getMore,
                    selectHotSearchItem: (value) => {
                      this.vm.submitSearch(value, SearchSource.HOT_SEARCH, this.vm.handleSearch);
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
              left: GridRowColSetting.getPageMargin(this.bp),
              right: GridRowColSetting.getPageMargin(this.bp),
            })
          }
        }
      }
      // todo 为适配元服务需要打开注释，以防胶囊遮挡
      // .padding({ top: 56 })
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.End)
      .height(Constants.FULL_PERCENT)
      .width(Constants.FULL_PERCENT)
      .onClick(() => {
        if (this.isWindowInLg) {
          this.vm.closePop();
        }
      })
    }
    .onBackPressed(() => {
      if (this.vm.searchWords.length) {
        this.vm.initSearchParam();
        return true;
      }
      return false;
    })
    .title('搜索', {
      paddingStart: { value: GridRowColSetting.getPageMargin(this.vm.breakpoint), unit: 1 }
    })
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((ctx: NavDestinationContext) => {
      this.routerStack = ctx.pathStack;
    })
  }

  @Builder
  searchWindowBuilder() {
    if (this.vm.isLoadingInResult) {
      Column() {
        LoadingProgress().size({ width: Constants.LOADING_SIZE, height: Constants.LOADING_SIZE })
      }.height(Constants.LOADING_HEIGHT).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center);
    } else {
      if (this.vm.showSearchSuggestionRspInResult) {
        SearchAutoComplete({
          breakpoint: 'sm',
          themeColor: this.vm.themeColor,
          itemBuilderParam: this.vm.suggestionItemBuilderParam,
          selectSuggestionItem: (value) => {
            this.vm.closePop();
            this.vm.submitSearch(value, SearchSource.SUGGESTION, this.vm.handleSearch);
          },
        })
          .constraintSize({ maxHeight: 'calc(100% - 148vp)' })

      } else {
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
                this.vm.closePop();
                this.vm.submitSearch(value, SearchSource.HISTORY, this.vm.handleSearch);
              },
            })

            if (this.vm.showGuessLike) {
              GuessLike({
                guessLikeList: this.vm.guessLikeList,
                breakpoint: 'sm',
                itemBuilderParam: this.vm.guessItemBuilderParam,
                selectGuessLikeItem: (value) => {
                  this.vm.closePop();
                  this.vm.submitSearch(value, SearchSource.RECOMMEND, this.vm.handleSearch);
                },
                queryGuessList: async () => {
                  this.vm.guessLikeList = await this.vm.queryGuessList(true);
                }
              })
            }

            if (this.vm.showHotSearch) {
              HotSearch({
                hotSearchList: this.vm.hotSearchList,
                breakpoint: 'sm',
                itemBuilderParam: this.vm.hotItemBuilderParam,
                getMore: this.vm.getMore,
                selectHotSearchItem: (value) => {
                  this.vm.closePop();
                  this.vm.submitSearch(value, SearchSource.HOT_SEARCH, this.vm.handleSearch);
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

  calculateWidth = () => {
    this.columnWidth = (this.containerWidth - GridRowColSetting.getGutter(this.bp) *
      (GridRowColSetting.getWindowColumn(this.bp) - 1)) /
    GridRowColSetting.getWindowColumn(this.bp);
    this.maxLen = GridRowColSetting.getMaxColumns(this.bp) * this.columnWidth +
      GridRowColSetting.getMaxGutter(this.bp) * GridRowColSetting.getGutter(this.bp)
  }
}