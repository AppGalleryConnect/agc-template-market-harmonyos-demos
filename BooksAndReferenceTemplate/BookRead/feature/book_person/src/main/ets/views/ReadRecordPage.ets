import { BookApi, BookInfo, Constants, FontModel, MathUtil, NavHeaderBar } from 'common';
import { ReadRecordCard } from 'book_home';
import { DeleteBottomCard } from 'book_shelf';
import { AppStorageV2 } from '@kit.ArkUI';


@ComponentV2
export struct ReadRecordPage {
  @Provider('isDeleteRecord') isDeleteRecord: boolean = false;
  @Local historyBooks: BookInfo[] = [];
  scroller: Scroller = new Scroller()
  @Local deleteBooks: Set<string> = new Set();
  @Local isSelectAll: boolean = false;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  async aboutToAppear(): Promise<void> {
    const hisRsp = await BookApi.getBooksShelfList('historyBooks', Constants.API_GET_BOOK_HISTORY_PATH, '');
    this.historyBooks = hisRsp.books;
    this.isDeleteRecord = false;
  }

  deleteBookList(bookType: string, bookList: BookInfo[]) {
    let tmp: BookInfo[] = [];
    for (let i = 0; i < bookList.length; i++) {
      bookList[i].isSelect = false
      if (!this.deleteBooks.has(bookList[i].name)) {
        tmp.push(bookList[i]);
      }
    }

    bookList.length = tmp.length;
    for (let i = 0; i < tmp.length; i++) {
      bookList[i] = tmp[i];
    }

    AppStorage.set(bookType, tmp);
    this.isDeleteRecord = false;
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '阅读记录',
          hasBackButton: true,
          hasBgColor: false,
          isMainPage: false,
          isRecord: true
        })
        this.bookShelfListHistory(this.historyBooks);
        if (this.isDeleteRecord) {
          DeleteBottomCard({
            isShelf: false,
            selectAll: (isSelectAll: boolean) => {
              if (isSelectAll) {
                this.isSelectAll = false
                this.historyBooks.forEach((info: BookInfo) => {
                  info.isSelect = false
                })
              } else {
                this.isSelectAll = true
                this.historyBooks.forEach((info: BookInfo) => {
                  info.isSelect = true
                })
              }
            },
            delete: () => {
              this.deleteBookList('historyBooks', this.historyBooks)
            }
          })
            .margin({ bottom: 28 })
        }
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  bookShelfListHistory(infos: BookInfo[] | undefined) {
    Column({ space: 8 }) {
      Text('最近七天')
        .fontSize(this.fontModel.getFg(12))
        .lineHeight(16)
        .fontColor($r('sys.color.font_secondary'))
      Scroll(this.scroller) {
        Column({ space: 8 }) {
          ForEach(infos, (info: BookInfo) => {
            Stack({ alignContent: Alignment.BottomEnd }) {
              ReadRecordCard({
                info: info, isSelectAll: this.isSelectAll, onDelete: (value: boolean) => {
                  if (value) {
                    this.deleteBooks.add(info.name);
                  } else {
                    this.deleteBooks.delete(info.name);
                  }
                }
              })
                .gesture(GestureGroup(GestureMode.Parallel,
                  LongPressGesture()
                    .onAction((event: GestureEvent) => {
                      // 针对书架列表
                      this.isDeleteRecord = true;
                    })
                ))
            }
          }, (item: BookInfo, index: number) => {
            return MathUtil.generateRandomNumber(16).toString();
          })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
      }
      .align(Alignment.Top)
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 15
    })
    .onClick(() => {
      this.isDeleteRecord = false;
      this.historyBooks.forEach((info: BookInfo) => {
        info.isSelect = false
      })
    })
  }
}