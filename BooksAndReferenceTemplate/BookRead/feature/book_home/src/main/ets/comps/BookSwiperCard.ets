import { BookInfo, Constants, LazyDataVM, TCRouter, TUISwiper } from 'common'


@Builder
function bookSingleSwiper(info?: BookInfo) {
  Column() {
    Image($r(info?.coverUrl?.toString()))
      .width(150)
      .height(200)
      .borderRadius(10)

    Column() {
      Text(info?.name)
        .padding({ top: 3 })
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Row() {
        Image($r('app.media.ic_public_star'))
          .height(15)
          .width(20)
          .padding({ right: 8 })
        Text(`${info?.rate} ${info?.category}|${info?.author}`)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
      }
      .padding({ top: 10 })
    }
    .padding({ top: 5 })
  }
  .width(150)
}

const bookSingleSwiperBuilder: WrappedBuilder<[BookInfo]> = wrapBuilder(bookSingleSwiper);

@ComponentV2
export struct BookSwiperCard {
  @Param @Require books: LazyDataVM<BookInfo>
  @Local imgHeight: number = 250
  @Local imgWidth: number = 150
  @Local builderList: WrappedBuilder<[BookInfo]>[] = []

  aboutToAppear(): void {
    this.builderList.push(bookSingleSwiperBuilder);
    this.builderList.push(bookSingleSwiperBuilder);
    this.builderList.push(bookSingleSwiperBuilder);
  }

  build() {
    Column() {
      TUISwiper({
        imgWidth: this.imgWidth,
        imgHeight: this.imgHeight,
        builderList: this.builderList,
        bookList: this.books,
        isLoop: true,
        isCovered: false,
        onImageClick: (index: number) => {
          let book = this.books.getData(index);
          TCRouter.push(Constants.READ_ROUTER, book);
        }
      })
    }
  }
}