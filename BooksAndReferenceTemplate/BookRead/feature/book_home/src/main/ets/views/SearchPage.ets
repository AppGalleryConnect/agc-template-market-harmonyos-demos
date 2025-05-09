import { BookApi, BookBigCard, BookInfo, Constants, GetBookApiRsp, LazyDataVM } from 'common'

@ComponentV2
export struct SearchPage {
  @Local changeValue: string = '';
  @Local submitValue: string = '';
  @Local isSubmit: boolean = false;
  @Local books: BookInfo[] = [];
  controller: SearchController = new SearchController();
  windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;

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
          Search({
            value: this.changeValue,
            placeholder: $r('app.string.search_placeholder'),
            controller: this.controller
          })
            .searchButton('搜索')
            .width('95%')
            .height(40)
            .backgroundColor('#F5F5F5')
            .defaultFocus(true)
            .enableKeyboardOnFocus(true)
            .placeholderColor(Color.Grey)
            .placeholderFont({ size: 14, weight: 400 })
            .textFont({ size: 14, weight: 400 })
            .onSubmit(async (value: string) => {
              this.submitValue = value;
              this.isSubmit = true;
              await this.searchBook(this.submitValue);
            })
            .onChange((value: string) => {
              this.changeValue = value;
            })
            .margin({
              left: 18,
              right: 18,
              top: 16 + this.windowTopHeight,
              bottom: 8,
            });

          if (this.isSubmit) {
            List({ space: 10 }) {
              ForEach(this.books, (item: BookInfo) => {
                ListItem() {
                  BookBigCard({ info: item })
                }
              }, (item: string) => JSON.stringify(item))
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)
            .padding({
              top: 20,
              left: 18,
              right: 18,
              bottom: 18
            })
            .cachedCount(3)
          }
        }
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
    }
    .hideTitleBar(true)
  }
}