import { BreakpointSystem, Constants, TCRouter } from 'common';
import { BookHomePage } from './BookHomePage';
import {
  AboutPage,
  BorrowDetailInfoPage,
  BorrowPage,
  LibraryPage,
  LoginPage,
  PrivacyPage,
  SettingPage,
  AccountPage,
  PreferencePage,
  ActivityPage,
  FeedbackPage,
  FeedbackRecordPage,
  IssueAndFeedbackPage,
  PrivacyPolicyPage,
  WelfareCenter,
  DataCollectionPage,
  DataSharingPage,
  ReadSettingPage,
  messagePage,
  MemberCenterPage,
  MemberAgreementPage,
  RechargePage,
  RechargeRecordPage,
  ReadHistoryBuilder,
  MinorsModePage,
  ReadRecordPage,
  MyDownloadPageBuilder,
  SettingFont,
  PrivacyAgreementPage,
  LaunchAdPage,
  CustomerServiceChatPage
} from 'book_person';
import { BookGroupContent, BookShelfPage } from 'book_shelf';
import { BookListPage, BookViewListPage, SearchPage } from 'book_home';
import { ReaderPage, WriteReviewPage, WriteCommentPage, WonderfulReviewPage, MyReviewPage } from 'book_read_kit';


@Entry
@ComponentV2
struct Index {
  aboutToAppear(): void {
    const uiContext = this.getUIContext()
    BreakpointSystem.register(uiContext)
    TCRouter.push(Constants.PRIVACY_AGREEMENT_ROUTER)
    this.pushKitRouter()
  }

  pushKitRouter() {
    if (AppStorage.get('takeMessage') === 1) {
      TCRouter.push(Constants.MESSAGE_PAGE_ROUTE)
      AppStorage.setOrCreate('takeMessage', 0)
      AppStorage.setOrCreate('inMessagePage', 1)
    }
  }

  @Builder
  routerMap(name: string) {
    if (name === Constants.HOME_ROUTER) {
      BookHomePage();
    } else if (name === Constants.READ_KIT_ROUTER) {
      ReaderPage();
    } else if (name === Constants.SETTING_ROUTE) {
      SettingPage()
    } else if (name === Constants.ACCOUNT_ROUTE) {
      AccountPage();
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
    } else if (name === Constants.PREFERENCE_ROUTE) {
      PreferencePage();
    } else if (name === Constants.ACTIVITY_ROUTE) {
      ActivityPage();
    } else if (name === Constants.ABOUT_ROUTE) {
      AboutPage();
    } else if (name === Constants.PRIVACY_ROUTE) {
      PrivacyPage();
    } else if (name === Constants.FONT_ROUTE) {
      SettingFont();
    } else if (name === Constants.FEEDBACK_ROUTE) {
      FeedbackPage();
    } else if (name === Constants.FEEDBACK_RECORD_ROUTE) {
      FeedbackRecordPage();
    } else if (name === Constants.ISSUE_AND_FEEDBACK_ROUTE) {
      IssueAndFeedbackPage();
    } else if (name === Constants.BOOK_CASE_ROUTER) {
      BookListPage();
    } else if (name === Constants.PRIVACY_POLICY_ROUTE) {
      PrivacyPolicyPage();
    } else if (name === Constants.MEMBER_CENTER_ROUTE) {
      MemberCenterPage();
    } else if (name === Constants.MEMBER_AGREEMENT_ROUTE) {
      MemberAgreementPage();
    } else if (name === Constants.RECHARGE_ROUTE) {
      RechargePage();
    } else if (name === Constants.RECHARGE_RECORD_ROUTE) {
      RechargeRecordPage();
    } else if (name === Constants.WELFARE_CENTER) {
      WelfareCenter()
    } else if (name === Constants.DATA_COLLECTION_ROUTE) {
      DataCollectionPage();
    } else if (name === Constants.DATA_SHARING_ROUTE) {
      DataSharingPage();
    } else if (name === Constants.READ_SETTING_ROUTE) {
      ReadSettingPage();
    } else if (name === Constants.WRITE_REVIEW_ROUTE) {
      WriteReviewPage();
    } else if (name === Constants.ALL_REVIEW_ROUTE) {
      WriteReviewPage();
    } else if (name === Constants.WRITE_COMMENT_ROUTE) {
      WriteCommentPage();
    } else if (name === Constants.WONDERFUL_REVIEW_ROUTE) {
      WonderfulReviewPage();
    } else if (name === Constants.MY_EVALUATION_ROUTE) {
      MyReviewPage();
    } else if (name === Constants.MESSAGE_PAGE_ROUTE) {
      messagePage();
    } else if (name === Constants.GROUP_ROUTE) {
      BookGroupContent();
    } else if (name === Constants.READ_HISTORY_ROUTE) {
      ReadHistoryBuilder();
    } else if (name === Constants.MINORS_MODE_ROUTE) {
      MinorsModePage();
    } else if (name === Constants.READ_RECORD_ROUTE) {
      ReadRecordPage();
    } else if (name === Constants.MY_DOWNLOAD_ROUTE) {
      MyDownloadPageBuilder();
    } else if (name === Constants.LAUNCH_AD_ROUTER) {
      LaunchAdPage();
    } else if (name === Constants.PRIVACY_AGREEMENT_ROUTER) {
      PrivacyAgreementPage();
    } else if (name === Constants.CUSTOMER_SERVICE_CHAT_ROUTER) {
      CustomerServiceChatPage();
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