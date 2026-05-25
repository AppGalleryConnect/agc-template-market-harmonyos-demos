import {
  BookApi,
  BookInfo,
  BookLittleCard,
  BookGroupCard,
  BookLikeCard,
  Constants,
  GroupBook,
  MathUtil,
  NavHeaderBar,
  TCRouter,
  GroupListCard,
  dialogView,
  DialogParams,
  DialogUtil,
  bookShelfCard,
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  EpubUtils,
  AppLinkingRouter,
  GetBookApiRsp,
  FontModel
} from 'common';
import { DeleteBottomCard } from '../comps/DeleteBottomCard';
import { UserInfo, fp2pxUtil } from 'base_common';
import { HashMap } from '@kit.ArkTS';
import { ShareBookCard } from 'book_read_kit'
import { AppStorageV2, PromptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
export function BookShelfPageBuilder() {
  BookShelfPage();
}

@ComponentV2
export struct BookShelfPage {
  @Local favBooks: GroupBook[] = [];
  @Local likeBooks: BookInfo[] = [];
  @Local myMap: HashMap<string, Array<BookInfo>> = new HashMap<string, Array<BookInfo>>();
  @Local historyBooks: BookInfo[] = [];
  @Local isEdit: boolean | undefined = false;
  @Consumer('isHistory') isHistory: boolean = false;
  @Local test: string[] = [];
  @Consumer('isDeleteShelf') isDeleteShelf: boolean = false;
  @Local isShowManage: boolean = false;
  @Local isNewGroup: boolean = false;
  @Local isGroupManage: boolean = false;
  @Local isShowBind: boolean = false;
  @Local selectGroup: boolean = false;
  @Local deleteBooks: Set<string> = new Set();
  @Local deleteBooksGroup: Set<string> = new Set();
  @Consumer('userInfo') userInfo: UserInfo | undefined = undefined;
  @Param currentNumber: number = 0;
  @Consumer('tabController') tabsController: TabsController = new TabsController();
  @Consumer('currentIndexTab') currentIndexTab: number = 0;
  @Provider('isGrid') isGrid: boolean = true;
  @Local bookManage: GroupBook = new GroupBook();
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  scroller: Scroller = new Scroller()
  @Local wBuilder: WrappedBuilder<[DialogParams]> = wrapBuilder(dialogView);
  @Local changeItem: DialogParams = new DialogParams('新建分组', '', true, '取消', '确认', () => {
  }, () => {
  })
  @Local signIn: number = AppStorage.get('signIn') || 0;
  @Local appLinkRouter: AppLinkingRouter = AppStorageV2.connect(AppLinkingRouter, () => new AppLinkingRouter())!;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Local bookIndex: number = 0
  @Local moveToGroupName: string = ''

  // 删除弹窗
  deleteDialog() {
    DialogUtil.openDialog(this.wBuilder, new DialogParams(
      '是否删除此书籍？', '书籍将在同账号其他设备的书架同步删除。', false, '取消', '确认',
      () => {
        DialogUtil.close()
      },
      () => {
        this.deleteBooksGroup.add(this.bookManage?.bookName as string);
        this.deleteBookListGroup('favBooks', this.favBooks)
        DialogUtil.close()
      }))
  };

  // 新建分组弹窗
  changeDialog() {
    DialogUtil.openDialog(this.wBuilder, new DialogParams(
      this.changeItem.title, this.changeItem.content, this.changeItem.input, this.changeItem.leftButtonText,
      this.changeItem.rightButtonText,
      () => { // 取消
        DialogUtil.close()
      },
      (text?: string) => { // 分组
        if (text !== '') {
          let groupBook: GroupBook = new GroupBook()
          groupBook.isSelect = false;
          groupBook.groupName = text
          if (this.isDuplicate(text as string)) {
            this.favBooks.unshift(groupBook)
            AppStorage.set('favBooks', this.favBooks)
          } else {
            this.getUIContext().getPromptAction().showToast({ message: '名字不能重复' })
          }
          DialogUtil.close()
        } else {
          this.getUIContext().getPromptAction().showToast({ message: '输入不能为空' })
        }
      }
    ))
  };

  isDuplicate(text: string): boolean {
    for (let i = 0; i < this.favBooks.length; i++) {
      if (this.favBooks[i].groupName === text) {
        return false
      }
    }
    return true
  }

  @Monitor('appLinkRouter.id')
  onAppLinkingClick() {
    this.checkAppLinkingScene();
  }

  async checkAppLinkingScene() {
    if (this.appLinkRouter.id && this.appLinkRouter.bookId) {
      let bookInfo: BookInfo | null = null;
      const rsp: GetBookApiRsp = await BookApi.getBookList();
      const books = rsp.books;
      for (let index = 0; index < books.length; index++) {
        if (books[index].id === this.appLinkRouter.bookId) {
          bookInfo = books[index];
          break;
        }
      }
      TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, bookInfo);
      this.appLinkRouter.id = 0;
    }
  }

  async aboutToAppear(): Promise<void> {
    this.isDeleteShelf = false
    this.refreshData()
    this.checkAppLinkingScene();
  }

  async refreshData() {
    const favRsp = await BookApi.getBooksShelfGroup('favBooks', Constants.API_GET_BOOK_FAVOURITE_PATH, '');
    const likeRsp = await BookApi.getBooksShelfList('likeBooks', Constants.API_GET_BOOK_LIKE_PATH, '');
    const userRsp = await BookApi.getUserInfo('');
    this.favBooks = favRsp.books;
    this.likeBooks = likeRsp.books;
    this.userInfo = userRsp.user;
    this.signIn = AppStorage.get('signIn') || 0;
    //添加今日阅读和听书时间的刷新
  }

  clearSelect() {
    this.favBooks.forEach((item: GroupBook) => {
      item.isSelect = false;
    })
  }

  deleteBookListGroup(bookType: string, bookListGroup: GroupBook[]) {
    let tmp: GroupBook[] = [];
    for (let i = 0; i < bookListGroup.length; i++) {
      if (!this.deleteBooksGroup.has(bookListGroup[i].bookName as string) &&
        !this.deleteBooksGroup.has(bookListGroup[i].groupName as string)) {
        tmp.push(bookListGroup[i]);
      } else {
        if (bookListGroup[i].bookName) {
          bookListGroup[i].singleBook!.isDownload = false
          EpubUtils.clearEpubFile(bookListGroup[i].singleBook!,
            (this.getUIContext().getHostContext() as Context).filesDir, 'files')
        } else {
          bookListGroup[i].groupBooks?.forEach((book: BookInfo) => {
            book.isDownload = false
            EpubUtils.clearEpubFile(book, (this.getUIContext().getHostContext() as Context).filesDir, 'files')
          })
        }
      }
    }

    bookListGroup.length = tmp.length;
    for (let i = 0; i < tmp.length; i++) {
      bookListGroup[i] = tmp[i];
    }

    AppStorage.set(bookType, tmp);
    this.deleteBooksGroup = new Set();
  }

  // 该分组加入当前书籍 name为当前选择的组名
  addGroupList(name: string) {
    for (let i = 0; i < this.favBooks.length; i++) {
      if (this.favBooks[i].groupName === name) {
        this.favBooks[i].isSelect = false;
        for (let j = 0; j < this.favBooks.length; j++) {
          if (this.favBooks[j].isSelect && this.favBooks[j].singleBook &&
            !this.favBooks[i].groupBooks?.some(book => book.id === this.favBooks[j].singleBook?.id)) {
            this.favBooks[i].groupBooks?.push(this.favBooks[j].singleBook as BookInfo)
          }
        }
        break;
      }
    }
    MathUtil.sortFav(this.favBooks)
    // 修改组数据 删除掉
    for (let i = 0; i < this.favBooks.length; i++) {
      if (this.favBooks[i].isSelect && this.favBooks[i].singleBook) {
        this.favBooks.splice(i, 1);
        i--;
      }
    }
    AppStorage.set('favBooks', this.favBooks)
  }

  @Builder
  readingInfo() {
    Column({ space: 8 }) {
      Row({ space: 5 }) {
        Image($r('app.media.icon_read'))
          .height(16)
          .width(16)
        Text($r('app.string.today_read'))
          .fontSize(this.fontModel.getFg(12))
          .fontColor($r('app.color.90per_000000'))
          .margin({ left: 3 })
        Text(`${this.userInfo ? this.userInfo.totalReading : 0}`)
          .fontSize(this.fontModel.getFg(12))
          .fontColor($r('app.color.free_color'))
        Text($r('app.string.minute'))
          .fontSize(this.fontModel.getFg(12))
          .fontColor($r('app.color.90per_000000'))
      }
      .alignSelf(ItemAlign.Start)

      Row({ space: 5 }) {
        Image($r('app.media.icon_listen'))
          .height(16)
          .width(16)
        Text($r('app.string.today_listen'))
          .fontSize(this.fontModel.getFg(12))
          .fontColor($r('app.color.90per_000000'))
          .margin({ left: 3 })
        Text(`${this.userInfo ? this.userInfo.totalListening : 0}`)
          .fontSize(this.fontModel.getFg(12))
          .fontColor($r('app.color.free_color'))
        Text($r('app.string.minute'))
          .fontSize(this.fontModel.getFg(12))
          .fontColor($r('app.color.90per_000000'))
      }
      .alignSelf(ItemAlign.Start)
    }
    .width(Constants.ABOUT_HALF_SIZE)
    .height(64)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .backgroundImage($r('app.media.reading_info_bg'))
    .backgroundImageSize({ width: '100%', height: '100%' })
    .borderRadius(16)
    .padding({
      left: 12
    })
    .margin({
      top: 30
    })
  }

  @Builder
  signInfo() {
    Column({ space: 4 }) {
      Row({ space: 5 }) {
        Text($r('app.string.checked_in'))
          .fontSize(this.fontModel.getFg(12))
          .fontColor($r('app.color.90per_000000'))
        Text(this.signIn.toString())
          .fontSize(this.fontModel.getFg(12))
          .fontColor('#ED6F21')
        Text($r('app.string.day'))
          .fontSize(this.fontModel.getFg(12))
          .fontColor($r('app.color.90per_000000'))
      }
      .alignSelf(ItemAlign.Start)

      Row() {
        Text() {
          Span($r('app.string.go_earn_more_coins'))
            .fontSize(this.fontModel.getFg(10))
          SymbolSpan($r('sys.symbol.chevron_right'))
            .fontSize(this.fontModel.getFg(12))
        }
        .lineHeight(13)
        .fontColor('#ED6F21')
      }
      .alignSelf(ItemAlign.Start)
    }
    .onClick(() => {
      TCRouter.pushByLogin(Constants.WELFARE_CENTER);
    })
    .width(Constants.ABOUT_HALF_SIZE)
    .height(64)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .backgroundImage($r('app.media.sign_info_bg'))
    .backgroundImageSize({ width: '100%', height: '100%' })
    .borderRadius(16)
    .padding({
      left: 12
    })
    .margin({
      top: 30
    })
  }

  findIndex(name: string, isGroup: boolean): number {
    for (let i = 0; i < this.favBooks.length; i++) {
      if ((this.favBooks[i].groupName === name && isGroup) || (this.favBooks[i].bookName === name && !isGroup)) {
        return i;
      }
    }
    return -1;
  }

  manageEvent(book: BookInfo, isShowM: boolean) {
    this.isShowManage = isShowM;
    this.isShowBind = isShowM;
    this.isNewGroup = false;
    this.bookManage.isSelect = true;
    this.bookManage.groupName = book.groupName;
    this.bookManage.iconString = '';
    this.bookManage.bookName = book.name;
    this.bookManage.singleBook = book;
    this.bookIndex = this.findIndex(book.name, false)
    this.favBooks[this.bookIndex].isSelect = true;
    this.isGroupManage = false;
  }

  manageGroupEvent(books: GroupBook, isShowM: boolean) {
    this.isShowManage = isShowM;
    this.isShowBind = isShowM;
    this.isNewGroup = false;
    this.bookManage.isSelect = true;
    this.bookManage.groupName = books.groupName;
    this.bookManage.iconString = '';
    this.bookManage.groupBooks = books.groupBooks;
    this.isGroupManage = true;
    this.bookIndex = this.findIndex(books.groupName!, true)
  }

  // 宫格模式
  @Builder
  bookShelfGrid() {
    Column() {
      Grid(this.scroller) {
        ForEach(this.favBooks, (info: GroupBook) => {
          GridItem() {
            Stack({ alignContent: Alignment.BottomEnd }) {
              if (info.groupName === '' || info.groupName === undefined) {
                BookLittleCard({
                  info: info.singleBook,
                  isDownload: info.isDownload,
                  downloading: info.downloading,
                  isPin: info.isPin,
                  downloadProgress: info.singleBook?.downloadProgress,
                  manageEvent: (book: BookInfo, isShowM: boolean) => {
                    this.manageEvent(book, isShowM)
                  }
                })
                  .gesture(GestureGroup(GestureMode.Parallel, LongPressGesture()
                    .onAction((event: GestureEvent) => {
                      // 针对书架列表
                      this.manageEvent(info.singleBook!, true)
                    })
                  ))
              } else {
                BookGroupCard({ info: info, isPin: info.isPin })
                  .gesture(GestureGroup(GestureMode.Parallel, LongPressGesture()
                    .onAction((event: GestureEvent) => {
                      // 针对书本分组
                      this.manageGroupEvent(info, true)
                    })
                  ))
                  .onClick(() => {
                    TCRouter.push(Constants.GROUP_ROUTE, { group: info, groups: this.favBooks })
                  })
              }

              if (this.isDeleteShelf) {
                Checkbox({ name: 'delete', group: 'deleteGroup' })
                  .selectedColor($r('app.color.slider_selected_color'))
                  .unselectedColor($r('sys.color.icon_tertiary'))
                  .select(info.isSelect)
                  .shape(CheckBoxShape.CIRCLE)
                  .onChange((value: boolean) => {
                    if (value) {
                      this.deleteBooksGroup.add(info.singleBook?.name || info.groupName!);
                      info.isSelect = true;
                    } else {
                      this.deleteBooksGroup.delete(info.singleBook?.name || info.groupName!);
                      info.isSelect = false;
                    }
                  })
                  .margin({ bottom: 42, right: 6 })
              }
            }
          }
          .width(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 113 : 164)
        }, (item: GroupBook, index: number) => {
          return MathUtil.generateRandomNumber(16).toString();
        })

        if (!this.isDeleteShelf) {
          GridItem() {
            Column() {
              Image($r('app.media.ic_public_plus'))
                .height(40)
                .width(40)
              Text($r('app.string.go_and_go_home'))
                .width(104)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize(this.fontModel.getFg(14))
                .textAlign(TextAlign.Center)
                .padding({ top: 8 })
            }
          }
          .borderRadius(10)
          .width(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 104 : 164)
          .height(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 144 : 214)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .onClick(() => {
            this.currentIndexTab = 1;
            this.tabsController.changeIndex(1)
          })
        }
      }
      .scrollBar(BarState.Off)
      .enableScrollInteraction(true)
      .columnsGap(5)
      .rowsGap(8)
      .edgeEffect(EdgeEffect.Spring)
      .width(Constants.FULL_SIZE)
    }
    .padding({ bottom: 15 })
  }

  //管理书籍
  @Builder
  manageBook() {
    if (this.isNewGroup) {
      this.newGroup();
    } else {
      Column() {
        if (!this.isGroupManage) {
          Row() {
            Row() {
              Image(typeof this.bookManage.singleBook!.coverUrl === 'string' ?
                $r(this.bookManage.singleBook!.coverUrl) :
                this.bookManage.singleBook!.coverUrl)
                .height(120)
                .width(90)
                .objectFit(ImageFit.Cover)
                .borderRadius(10)
              Column() {
                Text(this.bookManage?.bookName)
                  .fontSize(this.fontModel.getFg(14))
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Medium)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
                  .width(104)
                  .textAlign(TextAlign.Start)
                  .padding({ top: 5 })
                Row() {
                  Row() {
                    Text(this.bookManage?.singleBook?.rate)
                      .fontSize(this.fontModel.getFg(12))
                      .fontColor($r('sys.color.font_secondary'))
                    Text(this.bookManage?.singleBook?.category)
                      .fontSize(this.fontModel.getFg(12))
                      .fontColor($r('sys.color.font_secondary'))
                  }
                }.padding({ top: 10 })
              }
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 16, right: 12 })
            }.alignItems(VerticalAlign.Top)

            Row() {
              Button('阅读')
                .width(60)
                .height(25)
                .backgroundColor($r('sys.color.multi_color_08'))
                .margin({ right: 10 })
                .onClick(() => {
                  TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, this.bookManage.singleBook);
                  this.isShowBind = false;
                })
            }.alignItems(VerticalAlign.Bottom)
            .justifyContent(FlexAlign.End)
            .height('100%')

          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%').height(120).margin({ right: 10 })
        }

        Row() {
          Column({ space: 5 }) {
            SymbolGlyph(this.favBooks[this.bookIndex].isPin ? $r('sys.symbol.arrowshape_up_to_line_slash') :
              $r('sys.symbol.arrowshape_up_to_line'))
              .fontSize(fp2pxUtil(24))
              .fontColor([$r('sys.color.icon_primary')])
              .margin({ top: 5 })
            Row() {
              Text(this.favBooks[this.bookIndex].isPin ? $r('app.string.not_pin') : $r('app.string.pin'))
                .fontColor($r('sys.color.font_primary'))
                .fontSize(this.fontModel.getFg(12))
                .fontWeight(FontWeight.Regular)
            }
          }
          .onClick(() => {
            this.isShowBind = !this.isShowBind;
            this.favBooks[this.bookIndex].isPin = !this.favBooks[this.bookIndex].isPin;
            this.favBooks[this.bookIndex].timestamp = Date.now();
            if (this.favBooks[this.bookIndex].isPin) {
              let tmp = this.favBooks[this.bookIndex];
              this.favBooks.splice(this.bookIndex, 1);
              this.favBooks.unshift(tmp);
            } else {
              let tmp = this.favBooks[this.bookIndex];
              this.favBooks.splice(this.bookIndex, 1);
              this.favBooks.push(tmp);
            }
            MathUtil.sortFav(this.favBooks);
            this.clearSelect();
          })
          .height(70)

          if (this.isGroupManage) {
            Column({ space: 5 }) {
              SymbolGlyph($r('sys.symbol.highlighter_line'))
                .fontSize(fp2pxUtil(24))
                .margin({ top: 5 })
              Row() {
                Text($r('app.string.rename'))
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize(this.fontModel.getFg(12))
                  .fontWeight(FontWeight.Regular)
              }
            }
            .onClick(() => {
              this.renameDialog();
              this.clearSelect();
            })
            .height(70)

            Column({ space: 5 }) {
              SymbolGlyph($r('sys.symbol.folder_badge_ellipsis'))
                .fontSize(fp2pxUtil(24))
                .margin({ top: 5 })
              Row() {
                Text($r('app.string.disband_group'))
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize(this.fontModel.getFg(12))
                  .fontWeight(FontWeight.Regular)
              }
            }
            .onClick(() => {
              this.disbandGroupDialog(false);
            })
            .height(70)
          } else {
            Column({ space: 5 }) {
              SymbolGlyph($r('sys.symbol.download'))
                .fontSize(fp2pxUtil(24))
                .fontColor([$r('sys.color.icon_primary')])
                .margin({ top: 5 })
              Row() {
                Text($r('app.string.download'))
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize(this.fontModel.getFg(12))
                  .fontWeight(FontWeight.Regular)
              }
            }
            .onClick(async () => {
              this.isShowBind = !this.isShowBind;
              let index = this.findIndex(this.bookManage.bookName!, false)
              this.favBooks[index].downloading = true;
              this.favBooks[index].singleBook!.localPath =
                await EpubUtils.loadEpubFileFromNetwork(this.favBooks[index].singleBook!,
                  (this.getUIContext().getHostContext() as Context).filesDir);
              this.favBooks[index].isDownload = true;
              this.favBooks[index].downloading = false;
              this.clearSelect();
            })
            .height(70)

            Column() {
              ShareBookCard({ book: this.bookManage?.singleBook, isShelf: true })
            }
            .height(70)

            Column({ space: 5 }) {
              Image($r('app.media.ic_public_folder'))
                .height(24)
                .width(24)
                .margin({ top: 5 })
              Row() {
                Text($r('app.string.change_group'))
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize(this.fontModel.getFg(12))
                  .fontWeight(FontWeight.Regular)
              }
            }
            .onClick(() => {
              this.isShowManage = false;
              this.isNewGroup = true;
              this.isShowBind = true;
            })
            .height(70)
          }

          Column({ space: 5 }) {
            Image($r('app.media.ic_delete_book'))
              .width(24)
              .height(24)
              .margin({ top: 5 })
            Row() {
              Text(this.isGroupManage ? $r('app.string.delete_group') : $r('app.string.delete'))
                .fontSize(this.fontModel.getFg(12))
                .fontColor($r('sys.color.multi_color_08'))
                .fontWeight(FontWeight.Regular)
            }
          }.onClick(() => {
            this.isShowBind = false;
            if (this.isGroupManage) {
              this.disbandGroupDialog(true);
            } else {
              this.deleteDialog()
            }
          })
          .height(70)

        }.height(70)
        .width('100%')
        .padding({ top: 37 })
        .justifyContent(FlexAlign.SpaceEvenly)

        Column() {
          Row() {
            Text($r('app.string.book_like'))
              .fontSize(this.fontModel.getFg(14))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
            Row() {
              Text($r('app.string.go_book_shop'))
                .fontSize(this.fontModel.getFg(12))
                .fontColor($r('sys.color.font_secondary'))
              Image($r('app.media.arrow_right'))
                .height(16)
                .width(16).padding({ left: '6vp' })
            }.justifyContent(FlexAlign.SpaceBetween).padding({ right: '12vp' })
            .onClick(() => {
              this.clearSelect();
              this.isShowManage = false;
              this.isNewGroup = false;
              this.isShowBind = false;
              this.currentIndexTab = 1;
            })
          }.justifyContent(FlexAlign.SpaceBetween).width('100%')
          .padding({ left: 10, top: 10 })

          Grid(this.scroller) {
            ForEach(this.likeBooks, (info: BookInfo) => {
              GridItem() {
                Stack() {
                  BookLikeCard({
                    info: info, showEvent: (isShow: boolean) => {
                      this.isShowManage = isShow
                      this.isShowBind = isShow
                    }
                  })
                }
              }
              .width(113)
              .height(170)
              .padding({ left: 5, right: 5, top: 1 })
            }, (item: BookInfo, index: number) => {
              return MathUtil.generateRandomNumber(16).toString();
            })
          }
          .scrollBar(BarState.Off)
          .enableScrollInteraction(true)
          .maxCount(3)
          .rowsGap(10)
          .columnsGap(10)
          .edgeEffect(EdgeEffect.Spring)
          .columnsTemplate('1fr 1fr 1fr')
          .width(Constants.FULL_SIZE)
          .margin({ top: 1, bottom: 10 })
        }
        .margin({ top: 22 })
        .borderRadius(10)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .width('100%')
        .height(220)
        .alignItems(HorizontalAlign.Start)
      }.alignItems(HorizontalAlign.Start)
      .height('95%').width('100%')
      .padding({ left: 12, right: 12 })
    }
  }

  // 重命名弹窗
  renameDialog() {
    DialogUtil.openDialog(this.wBuilder, new DialogParams(
      '修改组名', '', true, '取消', '确认',
      () => { // 取消
        DialogUtil.close()
      },
      (text?: string) => { // 分组
        let index = this.findIndex(this.bookManage.groupName!, true)
        this.bookManage.groupName = text;
        this.favBooks[index].groupName = text;
        DialogUtil.close()
      }))
  };

  // 解散弹窗
  disbandGroupDialog(isDelete: boolean) {
    DialogUtil.openDialog(this.wBuilder, new DialogParams(
      isDelete ? '是否删除此分组' : '是否解散此分组',
      isDelete ? '删除分组后，组内书籍会被删除，将自动移出书架。' : '解散分组后，组内书籍不会被删除，将自动移入书架。', false,
      '取消', '确认',
      () => {
        DialogUtil.close()
      },
      () => {
        let num = 0;
        this.favBooks.forEach((item: GroupBook) => {
          if (item.groupName === this.bookManage?.groupName) {
            num = this.favBooks.indexOf(item);
          }
        })
        console.info(`长度${this.favBooks[num].groupBooks!.length}`)
        if (!isDelete) {
          this.favBooks[num].groupBooks!.forEach((item: BookInfo) => {
            let groupBook: GroupBook = new GroupBook()
            groupBook.bookName = item.name
            groupBook.isSelect = false;
            groupBook.groupName = ''
            groupBook.singleBook = item
            this.favBooks.push(groupBook)
          })
        }
        this.favBooks.splice(num, 1)
        DialogUtil.close()
        this.isShowManage = false;
        this.isShowBind = false;
        this.isGroupManage = false;
      }))
  };

  @Builder
  newGroup() {
    Column() {
      Column() {
        Row() {
          Row() {
            SymbolGlyph($r('sys.symbol.plus'))
              .fontSize(this.fontModel.getFg(12))
              .fontColor([$r('sys.color.multi_color_08')])
              .padding({ right: 6 })
            Text($r('app.string.new_group'))
              .fontSize(this.fontModel.getFg(12))
              .fontColor($r('sys.color.multi_color_08'))
              .fontWeight(FontWeight.Regular)
          }
          .justifyContent(FlexAlign.SpaceBetween).padding({ right: '12vp' })
          .onClick(() => {
            this.changeDialog()
          })
        }.width('100%').justifyContent(FlexAlign.End).margin({ top: 16 })

        Scroll() {
          Column() {
            ForEach(this.favBooks, (item: GroupBook, index: number) => {
              if (item.groupName !== '') {
                Row() {
                  Row() {
                    Radio({ value: item.groupName, group: 'radioGroup' })
                      .height(20)
                      .width(20)
                      .radioStyle({
                        checkedBackgroundColor: $r('app.color.font_overdue')
                      })
                      .margin({ left: 14 })
                      .onChange((isChecked: boolean) => {
                        if (isChecked) {
                          this.moveToGroupName = item.groupName!
                        }
                      })
                    Text(item.groupName)
                      .fontSize(this.fontModel.getFg(16))
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .margin({ left: 10 })
                  }
                  .height('100%')

                  if (item.groupBooks?.length) {
                    Text('共' + item.groupBooks?.length + '本')
                      .fontSize(this.fontModel.getFg(12))
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))
                      .height('100%')
                  } else {
                    Text('共' + 0 + '本')
                      .fontSize(this.fontModel.getFg(12))
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.comp_background_list_card'))
                      .height('100%')
                  }
                }
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(VerticalAlign.Top)
                .width('100%')
                .height(48)
                .margin({ top: 12 })
                .padding({ right: 16 })
                .backgroundColor($r('sys.color.comp_background_list_card'))
                .borderRadius(10)
              }
            }, (item: GroupBook) => item.timestamp.toString())
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .margin({ top: 16 })
        }
        .edgeEffect(EdgeEffect.Spring)
      }

      Button('确定')
        .width(304)
        .height(40)
        .borderRadius(20)
        .backgroundColor($r('sys.color.multi_color_08'))
        .onClick(() => {
          if (this.moveToGroupName) {
            this.addGroupList(this.moveToGroupName as string)
          }
          for (let index = 0; index < this.favBooks.length; index++) {
            if (!this.favBooks[index].singleBook && !this.favBooks[index].groupBooks?.length) {
              this.favBooks.splice(index, 1);
              index--;
            }
          }
          AppStorage.set('favBooks', this.favBooks)
          this.isShowBind = false;
          this.deleteBooksGroup = new Set();
          this.clearSelect();
        })
    }
    .height('90%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 12, right: 12 })
  }

  // 列表模式
  @Builder
  bookShelfList() {
    Scroll(this.scroller) {
      Column({ space: 8 }) {
        ForEach(this.favBooks, (info: GroupBook) => {
          Stack({ alignContent: Alignment.Start }) {
            if (info.groupName === '') {
              bookShelfCard({
                info: info.singleBook, isPin: info.isPin, manageEvent: (book: BookInfo, isShowM: boolean) => {
                  this.manageEvent(book, isShowM)
                }
              })
                .margin({ left: this.isDeleteShelf ? 36 : 0 })
                .width(this.isDeleteShelf ? `calc('100%' - 36vp)` : '100%')
                .gesture(GestureGroup(GestureMode.Parallel, LongPressGesture()
                  .onAction((event: GestureEvent) => {
                    // 针对书架列表
                    this.manageEvent(info.singleBook!, true)
                  })
                ))
                .onClick(() => {
                  if (this.isDeleteShelf) {
                    const newValue = !info.isSelect;
                    if (newValue) {
                      this.deleteBooksGroup.add(info.singleBook?.name as string);
                    } else {
                      this.deleteBooksGroup.delete(info.singleBook?.name as string);
                    }
                    info.isSelect = newValue;
                  } else {
                    TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, info.singleBook);
                  }
                })
            } else {
              GroupListCard({ info: info, isPin: info.isPin })
                .margin({ left: this.isDeleteShelf ? 36 : 0 })
                .onClick(() => {
                  TCRouter.push(Constants.GROUP_ROUTE, { group: info, groups: this.favBooks })
                })
            }
            if (this.isDeleteShelf) {
              Checkbox({ name: 'delete', group: 'deleteGroup' })
                .select(info.isSelect)
                .unselectedColor($r('sys.color.icon_tertiary'))
                .selectedColor($r('app.color.slider_selected_color'))
                .shape(CheckBoxShape.CIRCLE)
                .onChange((value: boolean) => {
                  if (value) {
                    this.deleteBooksGroup.add(info.singleBook?.name as string);
                    info.isSelect = true;
                  } else {
                    this.deleteBooksGroup.delete(info.singleBook?.name as string);
                    info.isSelect = false;
                  }
                })
                .margin({ left: 12 })
            }
          }
          .width(Constants.FULL_SIZE)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .borderRadius(16)
        }, (item: GroupBook) => item.singleBook?.id + '_' + item.singleBook?.name)

        if (!this.isDeleteShelf) {
          Column() {
            Column() {
              Image($r('app.media.ic_public_plus'))
                .width(40)
                .height(40)
              Text($r('app.string.go_and_go_home'))
                .width(104)
                .fontSize(this.fontModel.getFg(14))
                .fontColor($r('sys.color.font_secondary'))
                .textAlign(TextAlign.Center)
                .padding({ top: 8 })
            }
            .justifyContent(FlexAlign.Center)
            .borderRadius(10)
            .width(68)
            .height(90)
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .margin({ top: 10 })
            .onClick(() => {
              this.currentIndexTab = 1;
              this.tabsController.changeIndex(1)
            })
          }
          .width(Constants.FULL_SIZE)
          .alignItems(HorizontalAlign.Start)
        }
      }
      .padding({ top: '20vp' })
      .padding({ bottom: 15 })
      .width(Constants.FULL_SIZE)
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

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column() {
        NavHeaderBar({
          title: !this.isDeleteShelf ? $r('app.string.book_shelf') :
            this.deleteBooksGroup.size === 0 ? '未选择' : `已选择${this.deleteBooksGroup.size}项`,
          hasBackButton: this.isDeleteShelf,
          hasBgColor: false,
          isMainPage: true,
          isShelf: true,
          quit: () => {
            this.isDeleteShelf = false;
            this.deleteBooksGroup = new Set();
            this.clearSelect();
            this.isShowManage = false;
            this.isNewGroup = false;
            this.isShowBind = false;
            this.isGroupManage = false;
          },
          refreshData: async () => {
            this.refreshData()
          }
        })

        Column() {
          if (!this.isDeleteShelf) {
            Row() {
              this.readingInfo();
              this.signInfo();
            }
            .padding({ bottom: 12 })
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }

          Scroll() {
            Column() {
              if (this.isGrid) {
                this.bookShelfGrid();
              } else {
                this.bookShelfList();
              }
            }
          }
          .align(Alignment.Top)
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .width(Constants.FULL_SIZE)
        .padding({
          left: 12,
          right: 12,
        })
      }
      .bindSheet($$this.isShowBind, this.manageBook(), {
        detents: [SheetSize.MEDIUM, SheetSize.LARGE, 800],
        height: this.isShowManage ? SheetSize.FIT_CONTENT : SheetSize.MEDIUM,
        preferType: SheetType.BOTTOM,
        title: {
          title: this.isShowManage ? (this.isGroupManage ? this.bookManage.groupName : $r('app.string.manage_book')) :
            $r('app.string.change_group'),
          subtitle: this.isGroupManage ? `共${this.bookManage.groupBooks?.length}本` : ''
        },
        onWillDismiss: () => {
          for (let index = 0; index < this.favBooks.length; index++) {
            if (!this.favBooks[index].singleBook && !this.favBooks[index].groupBooks?.length) {
              this.favBooks.splice(index, 1);
              index--;
            }
          }
          AppStorage.set('favBooks', this.favBooks)
          this.deleteBooksGroup = new Set();
          this.clearSelect();
          this.isShowManage = false;
          this.isShowBind = false;
        }
      })

      if (this.isDeleteShelf) {
        DeleteBottomCard({
          selectAll: (isSelectAll: boolean) => {
            if (isSelectAll) {
              this.favBooks.forEach((info: GroupBook) => {
                info.isSelect = false
              })
            } else {
              this.favBooks.forEach((info: GroupBook) => {
                info.isSelect = true
              })
            }
          },
          changeGroup: () => {
            if (this.deleteBooksGroup.size < 1) {
              let promptAction: PromptAction = this.getUIContext().getPromptAction();
              try {
                promptAction.showToast({
                  message: '未选择',
                  duration: 2000
                });
              } catch (error) {
                let message = (error as BusinessError).message;
                let code = (error as BusinessError).code;
                console.error(`showToast args error code is ${code}, message is ${message}`);
              }
            } else {
              this.moveToGroupName = '';
              this.isShowManage = false;
              this.isNewGroup = true;
              this.isShowBind = true;
            }
          },
          download: () => {
            this.deleteBooksGroup.forEach(async (bookName: string) => {
              let index = this.findIndex(bookName, false)
              if (index !== -1) {
                this.favBooks[index].downloading = true;
                this.favBooks[index].singleBook!.localPath =
                  await EpubUtils.loadEpubFileFromNetwork(this.favBooks[index].singleBook!,
                    (this.getUIContext().getHostContext() as Context).filesDir);
                this.favBooks[index].isDownload = true;
                this.favBooks[index].downloading = false;
              }
            })
          },
          pin: () => {
            this.deleteBooksGroup.forEach((groupName: string) => {
              let index = this.findIndex(groupName, false)
              if (index === -1) {
                index = this.findIndex(groupName, true)
              }
              this.favBooks[index].isPin = true;
              this.favBooks[index].timestamp = Date.now();
              let tmp = this.favBooks[index];
              this.favBooks.splice(index, 1);
              this.favBooks.unshift(tmp);
            })
            MathUtil.sortFav(this.favBooks);
          },
          delete: () => {
            if (this.deleteBooksGroup.size < 1) {
              let promptAction: PromptAction = this.getUIContext().getPromptAction();
              try {
                promptAction.showToast({
                  message: '未选择',
                  duration: 2000
                });
              } catch (error) {
                let message = (error as BusinessError).message;
                let code = (error as BusinessError).code;
                console.error(`showToast args error code is ${code}, message is ${message}`);
              }
            } else {
              this.getUIContext().getPromptAction().showDialog({
                title: $r('app.string.delete_book_flag'),
                message: $r('app.string.q_delete_book_flag'),
                buttons: [
                  {
                    text: $r('app.string.cancel'),
                    color: $r('app.color.button_color')
                  },
                  {
                    text: $r('app.string.delete'),
                    color: $r('app.color.button_color')
                  }
                ]
              }, (err, data) => {
                if (data.index === 1) {
                  this.deleteBookListGroup('favBooks', this.favBooks)
                  this.getUIContext().getPromptAction().showToast({ message: $r('app.string.delete_book_success') })
                }
              })
            }
          }
        })
          .margin({ bottom: 10 })
      }
    }
    .onVisibleAreaChange([0.0], (isExpanding: boolean, currentRatio: number) => {
      if (isExpanding && currentRatio >= 0.0) {
        this.refreshData()
      }
    })
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}