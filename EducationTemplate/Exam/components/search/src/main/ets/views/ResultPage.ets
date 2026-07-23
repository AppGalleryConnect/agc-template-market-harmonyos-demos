import { UtilLog } from '@hw-agconnect/util-log';
import { Constants } from '../common/Constant';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { PopViewUtils } from '../common/PopViewUtils';
import { GuessLike } from '../components/GuessLike';
import { HistorySearch } from '../components/HistorySearch';
import { HotSearch } from '../components/HotSearch';
import { IncognitoCard } from '../components/IncognitoCard';
import { IncognitoSwitch } from '../components/IncognitoSwitch';
import { SearchAutoComplete } from '../components/SearchAutoComplete';
import { SearchBar } from '../components/SearchBar';
import { SearchResult } from '../components/SearchResult';
import { SearchSource } from '../types/Type';
import { SearchViewModel } from '../viewmodel/SearchViewModel';

const TAG = '[ResultPage]';

@Builder
export function ResultPageBuilder() {
  ResultPage()
}

@ComponentV2
export struct ResultPage {
  @Local curTabIndex: number = 0;
  @Local vm: SearchViewModel = SearchViewModel.getInstance();
  @Local columnWidth: number = 0;
  @Local maxLen: number = 0;
  @Local containerWidth: number = 0;
  @Local bp: string = 'sm';
  uiContext: UIContext = this.getUIContext();

  @Computed
  get isWindowInLg() {
    return ((['lg', 'xl'].includes(this.bp)) && this.vm.isShallowWindow);
  }

  aboutToAppear(): void {
    PopViewUtils.initPopViewUtil(this.uiContext);
  };

