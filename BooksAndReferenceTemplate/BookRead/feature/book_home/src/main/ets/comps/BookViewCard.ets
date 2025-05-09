import { BookInfo, BookLittleCard, Constants, LazyDataVM, TCRouter } from 'common';

/**
 * 书横卡
 */
@ComponentV2
export struct BookViewCard {
  @Param categoryName: ResourceStr = '';
  @Param @Require books: LazyDataVM<BookInfo>

  aboutToAppear(): void {
  }

  @Builder
  bookCategoryBar(category: ResourceStr) {
    Row() {
      Text(category)
        .fontColor($r('sys.color.font_primary'))
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
      Row() {
        Text($r('app.string.more'))
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
        Image($r('app.media.arrow_right'))
          .height(20)
          .width(20)
      }
      .onClick(() => {
        TCRouter.push(Constants.BOOK_LIST_ROUTE, { category: this.categoryName, books: this.books.getAllData() })
      })
    }
    .width('100%')
    .height(30)
    .padding({ bottom: 15 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    Column() {
      this.bookCategoryBar(this.categoryName)
      List({ space: 3 }) {
        LazyForEach(this.books, (item: BookInfo) => {
          ListItem() {
            BookLittleCard({ info: item })
              .width(120)
              .height(160)
              .padding({ left: 5, right: 5 })
          }
        }, (item: string) => new Date().toString())
      }
      .cachedCount(3)
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
    }
    .width(Constants.FULL_SIZE)
    .height(240)
    .padding({
      top: 25,
      left: 18,
      right: 18,
      bottom: 20
    })
  }
}
