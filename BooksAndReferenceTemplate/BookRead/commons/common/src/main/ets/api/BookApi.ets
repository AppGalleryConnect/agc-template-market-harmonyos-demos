import { BorrowInfo } from '../model/BorrowInfo';
import { Constants } from '../constant/Constants';
import { TCInvoke } from '../comp/TCInvoke';
import { BookInfo } from '../model/Book';
import { UserInfo } from '../model/UserInfo';
import App from '@system.app';

export interface GetBookApiRsp {
  books: Array<BookInfo>
}

export interface GetBookBorrowRsp {
  borrows: Array<BorrowInfo>
}

export interface GetUserInfoRsp {
  user: UserInfo
}

export interface GetFavBookRsp {
  books: Array<BookInfo>
}

export interface GetBookHistoryRsp {
  books: Array<BookInfo>
}

export class BookApi {
  private static INVOKE: TCInvoke = new TCInvoke();

  public static init(mockFile: string) {
    BookApi.INVOKE.initMock(mockFile);
  }

  public static async getBookList(): Promise<GetBookApiRsp> {
    const rsp: GetBookApiRsp = await BookApi.INVOKE.get<GetBookApiRsp>(Constants.API_GET_BOOK_PATH);
    return rsp;
  }

  public static async getBorrowList(userId: string): Promise<GetBookBorrowRsp> {
    let rsp: GetBookBorrowRsp = await BookApi.INVOKE.get<GetBookBorrowRsp>(Constants.API_GET_BOOK_BORROW_PATH);
    return rsp;
  }

  public static async getUserInfo(userId: string): Promise<GetUserInfoRsp> {
    let userInfo = AppStorage.get('userInfo') as UserInfo;
    const rsp: GetUserInfoRsp = await BookApi.INVOKE.get<GetUserInfoRsp>(Constants.API_GET_USER_INFO_PATH);
    if (userInfo) {
      // 替换头像和用户名
      rsp.user.nickName = userInfo.nickName;
      rsp.user.avatarUrl = userInfo.avatarUrl;
      rsp.user.isLogin = true;
    } else {
      rsp.user.avatarUrl = '';
      rsp.user.isLogin = false;
    }

    return rsp;
  }

  public static async getBooksShelfList(bookListType: string, bookListPath: string,
    userId: string): Promise<GetBookHistoryRsp> {
    let books = AppStorage.get(bookListType) as BookInfo[];
    if (books === undefined) {
      let rsp = await BookApi.INVOKE.get<GetFavBookRsp>(bookListPath)
      books = rsp.books
      AppStorage.set(bookListType, books)
    }
    return { books: books }
  }
}