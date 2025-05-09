import { ReaderController } from '../controller/ReaderController';
import { ReaderSpeechCard } from './ReaderSpeechCard';
import { promptAction } from '@kit.ArkUI';
import { BookApi, BookInfo, Constants, TCRouter, UserInfo } from 'common';

@ComponentV2
export struct ReaderTopCard {
  @Param @Require readController: ReaderController;
  @Local isAddSuccess: boolean = false;
  @Local isLogin: boolean = false;
  windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;

  async aboutToAppear(): Promise<void> {
    this.isLogin = AppStorage.get<UserInfo>('userInfo') !== undefined;
    const rsp = await BookApi.getBooksShelfList('favBooks',Constants.API_GET_BOOK_FAVOURITE_PATH,'');
    let books: BookInfo[] = rsp.books;
    books.forEach((book) => {
      if (book.id === this.readController.getBook().id && this.isLogin) {
        this.isAddSuccess = true;
        return;
      }
    });
  }

  async addBook2Shelf(isAdd: boolean , toast: ResourceStr) {
    const rsp = await BookApi.getBooksShelfList('favBooks',Constants.API_GET_BOOK_FAVOURITE_PATH,'');
    let books: BookInfo[] = rsp.books;
    if(isAdd){
      books.push(this.readController.getBook());
      AppStorage.set('favBooks', books);
      this.isAddSuccess = true;
    }else{
      let index = books.findIndex(book => this.readController.getBook().id === book.id)
      if(index !== -1){
        books.splice(index, 1);
        this.isAddSuccess = false;
      }
      AppStorage.set('historyBooks',books)
    }
    promptAction.showToast({
      message: toast,
      duration: 2000
    });
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .width(35)
          .height(35)
          .onClick(() => {
            TCRouter.pop();
          })
        Image(this.isAddSuccess ? $r('app.media.ic_add_book_shelf_success') : $r('app.media.ic_add_book_shelf'))
          .width(25)
          .height(25)
          .onClick(async () => {
            const userInfo = AppStorage.get<UserInfo>('userInfo');
            if (userInfo === undefined) {
              TCRouter.push(Constants.LOGIN_ROUTE);
            } else if (!this.isAddSuccess) {
              await this.addBook2Shelf(true,$r('app.string.add_shelf_success'));
            }else if(this.isAddSuccess){
            //   再次点击从书架删除
              await this.addBook2Shelf(false,$r('app.string.del_shelf_success'));
            }
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .height(50 + this.windowTopHeight)
      .width(Constants.FULL_SIZE)
      .padding({ top: 20, left: 18, right: 18 })
      .backgroundColor(Color.White)

      ReaderSpeechCard({ readController: this.readController });
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.SpaceBetween)
    .align(Alignment.BottomEnd)
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
  }
}