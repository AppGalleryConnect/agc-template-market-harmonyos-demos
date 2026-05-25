import {
  BookApi,
  BookInfo,
  Constants,
  GetBookApiRsp,
  GetHotBookListRsp,
  rankListInfo,
  TCRouter
} from 'common';
import { SearchViewModels } from '../viewModels/SearchViewModels';
import { LengthMetrics } from '@kit.ArkUI';
import { HotRankCard, SearchResultCard } from '../comps/HotRankCard';
import { LazyDataVM } from 'swiper_card'

export interface CategoryInfo {
  category: string;
  isCategory: boolean
}

@ComponentV2
export struct SearchPage {
  @Local category: string | undefined = '';
  @Local isCategory: boolean | undefined = false;
  @Local submitValue: string | undefined = '';
  @Local isSubmit: boolean = false;
  @Local isUpdater: boolean = false;
  @Local isSure: boolean = false;
  @Local books: BookInfo[] = [];
  @Local rankInfos: LazyDataVM<rankListInfo> | undefined = undefined;
  controller: SearchController = new SearchController();
  windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  searchVM: SearchViewModels = SearchViewModels.instance;

  async aboutToAppear(): Promise<void> {
    // 获取热搜榜排名数据
    this.rankInfos = await this.getRankInfo();

    const p = TCRouter.getParams<CategoryInfo>(Constants.SEARCH_ROUTE);
    if (p) {
      this.category = p?.category;
      this.isCategory = p?.isCategory;
    }else{
      this.searchVM.keyword = ''
    }

    if (this.isCategory) {
      this.isSubmit = true;
      this.isSure = true;
      this.searchVM.keyword = this.category as string;
      this.isUpdater = true;
      this.submitValue = this.category;
    }
  }

  async searchCategoryBook(value: string) {
    const rsp: GetBookApiRsp = await BookApi.getBookList();
    let tmp: BookInfo[] = [];
    for (let i = 0; i < rsp.books.length; i++) {
      if (this.fuzzySearch(rsp.books[i].category, value)) {
        tmp.push(rsp.books[i]);
      }
    }
    this.books = tmp;
  }

  async getRankInfo(): Promise<LazyDataVM<rankListInfo>> {
    let rsp: GetHotBookListRsp = await BookApi.getHotRankList();
    return new LazyDataVM<rankListInfo>(rsp.rankList);
  }

  async searchBook(value: string) {
    const rsp: GetBookApiRsp = await BookApi.getBookList();
    let tmp: BookInfo[] = [];
    for (let i = 0; i < rsp.books.length; i++) {
      if (this.fuzzySearch(rsp.books[i].name, value) || this.fuzzySearch(rsp.books[i].author, value)) {
        tmp.push(rsp.books[i]);
      }
    }
    this.books = tmp;
  }

