import { Constants } from '../constant/Constants'
import { TCRouter } from '../comp/TCRouter'
import {
  AppLinkingRouter,
  BookApi,
  BookInfo,
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  DialogParams,
  GetBookApiRsp,
  GroupBook,
  TSearch
} from '../../../../Index';
import { AppStorageV2, LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { fileUri, picker } from '@kit.CoreFileKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { bookParser } from '@kit.ReaderKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import { url } from '@kit.ArkTS';
import { Logger } from '@hw-agconnect/ui-base';
import { UserInfo, fp2pxUtil } from 'base_common';

function getFreeText(isFree?: string): string | null {
  switch (isFree) {
    case '0':
      return '免费';
    case '1':
      return '会员';
    case '2':
      return '付费';
    default:
      return null;
  }
}

function getFreeColor(isFree?: string): string | null {
  switch (isFree) {
    case '0':
      return '#64BB5C';
    case '1':
      return '#F9A01E';
    case '2':
      return '#E84026';
    default:
      return null;
  }
}

@Builder
export function BookCover(image?: PixelMap | ResourceStr | DrawableDescriptor, height: number = 144,
  width: number = 104, isFree?: string) {
  Stack({ alignContent: Alignment.TopEnd }) {
    Image(typeof image === 'string' ? $r(image) : image)
      .height(height)
      .width(width)
      .objectFit(ImageFit.Auto)
      .borderRadius(10)
      .draggable(false)
    Column() {
      Text(getFreeText(isFree))
        .fontSize(10)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .height(16)
        .width(32)
        .backgroundColor(getFreeColor(isFree))
        .borderRadius(10)
    }
    .padding(8)
  }
}

@Builder
export function BookCoverSM(image?: PixelMap | ResourceStr | DrawableDescriptor, isFree?: string) {
  Stack({ alignContent: Alignment.TopEnd }) {
    Image(typeof image === 'string' ? $r(image) : image)
      .height(90)
      .width(68)
      .objectFit(ImageFit.Cover)
      .borderRadius(8)
      .draggable(false)
    Column() {
      Text(getFreeText(isFree))
        .fontSize(10)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .height(16)
        .width(36)
        .backgroundColor(getFreeColor(isFree))
        .borderRadius(14)
    }
    .padding(4)
  }
}


@Builder
export function BookLikeCover(image?: PixelMap | ResourceStr | DrawableDescriptor, isFree?: string) {

  Stack({ alignContent: Alignment.TopEnd }) {
    Image($r(image?.toString()))
      .height(120)
      .width(88)
      .objectFit(ImageFit.Auto)
      .borderRadius(10)
    Column() {
      Text(getFreeText(isFree))
        .fontSize(10)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .height(20)
        .width(35)
        .backgroundColor(getFreeColor(isFree))
        .borderRadius(10)
    }
    .padding(8)
  }
}

@Builder
export function BookGroupCover(image?: PixelMap | ResourceStr | DrawableDescriptor) {

  Stack() {
    Image(typeof image === 'string' ? $r(image) : image)
      .width('100%')
      .height('100%')
      .objectFit(ImageFit.Auto)
      .borderRadius(5)
      .backgroundColor(Color.White)
      .draggable(false)

  }
}


@ComponentV2
export struct ReturnButton {
  build() {
    Image($r('app.media.ic_back'))
      .width(40)
      .height(40)
      .margin({ right: 12 })
      .onClick(() => {
        TCRouter.pop();
      })
  }
}

const TAG = '[CommonUI]';

@ComponentV2
export struct NavHeaderBar {
  @Param title: ResourceStr | string = 'default';
  @Param hasBackButton: boolean = true;
  @Param hasBgColor: boolean = true;
  @Param backImg: ResourceStr = $r('app.media.ic_back');
  @Param hasBackgroundImg: boolean = true;
  @Param isMainPage: boolean = false;
  @Consumer('tabController') tabsController: TabsController = new TabsController();
  @Consumer('currentIndexTab') currentIndexTab: number = 0;
  @Consumer('isHistory') isHistory: boolean = false;
  // 搜索框
  @Param isSearch: boolean = false;
  // 书架页title
  @Param isShelf: boolean = false;
  @Param isRecord: boolean = false;
  windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77
  @Consumer('isGrid') isGrid: boolean = true;
  @Consumer('isDeleteShelf') isDeleteShelf: boolean = false;
  @Consumer('isDeleteRecord') isDeleteRecord: boolean = false;
  @Local isShown: boolean = false;
  @Event quit: () => void = () => {
  }
  @Event refreshData: () => void = () => {
  }
  @Event gridSheet: () => void = () => {
    this.isGrid = true;
    this.isShown = false;
  }
  @Event listSheet: () => void = () => {
    this.isGrid = false;
    this.isShown = false;
  }
  @Event inputBook: () => void = () => {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    // 保存书籍到应用沙箱
    let documentPicker = new picker.DocumentViewPicker(context);
    const documentSelectOptions = new picker.DocumentSelectOptions();
    documentSelectOptions.fileSuffixFilters = ['图书|.epub'];
    documentSelectOptions.maxSelectNumber = 1;
    documentPicker.select(documentSelectOptions).then(async (documentSelectResult: string[]) => {
      const srcPath: string = new fileUri.FileUri(documentSelectResult[0]).path
      let pathDir = (this.getUIContext().getHostContext() as Context).filesDir
      let destPath: string =
        pathDir + Constants.FILE_SPLIT + Date.now() + Constants.EPUB_FILE_SUFFIX;
      let file: fs.File = null!;
      try {
        file = fs.openSync(destPath, fs.OpenMode.CREATE);
        fs.copyFileSync(srcPath, destPath)
      } catch (e) {
      } finally {
        fs.closeSync(file);
      }
      // 解析书籍信息并加入书架
      let defaultHandler = await bookParser.getDefaultHandler(destPath);
      let bookInfo = defaultHandler.getBookInfo();
      if (bookInfo) {
        const favRsp = await BookApi.getBooksShelfGroup('favBooks', Constants.API_GET_BOOK_FAVOURITE_PATH, '');
        let favBooks: GroupBook[] = favRsp.books;
        let temp: GroupBook = new GroupBook()
        let book = new BookInfo()
        temp.isSelect = false;
        temp.groupName = ''
        temp.bookName = bookInfo.bookTitle || '';
        book.id = Date.now().toString()
        book.name = bookInfo.bookTitle || '';
        book.author = bookInfo?.bookCreator || '';
        book.isDownload = true
        book.localPath = destPath
        let buffer = defaultHandler.getResourceContent(-1, bookInfo.bookCoverImage);
        let imageSource: image.ImageSource = image.createImageSource(buffer);
        book.coverUrl = await imageSource.createPixelMap();
        temp.singleBook = book
        favBooks.push(temp);
        AppStorage.set('favBooks', favBooks);
        imageSource.release();
      }
      this.refreshData()
    }).catch((err: BusinessError) => {
      console.error(`Invoke documentViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
    });


  }
  @Event bulkManage: () => void = () => {
    if (this.isDeleteShelf === false) {
      this.isDeleteShelf = true;
    } else {
      this.isDeleteShelf = false;
    }
    this.isShown = false;
  }
  @Event recordManage: () => void = () => {
    if (this.isDeleteRecord === false) {
      this.isDeleteRecord = true;
    } else {
      this.isDeleteRecord = false;
    }
  }
  @Event scan: () => void = () => {
    // 定义扫码参数options
    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL],
      enableMultiMode: true,
      enableAlbum: true
    };
    try {
      // 可调用getHostContext接口获取当前页面关联的Context
      scanBarcode.startScanForResult(this.getUIContext().getHostContext(), options,
        (error: BusinessError, result: scanBarcode.ScanResult) => {
          if (error) {
            console.error('[Scan CPSample]',
              `Failed to get ScanResult by callback with options. Code: ${error.code}, message: ${error.message}`);
            return;
          }
          // 解析码值结果跳转应用服务页
          this.handleAppLinking(result.originalValue)
          console.info('[Scan CPSample]',
            `Succeeded in getting ScanResult by callback with options, result is ${JSON.stringify(result)}`);
        })
    } catch (error) {
      console.error('[Scan CPSample]',
        `Failed to start the scanning service. Code:${error.code}, message: ${error.message}`);
    }
  }
  @Local gridIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.square_grid_2x2'));
  @Local textIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.arrow_right_folder_circle'))
  @Local mngIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.square_and_pencil'))
  @Local scanIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.line_viewfinder'))
  @Local listIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.list_square'));
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @BuilderParam editBuilder?: () => void;

  async handleAppLinking(uri: string) {
    /**
     * 处理扫码中获取传入的链接信息
     * 例如传入的url为：https://linking.xiaobingtang.cn/BookRead?id=1
     */
    if (uri) {
      try {
        const urlObject = url.URL.parseURL(uri);
        const bookId = urlObject.params.get('id');
        if (urlObject.pathname.includes('BookRead') && bookId) {
          let bookinfo: BookInfo | null = null;
          const rsp: GetBookApiRsp = await BookApi.getBookList();
          const books = rsp.books;
          for (let index = 0; index < books.length; index++) {
            if (books[index].id === bookId) {
              bookinfo = books[index];
              break;
            }
          }
          TCRouter.push(Constants.READ_KIT_ROUTER, bookinfo);
        }
        Logger.info(TAG, `Success to handle applinking want. pathname: ${urlObject.pathname}, bookId: ${bookId}`)
      } catch (e) {
        Logger.error(TAG, `Failed to handle applinking want. uri: ${uri}, Code: ${e.code}, message: ${e.message}`);
      }
    }
  }

  @Builder
  selectMenu() {
    Menu() {
      MenuItemGroup({ header: '书架管理' }) {
        MenuItem({
          symbolStartIcon: this.isGrid ? this.gridIconModifier : this.listIconModifier,
          content: this.isGrid ? '宫格模式' : '列表模式',
          builder: this.isGrid ? this.listSheet : this.gridSheet
        })
          .contentFont({ size: fp2pxUtil(16) })
        MenuItem({
          symbolStartIcon: this.textIconModifier,
          content: '导入文本',
          builder: this.inputBook
        })
          .contentFont({ size: fp2pxUtil(16) })
        MenuItem({
          symbolStartIcon: this.mngIconModifier,
          content: '批量管理',
          builder: this.bulkManage
        })
          .contentFont({ size: fp2pxUtil(16) })
        MenuItem({
          symbolStartIcon: this.scanIconModifier,
          content: '扫一扫',
          builder: this.scan
        })
          .contentFont({ size: fp2pxUtil(16) })
      }
    }
    .menuItemDivider({
      strokeWidth: LengthMetrics.px(1),
      color: $r('sys.color.comp_divider'),
      startMargin: LengthMetrics.vp(44),
      endMargin: LengthMetrics.vp(16),
      mode: DividerMode.FLOATING_ABOVE_MENU
    })
    .width(224)
  }

  build() {
    Column() {
      Row() {
        Row() {
          if (this.hasBackButton) {
            Image(this.backImg)
              .width(40)
              .height(40)
              .onClick(() => {
                if (this.isDeleteShelf) {
                  this.quit();
                } else {
                  TCRouter.pop();
                }
              })
              .margin({ right: 12 })
          }
          Text(this.title)
            .fontColor($r('sys.color.font_primary'))
            .fontSize(this.isMainPage ? fp2pxUtil(24) : fp2pxUtil(20))
            .fontWeight(FontWeight.Medium)
        }

        if (this.isSearch) {
          Row() {
            TSearch({ widthLength: '100%' })
              .margin({ left: 24, right: 8 })
              .layoutWeight(1)
            SymbolGlyph($r('sys.symbol.magnifyingglass'))
              .fontSize($r('sys.float.Title_M'))
              .fontColor([$r('sys.color.icon_primary')])
              .margin({ right: 8 })
              .width(40)
              .height(40)
              .borderRadius(1000)
              .padding(8)
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .onClick(() => {
                this.currentIndexTab = 0;
                this.tabsController.changeIndex(0)
                this.isHistory = true
              })
          }
          .layoutWeight(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 1 : 0)
          .width(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 'auto' : '50%')
        }
        if (this.isShelf && !this.isDeleteShelf) {
          Row() {
            SymbolGlyph($r('sys.symbol.magnifyingglass'))
              .fontSize($r('sys.float.Title_M'))
              .fontColor([$r('sys.color.icon_primary')])
              .margin({ right: 8 })
              .width(40)
              .height(40)
              .borderRadius(1000)
              .padding(8)
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .onClick(() => {
                TCRouter.push(Constants.SEARCH_ROUTE);
              })
            SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
              .fontSize($r('sys.float.Title_M'))
              .fontColor([$r('sys.color.icon_primary')])
              .width(40)
              .height(40)
              .borderRadius(1000)
              .padding(8)
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .onClick(() => {
                this.isShown = true
              })
              .bindContextMenu(this.isShown, this.selectMenu(), {
                aboutToDisappear: () => {
                  this.isShown = false
                }
              })

          }
        }
        if (this.editBuilder) {
          Row() {
            this.editBuilder()
          }
        }

        if (this.isRecord) {
          Row() {
            SymbolGlyph(this.isDeleteRecord ? $r('sys.symbol.square_and_pencil_fill') :
              $r('sys.symbol.square_and_pencil'))
              .fontSize(fp2pxUtil(24))
              .fontColor(this.isDeleteRecord ? [$r('sys.color.multi_color_08')] : [$r('sys.color.icon_primary')])
              .width(40)
              .height(40)
              .borderRadius(1000)
              .padding(8)
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .onClick(() => {
                this.recordManage();
              })
          }
        }
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding({
      top: 8 + this.windowTopHeight,
      bottom: 8,
      left: 16,
      right: 16
    })
    .width(Constants.FULL_SIZE)
    .height(56 + this.windowTopHeight)
    .backgroundColor(this.hasBgColor ? $r('sys.color.background_primary') : '#00000000')
  }
}

/*
 * 弹窗
 * */
@Builder
export function dialogView(params: DialogParams) {
  Column() {
    Column() {
      Text(params.title)
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
        .width(263)
        .textAlign(TextAlign.Center)

      if (params.input) {
        TextInput({ text: params.content, placeholder: '请输入分组名称（最多12个文字）' })
          .width('100%')
          .maxLength(12)
          .onChange((value: string) => {
            params.content = value
          })
          .margin({ top: 15, bottom: 8 });
      } else {
        Text(params.content)
          .fontSize(14)
          .width('100%')
          .fontColor($r('sys.color.font_secondary'))
          .textAlign(TextAlign.Center)
          .margin({ top: 27, bottom: 12 })
      }
    }

    Row() {
      Button(params.leftButtonText)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_secondary'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .padding({
          left: 50,
          right: 50,
          top: 12,
          bottom: 12
        })
        .onClick(() => {
          params.leftEvent();
        });
      Button(params.rightButtonText)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('app.color.font_overdue'))
        .padding({
          left: 50,
          right: 50,
          top: 12,
          bottom: 12
        })
        .onClick(() => {
          if (params.input) {
            params.rightEvent(params.content);
          } else {
            params.rightEvent();
          }

        });
    }
    .padding({
      left: 4,
      right: 4
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
  }
  .width(328)
  .padding({
    top: 16,
    bottom: 16,
    right: 12,
    left: 12
  })
  .backgroundColor($r('sys.color.comp_background_tertiary'))
  .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
  .borderRadius(16);
}

@ComponentV2
export struct AddToBookShelf {
  @Param @Require book: BookInfo
  @Local isAddSuccess: boolean = false;
  @Local isLogin: boolean = false;

  async aboutToAppear(): Promise<void> {
    this.isLogin = AppStorage.get<UserInfo>('userInfo') !== undefined;
    const rsp = await BookApi.getBooksShelfGroup('favBooks', Constants.API_GET_BOOK_FAVOURITE_PATH, '');
    let books: GroupBook[] = rsp.books;
    books.forEach((book) => {
      if (book.singleBook?.id === this.book.id && this.isLogin) {
        this.isAddSuccess = true;
        return;
      }
    });
  }

  async addBook2Shelf(isAdd: boolean, toast: ResourceStr) {
    const favRsp = await BookApi.getBooksShelfGroup('favBooks', Constants.API_GET_BOOK_FAVOURITE_PATH, '');
    const hisRsp = await BookApi.getBooksShelfList('favBooks', Constants.API_GET_BOOK_FAVOURITE_PATH, '')
    let favBooks: GroupBook[] = favRsp.books;
    let hisBooks: BookInfo[] = hisRsp.books
    if (isAdd) {
      let temp: GroupBook = new GroupBook()
      temp.isSelect = false;
      temp.groupName = this.book.groupName
      temp.bookName = this.book.name
      temp.singleBook = this.book
      favBooks.push(temp);
      AppStorage.set('favBooks', favBooks);
      this.isAddSuccess = true;
    } else {
      let index = hisBooks.findIndex(book => this.book.id === book.id)
      let fIndex = favBooks.findIndex(book => this.book.id === book.singleBook?.id)
      for (let i = 0; i < favBooks.length; i++) {
        let tmp = favBooks[i].groupBooks?.findIndex(book => this.book.id === book.id) || 0
        if (tmp !== -1) {
          this.isAddSuccess = false;
          favBooks[i].groupBooks?.splice(tmp, 1)
        }
      }
      if (index !== -1) {
        hisBooks.splice(index, 1);
        this.isAddSuccess = false;
      }
      if (fIndex !== -1) {
        favBooks.splice(fIndex, 1);
        this.isAddSuccess = false;
      }
      AppStorage.set('favBooks', favBooks);
      AppStorage.set('historyBooks', hisBooks)
    }
    this.getUIContext().getPromptAction().showToast({
      message: toast,
      duration: 2000
    });
  }

  build() {
    Row() {
      SymbolGlyph($r('sys.symbol.bookshelf_badge_plus'))
        .fontSize(24)
        .opacity(this.isAddSuccess ? 0.4 : 1)
        .enabled(!this.isAddSuccess)
        .onClick(async () => {
          const userInfo = AppStorage.get<UserInfo>('userInfo');
          if (userInfo === undefined) {
            TCRouter.push(Constants.LOGIN_ROUTE);
          } else if (!this.isAddSuccess) {
            await this.addBook2Shelf(true, $r('app.string.add_shelf_success'));
          } else if (this.isAddSuccess) {
            //   再次点击从书架删除
            await this.addBook2Shelf(false, $r('app.string.del_shelf_success'));
          }
        })
    }
  }
}