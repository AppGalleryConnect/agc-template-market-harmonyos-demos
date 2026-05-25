import { emitter } from '@kit.BasicServicesKit';

export class Constants {
  public static readonly FILE_SPLIT: string = '/';
  public static readonly EPUB_FILE_SUFFIX = '.epub';
  public static readonly ZIP_FILE_SUFFIX = '.zip';
  public static readonly FULL_SIZE = '100%';
  public static readonly ABOUT_HALF_SIZE = '47%';
  public static readonly LAUNCH_AD_ROUTER = 'launch_ad';
  public static readonly PRIVACY_AGREEMENT_ROUTER = 'privacy_agreement';
  public static readonly CUSTOMER_SERVICE_CHAT_ROUTER = 'customer_service_chat';
  public static readonly HOME_ROUTER = 'home';
  public static readonly READ_ROUTER = 'read';
  public static readonly READ_KIT_ROUTER = 'read_kit';
  public static readonly SHELF_ROUTER = 'shelf';
  public static readonly BOOK_CASE_ROUTER = 'case';
  public static readonly BOOK_LIST_ROUTE = 'book_list';
  public static readonly HISTORY_ROUTE = 'history';
  public static readonly PREFERENCE_ROUTE = 'preference'
  public static readonly ACTIVITY_ROUTE = 'activity'
  public static readonly LIBARY_ROUTE = 'libary';
  public static readonly BORROW_ROUTE = 'borrow_card';
  public static readonly SETTING_ROUTE = 'settings';
  public static readonly ACCOUNT_ROUTE = 'account';
  public static readonly MINORS_MODE_ROUTE = 'minors_mode';
  public static readonly READ_RECORD_ROUTE = 'read_record';
  public static readonly FAVOURITE_ROUTE = 'favourite';
  public static readonly BORROW_DETAIL_ROUTE = 'detail';
  public static readonly ABOUT_ROUTE = 'about';
  public static readonly PRIVACY_ROUTE = 'privacy';
  public static readonly FONT_ROUTE = 'font';
  public static readonly PRIVACY_POLICY_ROUTE = 'privacy_policy';
  public static readonly SPEECH_ROUTE = 'speech'
  public static readonly PERSON_ROUTE = 'person';
  public static readonly SEARCH_ROUTE = 'search';
  public static readonly MESSAGE_PAGE_ROUTE = 'message_page';
  public static readonly LOGIN_ROUTE = 'login';
  public static readonly WELFARE_CENTER = 'WelfareCenter';
  public static readonly GROUP_ROUTE = 'group_detail';
  public static readonly MEMBER_CENTER_ROUTE = 'member_center';
  public static readonly MEMBER_AGREEMENT_ROUTE = 'member_agreement';
  public static readonly RECHARGE_ROUTE = 'recharge';
  public static readonly RECHARGE_RECORD_ROUTE = 'recharge_record';
  public static readonly FEEDBACK_ROUTE = 'feedback';
  public static readonly FEEDBACK_RECORD_ROUTE = 'feedback_record';
  public static readonly ISSUE_AND_FEEDBACK_ROUTE = 'issue_and_feedback';
  public static readonly DATA_COLLECTION_ROUTE = 'data_collection';
  public static readonly DATA_SHARING_ROUTE = 'data_sharing';
  public static readonly READ_SETTING_ROUTE = 'read_setting';
  public static readonly WRITE_REVIEW_ROUTE = 'write_review';
  public static readonly ALL_REVIEW_ROUTE = 'all_review';
  public static readonly WRITE_COMMENT_ROUTE = 'write_comment';
  public static readonly WONDERFUL_REVIEW_ROUTE = 'wonderful_review';
  public static readonly MY_EVALUATION_ROUTE = 'my_evaluation';
  public static readonly READ_HISTORY_ROUTE = 'read_history';
  public static readonly MY_DOWNLOAD_ROUTE = 'my_download';
  public static readonly HTTP_GET = 'GET';
  public static readonly HTTP_POST = 'POST';
  public static readonly HTTP_PUT = 'PUT';
  public static readonly HTTP_DELETE = 'DELETE';
  public static readonly MODE_FLAG: string = 'release';
  public static readonly API_GET_BOOK_PATH: string = '/book/list';
  public static readonly API_GET_BOOK_RECOMMEND_PATH: string = '/book/recommend';
  public static readonly API_GET_BOOK_CHILD_PATH: string = '/book/child';
  public static readonly API_GET_HOT_BOOK_RANK_LIST_PATH: string = '/book/hotRankList';
  public static readonly API_GET_BOOK_FAVOURITE_PATH: string = '/book/favourite';
  public static readonly API_GET_BOOK_BORROW_PATH: string = '/book/borrow';
  public static readonly API_GET_USER_INFO_PATH: string = '/user/info';
  public static readonly API_GET_BOOK_HISTORY_PATH: string = '/book/history';
  public static readonly API_GET_BOOK_CATEGORY_PATH: string = '/book/categoryList';
  public static readonly API_GET_BOOK_LIKE_PATH: string = '/book/like';
  public static readonly API_GET_BOOK_GROUP_PATH: string = '/book/group';
  public static readonly MIN_SCREEN_BRIGHT = 0;
  public static readonly MAX_SCREEN_BRIGHT = 1;
  public static readonly MIN_FONT_SIZE = 50;
  public static readonly MAX_FONT_SIZE = 80;
  public static readonly MIN_PAGE_NUM = 0;
  public static readonly FULL_WIDTH: string = '100%';
  public static readonly FULL_HEIGHT: string = '100%';
  public static readonly CUSTOM_SLIDER_WIDTH: string = '15%';
  public static readonly CUSTOM_SLIDER_HEIGHT: string = 'auto';
  public static readonly DATE: string = '今天';
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
  public static readonly COINS_CHANGE: emitter.InnerEvent = {
    eventId: 14
  }
  public static readonly COINS_AD: emitter.InnerEvent = {
    eventId: 15
  }
  public static readonly TAB_INDEX_ZERO: number = 0;
  public static readonly TAB_INDEX_ONE: number = 1;
  public static readonly TAB_INDEX_TWO: number = 2;
  public static readonly TAB_INDEX_THREE: number = 3;
}

export type TData = ESObject