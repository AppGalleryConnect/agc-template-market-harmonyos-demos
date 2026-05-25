import { BasicDataSource } from '../common/BasicDataSource';
import { Constants } from '../common/Constant';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { GuessLike } from '../components/GuessLike';
import { HistorySearch } from '../components/HistorySearch';
import { HotSearch } from '../components/HotSearch';
import { SearchAutoComplete } from '../components/SearchAutoComplete';
import { SearchBar } from '../components/SearchBar';
import { SearchResult } from '../components/SearchResult';
import { STORE_SEARCH_RESULTS1, STORE_SEARCH_RESULTS2 } from '../https/MockData';
import { SearchItem, SearchSource, StoreInfo } from '../types/Type';
import { SearchViewModel } from '../viewmodel/SearchViewModel';
import { Logger } from 'external_interactions';

const TAG: string = '[ResultPage]';

@Builder
export function ResultPageBuilder() {
  ResultPage()
}

@ComponentV2
export struct ResultPage {
  @Local curTabIndex: number = 0;
  @Local vm: SearchViewModel = SearchViewModel.getInstance();
  @Local routerStack: NavPathStack = new NavPathStack();
  @Local dataSource: BasicDataSource<SearchItem> = new BasicDataSource();
  @Local columnWidth: number = 0;
  @Local maxLen: number = 0;
  @Local containerWidth: number = 0;
  @Local bp: string = 'sm';
  @Local storeSearchList: StoreInfo[] = []
  @Local scroller: Scroller = new Scroller();
  @Local scrollStatus: boolean = false;
  @Local curSubIndex: number = 0;
  @Local subBarScroller: Scroller = new Scroller();
  uiContext: UIContext = this.getUIContext();
  @BuilderParam itemBuilderParam: (item: StoreInfo) => void = this.itemBuilder;
  @Event onItemClick: (itemDetail: StoreInfo) => void = (itemDetail: StoreInfo) => {
    AppStorage.setOrCreate('currentStore', itemDetail.name)
    this.getUIContext().getHostContext()?.eventHub.emit('currentStore', itemDetail.name)
    this.routerStack.pop()
    this.routerStack.pop()
  }

  aboutToAppear(): void {
    if (this.vm.searchResults.length) {
      this.dataSource.setData(this.vm.searchResults[this.curTabIndex].itemList);
    }
    this.vm.isResultPopup = true;
    this.vm.showPopupInResult = false;
    this.bp = this.vm.breakpoint;
  };

  aboutToDisappear(): void {
    this.vm.isResultPopup = false;
  }

  @Monitor('curTabIndex')
  onListChange() {
    this.dataSource.setData(this.vm.searchResults[this.curTabIndex].itemList);
  }

  @Monitor('bp')
  onChange() {
    this.calculateWidth();
    this.vm.closePop();
    this.vm.toggleState(this.bp);
  }

  @Builder
  itemBuilder(item: StoreInfo) {
    Row() {
      Row() {
        Image($r('app.media.store'))
          .width(24)
          .margin({ right: 8 })
        Text(item.name)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Start)
      }

      Text(item.distance)
        .width(36)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)

    Text(item.address)
      .width('100%')
      .fontSize($r('sys.float.Body_M'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_secondary'))
      .textAlign(TextAlign.Start)
      .margin({ top: 8 })
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Row() {
            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r('sys.symbol.chevron_left'))
                .fontColor([$r('sys.color.icon_primary')])
                .fontSize(Constants.CHEVRON_WIDTH)
            }
            .width(Constants.BACK_BACKGROUND_WIDTH)
            .height(Constants.BACK_BACKGROUND_HEIGHT)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
          }
          .margin({ right: Constants.SPACE_S })
          .onClick(() => {
            this.routerStack?.pop?.();
            if ((['lg', 'xl'].includes(this.bp)) && this.vm.isShallowWindow) {
              this.vm.showPopupInResult = false;
              this.vm.isResultPopup = false;
              this.vm.initSearchParam();
            }
          });

