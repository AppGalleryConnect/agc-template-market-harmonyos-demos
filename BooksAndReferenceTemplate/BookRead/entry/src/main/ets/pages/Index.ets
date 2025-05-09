import { Constants, TCRouter } from 'common';
import { TextReader } from '@kit.SpeechKit';
import { BookHomePage } from './BookHomePage';
import { BookViewPage } from 'book_read';
import {
  AboutPage,
  BorrowDetailInfoPage,
  BorrowPage,
  LibraryPage,
  LoginPage,
  PrivacyPage,
  SettingPage
} from 'book_person';
import { BookShelfPage } from 'book_shelf';
import { BookViewListPage, SearchPage } from 'book_home';


@Entry
@ComponentV2
struct Index {
  aboutToAppear(): void {
    TCRouter.replace(Constants.HOME_ROUTER);
  }

  @Builder
  routerMap(name: string) {
    if (name === Constants.HOME_ROUTER) {
      BookHomePage();
    } else if (name === Constants.READ_ROUTER) {
      BookViewPage();
    } else if (name === Constants.SETTING_ROUTE) {
      SettingPage();
    } else if (name === Constants.LIBARY_ROUTE) {
      LibraryPage();
    } else if (name === Constants.BORROW_DETAIL_ROUTE) {
      BorrowDetailInfoPage();
    } else if (name === Constants.BORROW_ROUTE) {
      BorrowPage();
    } else if (name === Constants.SHELF_ROUTER) {
      BookShelfPage();
    } else if (name === Constants.BOOK_LIST_ROUTE) {
      BookViewListPage();
    } else if (name === Constants.SEARCH_ROUTE) {
      SearchPage();
    } else if (name === Constants.LOGIN_ROUTE) {
      LoginPage();
    } else if (name === Constants.ABOUT_ROUTE) {
      AboutPage();
    } else if (name === Constants.PRIVACY_ROUTE) {
      PrivacyPage();
    }
  }

  build() {
    Stack() {
      Navigation(TCRouter.getStack())
        .hideNavBar(true)
        .hideTitleBar(true)
        .mode(NavigationMode.Stack)
        .width(Constants.FULL_SIZE)
        .height(Constants.FULL_SIZE)
        .navDestination(this.routerMap)
    }.height(Constants.FULL_SIZE)
    .width(Constants.FULL_SIZE)
  }
}