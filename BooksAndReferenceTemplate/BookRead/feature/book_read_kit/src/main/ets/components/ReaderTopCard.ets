import { BookApi, BookInfo, Constants, EpubUtils, GroupBook, TCRouter } from 'common';
import { ShareBookCard } from './ShareBookCard';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { systemShare } from '@kit.ShareKit';
import { fileUri } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { Logger } from '@hw-agconnect/ui-base';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { UserInfo } from 'base_common';

@ComponentV2
export struct ReaderTopCard {
  @Param @Require book: BookInfo
  @Local isAddSuccess: boolean = false;
  @Local isLogin: boolean = false;
  @Local isDownload: boolean = false;
  @Consumer('nightMode') nightMode: boolean = AppStorage.get<boolean>('bookNightMode') ?? false;
  windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;

  setShareData() {
    const contextFaker: Context = this.getUIContext().getHostContext() as Context;
    let filePath = contextFaker.filesDir + '/book_image_1.png';
    let i = this.book.coverUrl
    let utdTypeId = utd.getUniformDataTypeByFilenameExtension('.png', utd.UniformDataType.IMAGE);

    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utdTypeId,
      uri: fileUri.getUriFromPath(filePath),
      title: 'Picture Title',
      description: 'Picture Description',
    });

    let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    controller.show(context, {
      selectionMode: systemShare.SelectionMode.SINGLE,
      previewMode: systemShare.SharePreviewMode.DETAIL,
    }).then(() => {
      Logger.info('ShareController show success.');
    }).catch((error: BusinessError) => {
      Logger.error(`ShareController show error. code: ${error.code}, message: ${error.message}`);
    });
  }

  async aboutToAppear(): Promise<void> {
    this.isLogin = AppStorage.get<UserInfo>('userInfo') !== undefined;
    const rsp = await BookApi.getBooksShelfGroup('favBooks', Constants.API_GET_BOOK_FAVOURITE_PATH, '');
    let books: GroupBook[] = rsp.books;
    let fIndex = books.findIndex(book => this.book.id === book.singleBook?.id);
    if (fIndex === -1) {
      this.isDownload = this.book.isDownload || false;
    } else {
      this.isDownload = books[fIndex].isDownload || false;
    }
    books.forEach((book) => {
      if (book.groupBooks?.length! > 0) {
        if (book.groupBooks?.some(item => item.id === this.book.id)) {
          this.isAddSuccess = true;
          return;
        }
      } else {
        if (book.singleBook?.id === this.book.id && this.isLogin) {
          this.isAddSuccess = true;
          return;
        }
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
      temp.isDownload = this.book.isDownload
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
      Image(this.nightMode ? $r('app.media.ic_back_dark') : $r('app.media.ic_back_book'))
        .width(35)
        .height(35)
        .onClick(() => {
          TCRouter.pop();
        })


      Row({ space: 8 }) {
        Image(this.isDownload ? $r('app.media.icon_down_gray') : $r('app.media.icon_down'))
          .width(35)
          .height(35)
          .onClick(async () => {
            if (!this.isDownload) {
              this.isDownload = !this.isDownload;
              const favRsp = await BookApi.getBooksShelfGroup('favBooks', Constants.API_GET_BOOK_FAVOURITE_PATH, '');
              let favBooks: GroupBook[] = favRsp.books;
              let fIndex = favBooks.findIndex(book => this.book.id === book.singleBook?.id);
              if (fIndex !== -1) {
                favBooks[fIndex].singleBook!.localPath =
                  await EpubUtils.loadEpubFileFromNetwork(favBooks[fIndex].singleBook!,
                    (this.getUIContext().getHostContext() as Context).filesDir);
                favBooks[fIndex].isDownload = this.isDownload;
                AppStorage.set('favBooks', favBooks);
              } else {
                this.book.localPath = await EpubUtils.loadEpubFileFromNetwork(this.book,
                  (this.getUIContext().getHostContext() as Context).filesDir);
                this.book.isDownload = this.isDownload

                let downloadBooks: GroupBook[] = AppStorage.get('downloadBooks') || [];
                let dbook: GroupBook = new GroupBook()
                dbook.bookName = this.book.name;
                dbook.singleBook = this.book;
                dbook.isDownload = true;
                downloadBooks.push(dbook)
                AppStorage.setOrCreate('downloadBooks', downloadBooks)
              }
            }
          })

        Image(this.isAddSuccess ?
          (this.nightMode ? $r('app.media.ic_add_book_shelf_success_dark') :
            $r('app.media.ic_add_book_shelf_success')) :
          (this.nightMode ? $r('app.media.ic_add_book_shelf_dark') : $r('app.media.ic_add_book_shelf')))
          .width(35)
          .height(35)
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

        ShareBookCard({
          book: this.book,
          shareImage: this.nightMode ? $r('app.media.ic_share_top_card_dark') : $r('app.media.ic_share_top_card')
        })
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(this.nightMode ? $r('app.color.100per_000000') : $r('app.color.100per_f1f3f5'))
    .width(Constants.FULL_SIZE)
    .padding({
      top: this.windowTopHeight + 8,
      left: 18,
      right: 18,
      bottom: 8
    })
  }
}