          Text('门店搜索')
            .width(136)
            .lineHeight(27)
            .fontSize(20)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(700)
        }
        .width('100%')
        .padding({
          left: GridRowColSetting.getPageMargin(this.bp),
          right: GridRowColSetting.getPageMargin(this.bp),
        })
        .justifyContent(FlexAlign.Start)

        GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
          GridCol({
            span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS,
          }) {
            Row() {
              SearchBar({
                placeholder: this.vm.placeholder,
                searchWords: this.vm.searchWords,
                themeColor: this.vm.themeColor,
                controller: this.vm.searchResultController,
                isResult: this.vm.isResultPopup,
                updateSearchWords: (value) => {
                  if ((['lg', 'xl'].includes(this.bp)) && this.vm.isShallowWindow) {
                    if (this.vm.isResultPopup) {
                      this.vm.searchQuery(value, this.vm.searchSuggestion)
                    }
                  } else {
                    this.vm.searchQuery(value, this.vm.searchSuggestion)
                  }
                },
                submitSearch: (value) => {
                  if (AppStorage.get('currentCity') === '北京' || AppStorage.get('currentCity') === '北京市') {
                    this.storeSearchList = STORE_SEARCH_RESULTS1.filter(store => store.address.includes(value))
                  } else if (AppStorage.get('currentCity') === '南京' || AppStorage.get('currentCity') === '南京市') {
                    this.storeSearchList = STORE_SEARCH_RESULTS2.filter(store => store.address.includes(value))
                  }

                  this.vm.submitSearch(this.uiContext, value, SearchSource.USER_INPUT, this.vm.handleSearch);
                  if ((['lg', 'xl'].includes(this.bp)) && this.vm.isShallowWindow) {
                    this.vm.closePop();
                  }
                },
              })
                .layoutWeight(1)
                .constraintSize({
                  maxWidth: ((['lg', 'xl'].includes(this.bp)) && this.vm.isShallowWindow) ?
                  GridRowColSetting.DIALOG_MAX_WIDTH : 'auto'
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
                    Logger.info(TAG, `onStateChange======== ${JSON.stringify(event.isVisible)}`);
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

        List({ space: Constants.SPACE_L, scroller: this.scroller }) {
          ForEach(this.storeSearchList, (gridItem: StoreInfo) => {
            ListItem() {
              Column() {
                this.itemBuilderParam(gridItem)
              }
              .justifyContent(FlexAlign.Center)
            }
            .onClick(() => {
              this.onItemClick(gridItem)
            })
          }, (gridItem: StoreInfo) => JSON.stringify(gridItem))
        }
        .visibility(this.storeSearchList.length !== 0 && this.vm.searchWords.length !== 0
          ? Visibility.Visible : Visibility.None)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .listDirection(Axis.Vertical)
        .layoutWeight(1)
        .height(Constants.FULL_PERCENT)
        .scrollBar(BarState.Off)
        .sticky(StickyStyle.None)
        .onScrollIndex((start: number) => {
          if (!this.scrollStatus) {
            this.curSubIndex = start
            this.subBarScroller.scrollToIndex(start, true)
          }
        })
        .margin({
          top: Constants.PADDING_L,
          left: GridRowColSetting.getPageMargin(this.bp),
          right: GridRowColSetting.getPageMargin(this.bp)
        })

        Scroll() {
          Column() {
            HistorySearch({
              breakpoint: this.bp,
              maxLen: this.maxLen,
              columnWidth: this.columnWidth,
              deleteHistoryList: this.vm.deleteHistoryList,
              selectHistoryItem: (value) => {
                this.vm.submitSearch(this.uiContext, value, SearchSource.HISTORY, this.vm.handleSearch);
                if (AppStorage.get('currentCity') === '北京' || AppStorage.get('currentCity') === '北京市') {
                  this.storeSearchList = STORE_SEARCH_RESULTS1.filter(store => store.address.includes(value.content))
                } else if (AppStorage.get('currentCity') === '南京' || AppStorage.get('currentCity') === '南京市') {
                  this.storeSearchList = STORE_SEARCH_RESULTS2.filter(store => store.address.includes(value.content))
                }

                this.vm.submitSearch(this.uiContext, value.content, SearchSource.USER_INPUT, this.vm.handleSearch);
              },
              queryHistoryList: this.vm.queryHistoryList
            })
          }
        }
        .visibility(this.storeSearchList.length !== 0 ? Visibility.None : Visibility.Visible)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .layoutWeight(1)
        .margin({
          left: GridRowColSetting.getPageMargin(this.bp),
          right: GridRowColSetting.getPageMargin(this.bp),
        })
      }
      .padding({ top: 46 })
      .margin({ bottom: 20 })
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.End)
      .height(Constants.FULL_PERCENT)
      .width(Constants.FULL_PERCENT)
      .onClick(() => {
        if ((['lg', 'xl'].includes(this.bp)) && this.vm.isShallowWindow) {
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
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.routerStack = ctx.pathStack;
    })
  }

  @Builder
  searchWindowBuilder() {
    if (this.vm.showSearchSuggestionRspInResult) {
      SearchAutoComplete({
        breakpoint: 'sm',
        themeColor: this.vm.themeColor,
        itemBuilderParam: this.vm.suggestionItemBuilderParam,
        selectSuggestionItem: (value) => {
          this.vm.closePop();
          this.vm.submitSearch(this.uiContext, value, SearchSource.SUGGESTION, this.vm.handleSearch);
        },
      })
        .constraintSize({ maxHeight: 'calc(100% - 148vp)' })

    } else {
      Scroll() {
        Column() {
          HistorySearch({
            breakpoint: 'sm',
            maxLen: 2 * ((400 - 56) / 4) + 8,
            columnWidth: (400 - 56) / 4,
            deleteHistoryList: this.vm.deleteHistoryList,
            selectHistoryItem: (value) => {
              this.vm.closePop();
              this.vm.submitSearch(this.uiContext, value, SearchSource.HISTORY, this.vm.handleSearch);
            },
            queryHistoryList: this.vm.queryHistoryList
          })

          if (this.vm.showGuessLike) {
            GuessLike({
              breakpoint: 'sm',
              itemBuilderParam: this.vm.guessItemBuilderParam,
              selectGuessLikeItem: (value) => {
                this.vm.closePop();
                this.vm.submitSearch(this.uiContext, value, SearchSource.RECOMMEND, this.vm.handleSearch);
              },
              queryGuessList: this.vm.queryGuessList
            })
          }

          if (this.vm.showHotSearch) {
            HotSearch({
              breakpoint: 'sm',
              itemBuilderParam: this.vm.hotItemBuilderParam,
              getMore: this.vm.getMore,
              selectHotSearchItem: (value) => {
                this.vm.closePop();
                this.vm.submitSearch(this.uiContext, value, SearchSource.HOT_SEARCH, this.vm.handleSearch);
              },
              queryHotSearchList: this.vm.queryHotSearchList
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

  calculateWidth = () => {
    this.columnWidth = (this.containerWidth - GridRowColSetting.getGutter(this.bp) *
      (GridRowColSetting.getWindowColumn(this.bp) - 1)) /
    GridRowColSetting.getWindowColumn(this.bp);
    this.maxLen = GridRowColSetting.getMaxColumns(this.bp) * this.columnWidth +
      GridRowColSetting.getMaxGutter(this.bp) * GridRowColSetting.getGutter(this.bp)
  }
}