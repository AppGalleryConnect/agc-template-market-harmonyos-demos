import { BookBigCard, BookInfo, Constants, LazyDataVM, NavHeaderBar, TCRouter } from 'common';

export interface CategoryInfo {
  category: ResourceStr;
  books: BookInfo[]
}

/**
 * 书纵卡
 */
@ComponentV2
export struct BookViewListPage {
  @Local books: LazyDataVM<BookInfo> | undefined;
  @Local category: ResourceStr | undefined = '';

  async aboutToAppear(): Promise<void> {
    const p = TCRouter.getParams<CategoryInfo>(Constants.BOOK_LIST_ROUTE);
    this.category = p?.category;
    this.books = new LazyDataVM<BookInfo>(p?.books);
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          NavHeaderBar({
            title: this.category,
            hasBackButton: true,
            hasBgColor: false,
            isMainPage: true,
          })
          List({ space: 10 }) {
            LazyForEach(this.books, (item: BookInfo) => {
              ListItem() {
                BookBigCard({ info: item })
              }
            }, (item: string) => item)
          }
          .scrollBar(BarState.Off)
          .padding({
            top: 20,
            left: 18,
            right: 18,
            bottom: 18
          })
          .cachedCount(3)
          .layoutWeight(1)
        }
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
    }
    .hideTitleBar(true)
  }
}