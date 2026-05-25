import {
  BookApi,
  BookInfo,
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  Constants,
  GetBookApiRsp,
  MinorsMode,
  MinorsProtectionUtils,
  TCRouter,
} from 'common';
import { BookListCard } from '../comps/BookListCard';
import { BookSwiperCard } from '../comps/BookSwiperCard';
import { BookViewCard } from '../comps/BookViewCard';
import { LazyDataVM } from 'swiper_card';
import { AppStorageV2 } from '@kit.ArkUI';
import { fp2pxUtil } from 'base_common';

@Builder
export function BookListPageBuilder() {
  BookListPage();
}


@ComponentV2
export struct BookListPage {
  @Local books: LazyDataVM<BookInfo> | undefined = undefined;
  @Local recommendBooks: LazyDataVM<BookInfo> | undefined = undefined;
  @Local childBooks: LazyDataVM<BookInfo> | undefined = undefined;
  @Local swiperImg: Resource[] = new Array(4).fill('').map((item: string, index) => {
    return index % 2 ? $r(`app.media.swiper_list_0`) : $r(`app.media.swiper_list_1`)
  })
  @Local categoryText: Resource[] = [];
  @Local currentIndex: number = 0;
  @Param currentNumber: number = 0;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local headerPosition: number = 0;
  @Local listStartOffset: number = this.windowTopHeight + 56;
  private tabsListController: TabsController = new TabsController()
  private scroller = new Scroller();
  private rowScroller: Scroller = new Scroller()
  @Local minorsMode: MinorsMode =
    AppStorageV2.connect(MinorsMode, 'isMinorsMode', () => new MinorsMode(MinorsProtectionUtils.getMinorsMode()))!

  @Monitor('minorsMode.isMinorsMode')
  async onMinorChange(monitor: IMonitor) {
    this.initCategoryText();
  }

  async aboutToAppear(): Promise<void> {
    await this.getHomeBooks();
    await this.getRecommendBooks();
    await this.getChildBooks();
    this.initCategoryText();
  }

  initCategoryText() {
    if (this.minorsMode.isMinorsMode) {
      this.categoryText =
        [$r('app.string.children_literature'), $r('app.string.science_nature'), $r('app.string.poetry_prose'),
          $r('app.string.masterpiece_historical'), $r('app.string.literary_classics'),
          $r('app.string.revolutionary_spirit')]
    } else {
      this.categoryText = [$r('app.string.recommend'), $r('app.string.boys_channel'), $r('app.string.girls_channel')]
    }
  }

  async getHomeBooks() {
    const rsp: GetBookApiRsp = await BookApi.getBookList();
    this.books = new LazyDataVM<BookInfo>(rsp.books);
  }

  async getRecommendBooks() {
    const rsp: GetBookApiRsp = await BookApi.getRecommendBookList();
    this.recommendBooks = new LazyDataVM<BookInfo>(rsp.books);
  }

  async getChildBooks() {
    const rsp: GetBookApiRsp = await BookApi.getChildBookList();
    this.childBooks = new LazyDataVM<BookInfo>(rsp.books);
  }

  // 区分各类频道
  async filterBook(status: string) {
    const rsp: GetBookApiRsp = await BookApi.getBookList();
    let tmp: BookInfo[] = status === '0' ? rsp.books : rsp.books.filter(book => book.gender === status);
    this.books?.pushArrayData(tmp);

    const recommendRsp: GetBookApiRsp = await BookApi.getRecommendBookList();
    let recommendTmp: BookInfo[] =
      status === '0' ? recommendRsp.books : recommendRsp.books.filter(book => book.gender === status);
    this.recommendBooks?.pushArrayData(recommendTmp);

    const childRsp: GetBookApiRsp = await BookApi.getChildBookList();
    let childTmp: BookInfo[] = status === '0' ? childRsp.books : childRsp.books.filter(book => book.gender === status);
    this.childBooks?.pushArrayData(childTmp);
  }

  @Builder
  swiperInfo() {
    Swiper() {
      ForEach(this.swiperImg, (item: Resource) => {
        Image(item)
          .height(168)
          .width(Constants.FULL_SIZE)
          .borderRadius(10)
      }, (item: string) => new Date().toString())
    }
    .autoPlay(true)
    .padding({ top: 20, left: 18, right: 18 })
  }

