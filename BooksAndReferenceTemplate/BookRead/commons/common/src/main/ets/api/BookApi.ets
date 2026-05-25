import { BorrowInfo } from '../model/BorrowInfo';
import { Constants } from '../constant/Constants';
import { TCInvoke } from '../comp/TCInvoke';
import { BookInfo, GroupBook, rankListInfo } from '../model/Book';
import { UserInfo } from 'base_common';
import App from '@system.app';
import { BookCategory } from '../model/BookSortInfo';

export interface GetBookApiRsp {
  books: Array<BookInfo>
}

export interface GetBookBorrowRsp {
  borrows: Array<BorrowInfo>
}

export interface GetHotBookListRsp {
  rankList: Array<rankListInfo>
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

export interface GetBookGroupRsp {
  books: Array<GroupBook>
}

export interface GetBookCategoryRsp {
  category: Array<BookCategory>
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

  public static async getRecommendBookList(): Promise<GetBookApiRsp> {
    const rsp: GetBookApiRsp = await BookApi.INVOKE.get<GetBookApiRsp>(Constants.API_GET_BOOK_RECOMMEND_PATH);
    return rsp;
  }

  public static async getChildBookList(): Promise<GetBookApiRsp> {
    const rsp: GetBookApiRsp = await BookApi.INVOKE.get<GetBookApiRsp>(Constants.API_GET_BOOK_CHILD_PATH);
    return rsp;
  }

  public static async getBorrowList(userId: string): Promise<GetBookBorrowRsp> {
    let rsp: GetBookBorrowRsp = await BookApi.INVOKE.get<GetBookBorrowRsp>(Constants.API_GET_BOOK_BORROW_PATH);
    return rsp;
  }

  public static async getHotRankList(): Promise<GetHotBookListRsp> {
    let rsp: GetHotBookListRsp = await BookApi.INVOKE.get<GetHotBookListRsp>(Constants.API_GET_HOT_BOOK_RANK_LIST_PATH);
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
    if (!books) {
      let rsp = await BookApi.INVOKE.get<GetFavBookRsp>(bookListPath)
      books = rsp.books
      AppStorage.set(bookListType, books)
    }
    return { books: books }
  }

  public static async getBooksShelfGroup(bookListType: string, bookListPath: string,
    userId: string): Promise<GetBookGroupRsp> {
    let books = AppStorage.get(bookListType) as GroupBook[];
    if (!books) {
      let rsp = await BookApi.INVOKE.get<GetBookGroupRsp>(bookListPath)
      books = rsp.books
      AppStorage.set(bookListType, books)
    }
    return { books: books }
  }

  public static async getBookCategoryList(): Promise<GetBookCategoryRsp> {
    const rsp: GetBookCategoryRsp = await BookApi.INVOKE.get<GetBookCategoryRsp>(Constants.API_GET_BOOK_CATEGORY_PATH);
    return rsp;
  }

}