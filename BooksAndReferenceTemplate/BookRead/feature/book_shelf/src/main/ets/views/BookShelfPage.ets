import { BookApi, BookInfo, BookLittleCard, Constants, MathUtil, NavHeaderBar, TCRouter, UserInfo } from 'common';
import { DeleteBottomCard } from '../comps/DeleteBottomCard';


@ComponentV2
export struct BookShelfPage {
  @Local favBooks: BookInfo[] = [];
  @Local historyBooks: BookInfo[] = [];
  @Local isHistory: boolean = false;
  @Local test: string[] = [];
  @Local isDeleteShelf: boolean = false;
  @Local deleteBooks: Set<string> = new Set();
  @Local userInfo: UserInfo | undefined = undefined;
  scroller: Scroller = new Scroller()

  async aboutToAppear(): Promise<void> {
    const params = TCRouter.getParams<boolean>(Constants.SHELF_ROUTER);
    this.isHistory = params === undefined ? false : params;
    const favRsp = await BookApi.getBooksShelfList('favBooks',Constants.API_GET_BOOK_FAVOURITE_PATH,'');
    const hisRsp = await BookApi.getBooksShelfList('historyBooks', Constants.API_GET_BOOK_HISTORY_PATH,'');
    const userRsp = await BookApi.getUserInfo('');
    this.isDeleteShelf = false
    this.favBooks = favRsp.books;
    this.historyBooks = hisRsp.books;
    this.userInfo = userRsp.user;
  }

  deleteBookList(bookType: string, bookList: BookInfo[]) {
    let tmp: BookInfo[] = [];
    for (let i = 0; i < bookList.length; i++) {
      if (!this.deleteBooks.has(bookList[i].name)) {
        tmp.push(bookList[i]);
      }
    }

    bookList.length = tmp.length;
    for (let i = 0; i < tmp.length; i++) {
      bookList[i] = tmp[i];
    }

    AppStorage.set(bookType, tmp);
    this.isDeleteShelf = false;
  }

  @Builder
  readingInfo() {
    Column({ space: 20 }) {
      Row({ space: 5 }) {
        Text($r('app.string.today'))
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .margin({ right: 5 })

        Row({ space: 5 }) {
          Image($r('app.media.ic_public_reading'))
            .width(25)
            .height(25)
          Text(`${this.userInfo?.totalReading}${getContext().resourceManager.getStringByNameSync('minute')}`)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))

        }
        .width(80)

        Row({ space: 5 }) {
          Image($r('app.media.ic_public_headphones'))
            .width(25)
            .height(25)
          Text(`${this.userInfo?.totalListening}${getContext().resourceManager.getStringByNameSync('minute')}`)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
        }
        .width(80)
      }
      .margin({ top: 15 })
      .alignSelf(ItemAlign.Start)

      Text($r('app.string.reading_is_perfect'))
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('app.color.reading_is_perfect'))
        .alignSelf(ItemAlign.Start)
        .width(Constants.FULL_SIZE)
        .padding({
          top: 5
        })
    }
    .width(Constants.FULL_SIZE)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding({
      left: 16,
      right: 16,
      bottom: 20,
    })
    .margin({
      top: 30
    })
  }

  @Builder
  bookShelfGrid(infos: BookInfo[] | undefined, isHistory: boolean) {
    Column() {
      Grid(this.scroller) {
        ForEach(infos, (info: BookInfo) => {
          GridItem() {
            Stack() {
              BookLittleCard({ info: info })
                .gesture(GestureGroup(GestureMode.Parallel,
                  LongPressGesture()
                    .onAction((event: GestureEvent) => {
                      // 针对书架列表
                      this.isDeleteShelf = true;
                    })
                ))
              if (this.isDeleteShelf) {
                Checkbox({ name: 'delete', group: 'deleteGroup' })
                  .select(false)
                  .selectedColor($r('app.color.slider_selected_color'))
                  .unselectedColor($r('app.color.common_background'))
                  .shape(CheckBoxShape.CIRCLE)
                  .onChange((value: boolean) => {
                    if (value) {
                      this.deleteBooks.add(info.name);
                    } else {
                      this.deleteBooks.delete(info.name);
                    }
                  })
                  .padding({ top: 70, left: 70 })
              }
            }
          }
          .width(113)
          .height(180)
          .padding({ left: 5, right: 5, top: 10 })
        }, (item: BookInfo, index: number) => {
          return MathUtil.generateRandomNumber(16).toString();
        })

        if (!isHistory) {
          GridItem() {
            Column() {
              Image($r('app.media.ic_public_plus'))
                .width(40)
                .height(40)
              Text($r('app.string.go_and_go_home'))
                .width(104)
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_secondary'))
                .textAlign(TextAlign.Center)
                .padding({ top: 8 })
            }
          }
          .borderRadius(10)
          .width(113)
          .height(150)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .padding({ left: 5, right: 5, top: 10 })
          .margin({ top: 10 })
          .onClick(() => {
            TCRouter.replace(Constants.HOME_ROUTER)
          })
        }
      }
      .scrollBar(BarState.Off)
      .enableScrollInteraction(true)
      .maxCount(3)
      .rowsGap(10)
      .columnsGap(10)
      .edgeEffect(EdgeEffect.Spring)
      .columnsTemplate('1fr 1fr 1fr')
      .width(Constants.FULL_SIZE)
      .height('100%')
      .padding({ bottom: '30%' })
    }
    .padding({ bottom: 15 })
    .layoutWeight(1)
  }

  @Builder
  shelfHeader() {
    Row({ space: 10 }) {
      Row() {
        Text($r('app.string.book_list'))
          .fontSize(20)
          .fontColor(this.isHistory ? $r('sys.color.font_secondary') : $r('sys.color.font_primary'))
        Text(`(${this.favBooks?.length || 0})`)
          .fontSize(15)
          .fontColor(this.isHistory ? $r('sys.color.font_secondary') : $r('sys.color.font_primary'))
      }
      .onClick(() => {
        this.isHistory = false;
        this.isDeleteShelf = false
      })

      Text('|')
      Row() {
        Text($r('app.string.history'))
          .fontSize(20)
          .fontColor(this.isHistory ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
        Text(`(${this.historyBooks?.length || 0})`)
          .fontSize(15)
          .fontColor(this.isHistory ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
      }
      .onClick(() => {
        this.isHistory = true;
        this.isDeleteShelf = false
      })
    }
    .alignSelf(ItemAlign.Start)
    .width(Constants.FULL_SIZE)
    .padding({
      left: 12,
      right: 16,
      top: 24,
      bottom: 10,
    })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Column() {
          NavHeaderBar({
            title: $r('app.string.book_shelf'),
            hasBackButton: true,
            hasBgColor: false,
            isMainPage: true,
          })

          Column() {
            this.readingInfo();
            this.shelfHeader();
            if (this.isHistory) {
              this.bookShelfGrid(this.historyBooks, this.isHistory);
            } else {
              this.bookShelfGrid(this.favBooks, this.isHistory);
            }
          }
          .alignItems(HorizontalAlign.Start)
          .width(Constants.FULL_SIZE)
          .padding({
            left: 12,
            right: 12,
          })
        }

        if (this.isDeleteShelf) {
          DeleteBottomCard({
            delete: () => {
              let bookType = this.isHistory ? 'historyBooks' : 'favBooks';
              if (bookType === 'historyBooks') {
                this.deleteBookList(bookType, this.historyBooks)
              }else{
                this.deleteBookList(bookType, this.favBooks)
              }
            }
          });
        }
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.background_secondary'))
    }.hideTitleBar(true)
  }
}