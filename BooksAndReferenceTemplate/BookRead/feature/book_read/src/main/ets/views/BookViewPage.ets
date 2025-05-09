import { ReaderController } from '../controller/ReaderController';
import { ReaderView } from './ReaderView';
import { emitter } from '@kit.BasicServicesKit';
import { BookApi, BookInfo, Constants, EpubUtils, TCRouter } from 'common';
import { JSON } from '@kit.ArkTS';

@ComponentV2
export struct BookViewPage {
  @Local book: BookInfo | undefined = undefined
  @Local readController: ReaderController | undefined = undefined;
  @Local loadFlag: boolean = false;
  @Local viewColor: Resource = $r('app.color.reader_view_background_0');

  async aboutToAppear(): Promise<void> {
    const p = TCRouter.getParams<BookInfo>(Constants.READ_ROUTER);
    if (p) {
      await this.loadBook(p);
    }
    if(AppStorage.has('colorSelectedIndex')){
      let colorSelectedIndex = AppStorage.get<number>('colorSelectedIndex')
      this.viewColor = $r(`app.color.reader_view_background_${colorSelectedIndex}`)
    }
    // 订阅颜色修改事件
    emitter.on(Constants.VIEW_COLOR_CHANGE, (eventData: emitter.EventData) => {
      // 监听到点击事件，关闭目录栏
      if (eventData.data) {
        this.viewColor = eventData.data.color;
      }
    })
  }

  async loadBook(p: BookInfo) {
    this.book = p;
    this.book.localPath =
      await EpubUtils.loadEpubFileFromNetwork(this.book.id,
        this.book.epubUrl, getContext(this).cacheDir)
    this.readController = new ReaderController(this.book);
    this.readController.loadAllChapter();
    this.loadFlag = true;
    const hisRsp = await BookApi.getBooksShelfList('historyBooks', Constants.API_GET_BOOK_HISTORY_PATH,'');
    let books = hisRsp.books;
    let index = books.findIndex(book => book.id === p.id)
    if( index !== -1 ){
      books.splice(index,1);
    }
    books.unshift(p);
    AppStorage.set('historyBooks',books);
  }

  build() {
    NavDestination() {
      Column() {
        if (this.loadFlag) {
          ReaderView({ readController: this.readController });
        }
      }
    }
    .hideTitleBar(true)
    .backgroundColor(this.viewColor)
    .height('100%')
    .width('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}