  aboutToDisappear(): void {
    this.vm.isResultPopup = false;
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
              Row() {
                Button({ type: ButtonType.Circle }) {
                  SymbolGlyph($r('sys.symbol.chevron_left'))
                    .fontColor([$r('sys.color.icon_primary')])
                    .fontSize(Constants.CHEVRON_WIDTH)
                    .maxFontScale(1)
                }
                .width(Constants.BACK_BACKGROUND_WIDTH)
                .height(Constants.BACK_BACKGROUND_HEIGHT)
                .backgroundColor($r('sys.color.comp_background_tertiary'))
              }
              .margin({ right: Constants.SPACE_S })
              .onClick(() => {
                this.vm.routerStack?.pop?.();
                if (this.isWindowInLg) {
                  this.vm.showPopupInResult = false;
                  this.vm.isResultPopup = false;
                  this.vm.initSearchParam();
                }
              });

              SearchBar({
                vm: this.vm,
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
                  this.vm.submitSearch(value, SearchSource.USER_INPUT, this.vm.isIncognitoMode, this.vm.handleSearch);
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
                    UtilLog.info('onStateChange========' + event.isVisible);
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
        .padding({
          left: GridRowColSetting.getPageMargin(this.bp),
          right: GridRowColSetting.getPageMargin(this.bp),
        })
        .onBreakpointChange((bp) => {
          this.bp = bp;
          this.vm.breakpoint = bp;
        })

        if (this.isWindowInLg) {
          SearchResult({
            vm: this.vm,
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
              vm: this.vm,
              themeColor: this.vm.themeColor,
              breakpoint: this.bp,
              itemBuilderParam: this.vm.suggestionItemBuilderParam,
              selectSuggestionItem: (value) => {
                this.vm.submitSearch(value, SearchSource.SUGGESTION, this.vm.isIncognitoMode, this.vm.handleSearch);
              },
            })

          } else if (this.vm.showSearchRsp) {
            SearchResult({
              vm: this.vm,
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
                if (!this.vm.isIncognitoMode) {
                  HistorySearch({
                    historyList: this.vm.historyList,
                    breakpoint: this.bp,
                    maxLen: this.maxLen,
                    columnWidth: this.columnWidth,
                    deleteHistoryList: async () => {
                      this.vm.historyList = await this.vm.deleteHistoryList();
                    },
                    selectHistoryItem: (value) => {
                      this.vm.submitSearch(value, SearchSource.HISTORY, this.vm.isIncognitoMode, this.vm.handleSearch);
                    },
                  })

                  if (this.vm.showGuessLike) {
                    GuessLike({
                      vm: this.vm,
                      guessLikeList: this.vm.guessLikeList,
                      breakpoint: this.bp,
                      itemBuilderParam: this.vm.guessItemBuilderParam,
                      selectGuessLikeItem: (value) => {
                        this.vm.submitSearch(value, SearchSource.RECOMMEND, this.vm.isIncognitoMode,
                          this.vm.handleSearch);
                      },
                      queryGuessList: async () => {
                        this.vm.guessLikeList = await this.vm.queryGuessList(true);
                      }
                    })
                  }
                } else {
                  IncognitoCard()
                }

                if (this.vm.showHotSearch) {
                  HotSearch({
                    hotSearchList: this.vm.hotSearchList,
                    breakpoint: this.bp,
                    itemBuilderParam: this.vm.hotItemBuilderParam,
                    getMore: this.vm.getMore,
                    selectHotSearchItem: (value) => {
                      this.vm.submitSearch(value, SearchSource.HOT_SEARCH, this.vm.isIncognitoMode,
                        this.vm.handleSearch);
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

            if (this.vm.showIncognitoMode) {
              IncognitoSwitch({ themeColor: this.vm.themeColor, vm: this.vm })
                .margin({
                  left: GridRowColSetting.getPageMargin(this.bp),
                  right: GridRowColSetting.getPageMargin(this.bp),
                })
            }
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
    .onReady((context) => {
      const params = context.pathInfo.param as Record<string, Object | SearchViewModel>;
      UtilLog.debug(TAG, 'params111', JSON.stringify(context.pathInfo))
      if(params) {
        this.vm = params.vm as SearchViewModel;
        this.vm.loadingData();
        this.vm.isResultPopup = true;
        this.vm.showPopupInResult = false;
        this.bp = this.vm.breakpoint;
      }
    })
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
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
          vm: this.vm,
          breakpoint: 'sm',
          themeColor: this.vm.themeColor,
          itemBuilderParam: this.vm.suggestionItemBuilderParam,
          selectSuggestionItem: (value) => {
            this.vm.closePop();
            this.vm.submitSearch(value, SearchSource.SUGGESTION, this.vm.isIncognitoMode, this.vm.handleSearch);
          },
        })
          .constraintSize({
            maxHeight: this.vm.popupHeight === 0 ? `calc(100% - 92vp - ${this.vm.searchBarHeight}vp)` :
              this.vm.popupHeight
          })

      } else {
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
                    this.vm.closePop();
                    this.vm.submitSearch(value, SearchSource.HISTORY, this.vm.isIncognitoMode, this.vm.handleSearch);
                  },
                })

                if (this.vm.showGuessLike) {
                  GuessLike({
                    vm: this.vm,
                    guessLikeList: this.vm.guessLikeList,
                    breakpoint: 'sm',
                    itemBuilderParam: this.vm.guessItemBuilderParam,
                    selectGuessLikeItem: (value) => {
                      this.vm.closePop();
                      this.vm.submitSearch(value, SearchSource.RECOMMEND, this.vm.isIncognitoMode,
                        this.vm.handleSearch);
                    },
                    queryGuessList: async () => {
                      this.vm.guessLikeList = await this.vm.queryGuessList(true);
                    }
                  })
                }
              } else {
                IncognitoCard()
              }

              if (this.vm.showHotSearch) {
                HotSearch({
                  hotSearchList: this.vm.hotSearchList,
                  breakpoint: 'sm',
                  itemBuilderParam: this.vm.hotItemBuilderParam,
                  getMore: this.vm.getMore,
                  selectHotSearchItem: (value) => {
                    this.vm.closePop();
                    this.vm.submitSearch(value, SearchSource.HOT_SEARCH, this.vm.isIncognitoMode, this.vm.handleSearch);
                  },
                })
              }
            }
          }
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .align(Alignment.Top)
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .margin({
            left: Constants.PADDING_XL,
            right: Constants.PADDING_XL,
          })

          if (this.vm.showIncognitoMode) {
            IncognitoSwitch({ themeColor: this.vm.themeColor, vm: this.vm })
              .margin({
                left: Constants.PADDING_XL,
                right: Constants.PADDING_XL,
              })
          }
        }
        .constraintSize({
          maxHeight: this.vm.popupHeight === 0 ? `calc(100% - 92vp - ${this.vm.searchBarHeight}vp)` :
            this.vm.popupHeight
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