  fuzzySearch(target: string, query: string): boolean {
    const lowerTarget = target.toLowerCase();
    const lowerQuery = query.toLowerCase();
    return lowerTarget.includes(lowerQuery);
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          Row() {
            Image($r('app.media.ic_back')).height('40vp').width('40vp')
              .margin({ top: 16 + this.windowTopHeight, right: '8vp' })
              .onClick(() => {
                TCRouter.pop();
              })

            Search({
              value: this.searchVM.keyword,
              placeholder: $r('app.string.search_placeholder')
            })
              .enableKeyboardOnFocus(this.isCategory ? false : true)
              .layoutWeight(1)
              .defaultFocus(this.isCategory ? false : true)
              .placeholderColor($r('sys.color.font_secondary'))
              .placeholderFont({ size: $r('sys.float.Body_L') })
              .textFont({ size: $r('sys.float.Body_L') })
              .onSubmit(async (value: string) => {
                this.submitValue = value;
                this.isSubmit = true;
                await this.searchBook(this.submitValue);
                this.searchVM.searchDishes();
              })
              .onFocus(() => {
                this.isSubmit = false;
                this.isUpdater = false;
              })
              .onChange((value: string) => {
                this.searchVM.keyword = value;
                if (value.length === 0) {
                  this.submitValue = value;
                  this.isSubmit = false;
                  this.isUpdater = false;
                } else {
                  this.submitValue = value;
                  this.isSubmit = true;
                  this.isUpdater = this.isSure ? true : false

                  this.isSure = false;
                  if (this.isCategory) {
                    this.searchCategoryBook(this.submitValue);
                  } else {
                    this.searchBook(this.submitValue);
                  }
                  this.isCategory = false;

                }

              })
              .margin({ top: 16 + this.windowTopHeight });

          }

          if (this.isSubmit) {
            if (this.books.length === 0) {
              Column() {
                Image($r('app.media.SearchNoResult'))
                  .height('120vp').width('120vp')
                  .margin({ right: '2vp', top: '20%' })
                Text($r('app.string.noSearchResult'))
                  .fontSize($r('sys.float.Subtitle_S'))
                  .fontColor($r('sys.color.font_secondary'))
                  .fontWeight(FontWeight.Regular)
                  .margin({ top: 12 })
                  .opacity(0.6);
              }.width('100%').height('100%')
            } else {
              if (this.isUpdater) {
                Column() {
                  Text($r('app.string.searchResult'))
                    .fontSize($r('sys.float.Subtitle_L'))
                    .fontColor($r('sys.color.font_primary'))
                    .fontWeight(FontWeight.Medium)
                    .textAlign(TextAlign.Start)
                    .padding({ bottom: '20vp' })

                  List({ space: 10 }) {
                    ForEach(this.books, (item: BookInfo) => {
                      ListItem() {
                        SearchResultCard({ info: item })
                      }
                    }, (item: string) => JSON.stringify(item))
                  }
                  .scrollBar(BarState.Off)
                  .edgeEffect(EdgeEffect.Spring)
                  .layoutWeight(1)
                }
                .padding({ top: '20vp' })
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              } else {
                List({ space: 10 }) {
                  ForEach(this.books, (item: BookInfo) => {
                    ListItem() {
                      Column() {
                        Row() {
                          Image($r('app.media.ic_search_01'))
                            .height('13vp')
                            .width('13vp')
                            .margin({ right: 16 })
                          Column() {
                            Text() {
                              Span(item?.name.substring(0, item?.name.indexOf(this.searchVM.keyword)))
                              // 红色高亮文字
                              Span(this.searchVM.keyword).fontColor('#F17F31')
                              Span(item.name.substring(item.name.indexOf(this.searchVM.keyword) +
                              this.searchVM.keyword.length, item.name.length))
                            }.onClick(() => {
                              this.searchVM.keyword = item.name;
                              this.submitValue = item.name;
                              this.isSure = true;
                              this.isSubmit = true;
                              this.isUpdater = true;
                            })
                            .height('100%')
                            .width('100%')
                          }
                          .width('296vp')
                        }
                        .width('100%')
                        .height('48vp')
                        Divider().margin({ right: 16, left: 26 })
                      }
                    }
                  }, (item: string) => JSON.stringify(item))
                }
                .scrollBar(BarState.Off)
                .edgeEffect(EdgeEffect.Spring)
                .layoutWeight(1)
                .padding({ top: '20vp' })
              }
            }
          } else {
            this.searchRecordBuilder();
            this.hotSearchBuilder();
          }
        }
        .padding({ left: '16vp', right: '16vp' })
        .width('100%')
        .height('100%')
        .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
  }

  @Builder
  searchRecordBuilder() {
    if (this.searchVM.historyInfo.length) {
      Row() {
        Text($r('app.string.searchHistory')).fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium);

        Row() {
          Image($r('app.media.ic_delete'))
            .height('16vp')
            .margin({ right: '2vp' })
          Text($r('app.string.clearHistory'))
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
        }.onClick(() => {
          this.searchVM.historyInfo = [];
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: '12vp', top: '24vp' })

      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) } }) {
        ForEach(this.searchVM.historyInfo, (item: string, index) => {
          Text(item)
            .labelBaseStyle()
            .onClick(() => {
              this.searchVM.keyword = item;
              this.submitValue = item;
              this.isSubmit = true;
              this.searchBook(this.submitValue);
              this.searchVM.searchDishes();
            });
        }, (item: string, index) => item + index.toString());
      };
    }
    Text($r('app.string.hotSearch'))
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Medium)
      .margin({ top: 24, bottom: 14 })
      .width('100%');

    Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) } }) {
      ForEach(this.searchVM.hotInfo, (item: string, index) => {
        Text(item)
          .labelBaseStyle()
          .onClick(() => {
            this.searchVM.keyword = item;
            this.submitValue = item;
            this.isSubmit = true;
            this.searchBook(this.submitValue);
            this.searchVM.searchDishes();
          });
      }, (item: string, index) => item + index.toString());
    };
  }

  @Builder
  hotSearchBuilder() {
    List({ space: 20, initialIndex: 0 }) {
      LazyForEach(this.rankInfos, (item: rankListInfo) => {
        ListItem() {
          HotRankCard({ info: item })
        }
      }, (item: string) => item)
    }
    .listDirection(Axis.Horizontal) // 排列方向
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .margin({ top: 24, bottom: 24 })
    .cachedCount(3)
    .layoutWeight(1)
  }
}

@Extend(Text)
function labelBaseStyle() {
  .padding({
    top: 4,
    bottom: 4,
    left: 16,
    right: 16,
  })
  .fontSize($r('sys.float.Body_M'))
  .fontColor($r('sys.color.font_primary'))
  .fontWeight(FontWeight.Medium)
  .borderRadius(14)
  .backgroundColor('#0D000000')
  .focusable(true)
  .focusOnTouch(true);
}
