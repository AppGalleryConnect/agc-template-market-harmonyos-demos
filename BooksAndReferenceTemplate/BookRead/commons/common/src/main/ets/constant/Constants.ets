import { emitter } from '@kit.BasicServicesKit';

export class Constants {
  public static readonly FILE_SPLIT: string = '/';
  public static readonly EPUB_FILE_SUFFIX = '.epub';
  public static readonly ZIP_FILE_SUFFIX = '.zip';
  public static readonly FULL_SIZE = '100%';
  public static readonly HOME_ROUTER = 'home';
  public static readonly READ_ROUTER = 'read';
  public static readonly SHELF_ROUTER = 'shelf';
  public static readonly BOOK_LIST_ROUTE = 'book_list';
  public static readonly HISTORY_ROUTE = 'history';
  public static readonly LIBARY_ROUTE = 'libary';
  public static readonly BORROW_ROUTE = 'borrow_card';
  public static readonly SETTING_ROUTE = 'settings';
  public static readonly FAVOURITE_ROUTE = 'favourite';
  public static readonly BORROW_DETAIL_ROUTE = 'detail';
  public static readonly ABOUT_ROUTE = 'about';
  public static readonly PRIVACY_ROUTE = 'privacy';
  public static readonly SPEECH_ROUTE = 'speech'
  public static readonly PERSON_ROUTE = 'person';
  public static readonly SEARCH_ROUTE = 'search';
  public static readonly LOGIN_ROUTE = 'login';
  public static readonly HTTP_GET = 'GET';
  public static readonly HTTP_POST = 'POST';
  public static readonly HTTP_PUT = 'PUT';
  public static readonly HTTP_DELETE = 'DELETE';
  public static readonly MODE_FLAG: string = 'release';
  public static readonly API_GET_BOOK_PATH: string = '/book/list';
  public static readonly API_GET_BOOK_FAVOURITE_PATH: string = '/book/favourite';
  public static readonly API_GET_BOOK_BORROW_PATH: string = '/book/borrow';
  public static readonly API_GET_USER_INFO_PATH: string = '/user/info';
  public static readonly API_GET_BOOK_HISTORY_PATH: string = '/book/history';
  public static readonly MIN_SCREEN_BRIGHT = 0;
  public static readonly MAX_SCREEN_BRIGHT = 1;
  public static readonly MIN_FONT_SIZE = 50;
  public static readonly MAX_FONT_SIZE = 80;
  public static readonly MIN_PAGE_NUM = 0;
  public static readonly SWIPER_CHANGE: emitter.InnerEvent = {
    eventId: 10
  };
  public static readonly VIEW_COLOR_CHANGE: emitter.InnerEvent = {
    eventId: 11
  }
  public static readonly FONT_CHANGE: emitter.InnerEvent = {
    eventId: 12
  }
  public static readonly LOGIN_CHANGE: emitter.InnerEvent = {
    eventId: 13
  }
  public static readonly TAB_INDEX_ZERO: number = 0;
  public static readonly TAB_INDEX_ONE: number = 1;
  public static readonly TAB_INDEX_TWO: number = 2;
  public static readonly TAB_INDEX_THREE: number = 3;
}

export type TData = ESObject