  @Builder
  categoryTab() {
    Row() {
      Row() {
        Scroll(this.rowScroller) {
          Row({ space: 12 }) {
            ForEach(this.categoryText, (item: ResourceStr, index: number) => {
              Text(item)
                .textAlign(TextAlign.Center)
                .fontSize(fp2pxUtil(16))
                .fontColor(this.currentIndex === index ? $r('sys.color.ohos_id_color_background') :
                  $r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
                .height(36)
                .width(96)
                .backgroundColor(this.currentIndex === index ? $r('sys.color.multi_color_08') :
                  ($r('sys.color.comp_background_tertiary')))
                .borderRadius(21)
                .onClick(async () => {
                  this.currentIndex = index
                  if (index === 0) {
                    await this.filterBook('0');
                  } else if (index === 1) {
                    await this.filterBook('2');
                  } else {
                    await this.filterBook('1');
                  }
                })
            }, (item: string) => new Date().toString())
          }
          .padding({ right: this.headerPosition < 0 ? 48 : 0 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }
      .padding({
        top: 10,
        bottom: 10,
        left: 16,
        right: this.headerPosition < 0 ? 16 : 16
      })
      .width(this.minorsMode.isMinorsMode ? '100%' :
        this.curBreakpoint.value === BreakpointTypeEnum.SM ? Constants.FULL_SIZE : '50%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .backgroundBlurStyle(BlurStyle.COMPONENT_THIN)
  }

  @Builder
  bookList(books: LazyDataVM<BookInfo> | undefined, recommendBooks: LazyDataVM<BookInfo> | undefined) {
    BookListCard({ books: recommendBooks, categoryName: $r('app.string.daily_recommendation') });
    if (!this.minorsMode.isMinorsMode) {
      BookViewCard({ books: books, categoryName: $r('app.string.recommend_for_you') });
    }
  }

  @Builder
  dailyRecommendation(books: LazyDataVM<BookInfo> | undefined) {
    BookListCard({ books: books, categoryName: $r('app.string.daily_recommendation') });
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        Row()
          .width('100%')
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .backgroundBlurStyle(BlurStyle.COMPONENT_THIN)
          .height(this.windowTopHeight)
        Row() {
          Text(this.minorsMode.isMinorsMode ? '书城' : '首页')
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Title_M'))
            .fontWeight(FontWeight.Medium)
            .padding({ left: 16 })
        }
        .width('100%')
        .height(56 + this.windowTopHeight)
        .padding({ top: this.windowTopHeight + 8 })
        .justifyContent(FlexAlign.Start)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .backgroundBlurStyle(BlurStyle.COMPONENT_THIN)
        .position({ y: this.headerPosition })
        .zIndex(10);

        List({ scroller: this.scroller }) {
          ListItem() {
            if (!this.minorsMode.isMinorsMode) {
              BookSwiperCard({ books: this.books });
            }
          }

          ListItemGroup({ header: this.categoryTab() }) {
            ListItem() {
              Column() {
                BookListCard({
                  books: this.minorsMode.isMinorsMode ? this.childBooks : this.recommendBooks,
                  categoryName: $r('app.string.daily_recommendation')
                });
                if (!this.minorsMode.isMinorsMode) {
                  BookViewCard({
                    books: this.books,
                    categoryName: $r('app.string.recommend_for_you')
                  })
                }
              }
              .width('100%')
            }
          }
        }
        .width('100%')
        .layoutWeight(1)
        .sticky(StickyStyle.Header)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .contentStartOffset(this.listStartOffset)
        .nestedScroll({
          scrollForward: NestedScrollMode.PARENT_FIRST,
          scrollBackward: NestedScrollMode.SELF_FIRST
        })
        .onDidScroll(() => {
          let secondRect = this.scroller.getItemRect(1);
          this.headerPosition = Math.min(0, secondRect.y - 56);
          this.listStartOffset = Math.max(0, 56 + this.headerPosition);
        });
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))

      Row() {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize($r('sys.float.Title_M'))
          .fontColor([$r('sys.color.icon_primary')])
          .width(40)
          .height(40)
          .borderRadius(1000)
          .padding(8)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
      .height(56)
      .width(64)
      .padding({ left: 8 })
      .backdropBlur(20)
      .margin({ top: this.windowTopHeight })
      .onClick(() => {
        TCRouter.push(Constants.SEARCH_ROUTE);
      })
    }
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}