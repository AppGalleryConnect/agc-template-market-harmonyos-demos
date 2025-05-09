import { BookApi, BookInfo, Constants, GetBookApiRsp, LazyDataVM, NavHeaderBar, TSearch, WindowUtils } from 'common';
import { EpubParser, PageRect } from 'parse';

import { BookSwiperCard } from '../comps/BookSwiperCard';
import { BookViewCard } from '../comps/BookViewCard';
import { BookWaterFlowCard } from '../comps/BookWaterFlowCard';

@ComponentV2
export struct BookListPage {
  @Local books: LazyDataVM<BookInfo> | undefined = undefined;
  @Local swiperImg: Resource[] = new Array(4).fill('').map((item: string, index) => {
    return index%2 ? $r(`app.media.swiper_list_0`) : $r(`app.media.swiper_list_1`)
  })
  @Local categoryText: Resource[] = [];
  @Local currentIndex: number = 0;

  async aboutToAppear(): Promise<void> {
    this.init();
    await this.getHomeBooks();

    this.categoryText.push($r('app.string.recommend'));
    this.categoryText.push($r('app.string.member'));
    this.categoryText.push($r('app.string.free'));
  }

  init() {
    const rect: PageRect = {
      mRowSize: px2vp(500),
      mPadding: px2vp(200),
      mTop: px2vp(30),
      mBottom: px2vp(1200),
    }
    EpubParser.initManager(WindowUtils.getWindowWidth(), WindowUtils.getWindowHeight(), rect, 70);
  }

  async getHomeBooks() {
    const rsp: GetBookApiRsp = await BookApi.getBookList();
    this.books = new LazyDataVM<BookInfo>(rsp.books);
  }

  async filterBook(status: boolean) {
    const rsp: GetBookApiRsp = await BookApi.getBookList();
    let tmp: BookInfo[] = [];
    for (let i = 0; i < rsp.books.length; i++) {
      if (rsp.books[i].isFree === status) {
        tmp.push(rsp.books[i]);
      }
    }

    this.books = new LazyDataVM<BookInfo>(tmp);
  }

  @Builder
  swiperInfo() {
    Swiper() {
      ForEach(this.swiperImg, (item: Resource) => {
        Image(item)
          .height(168)
          .width(Constants.FULL_SIZE)
          .borderRadius(10)
      },(item: string) => new Date().toString())
    }
    .autoPlay(true)
    .padding({ top: 20, left: 18, right: 18 })
  }

  @Builder
  categoryTab() {
    List({ space: 15 }) {
      ForEach(this.categoryText, (item: ResourceStr, index: number) => {
        ListItem() {
          Text(item)
            .textAlign(TextAlign.Center)
            .fontSize($r('sys.float.Body_L'))
            .fontColor(this.currentIndex === index ? Color.White : $r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .height(40)
            .width(100)
            .backgroundColor(this.currentIndex === index ? Color.Black : $r('app.color.common_background'))
            .borderRadius(21)
            .onClick(async () => {
              this.currentIndex = index
              if (index === 0) {
                await this.getHomeBooks();
              } else if (index === 1) {
                await this.filterBook(false);
              } else {
                await this.filterBook(true);
              }
            })
        }
      },(item: string) => new Date().toString())
    }
    .scrollBar(BarState.Off)
    .listDirection(Axis.Horizontal)
    .padding({ top: 20, left: 18, right: 18 })
  }

  @Builder
  bookList(books: LazyDataVM<BookInfo> | undefined) {
    BookViewCard({ books: books, categoryName: $r('app.string.popular_book') });
    BookViewCard({ books: books, categoryName: $r('app.string.more_popular_book') });
    BookWaterFlowCard({ books: books });
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          NavHeaderBar({
            title: $r('app.string.book_home'),
            hasBackButton: false,
            hasBgColor: false,
            isMainPage: true,
          })

          Scroll() {
            Column() {
              TSearch();
              BookSwiperCard({ books: this.books });
              this.categoryTab();
              this.swiperInfo();

              if (this.currentIndex === 0) {
                this.bookList(this.books);
              } else if (this.currentIndex === 1) {
                this.bookList(this.books);
              } else {
                this.bookList(this.books);
              }
            }
          }.scrollBar(BarState.Off)
        }
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
    }
    .hideTitleBar(true)
  }
}