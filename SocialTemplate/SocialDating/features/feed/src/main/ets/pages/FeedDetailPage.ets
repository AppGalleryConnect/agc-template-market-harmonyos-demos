import { BasicUserInfo, Constants, NavigationTitleBuilder,Comment, Feed } from 'commons';
import { FeedDetailPageRouteParam } from '../model/FeedDetailPageRouteParam';
import { FeedBasic } from './FeedListPage';
import FeedService from '../service/FeedService';
import Logger from 'commons/src/main/ets/utils/Logger';

@Builder
export function FeedDetailPageBuilder() {
  FeedDetailPage()
}

@Component
struct FeedDetailPage {
  @Consume('pageStack') pageStack: NavPathStack;
  @State feedInfo: Feed | null = null;
  @State isShowFollow: boolean = false;
  @State showCommentSheet: boolean = false;
  @State showCommentSheets: boolean[] = [];
  @State theCommentToReply: Comment | null = null;
  @State newCommentTxt: string = '';
  @State currentUser: BasicUserInfo | null = null;

  aboutToAppear(): void {
    let params: FeedDetailPageRouteParam[] = this.pageStack.getParamByName('FeedDetail') as FeedDetailPageRouteParam[];
    if (params.length >= 1) {
      this.feedInfo = params[0].feed;
      this.isShowFollow = params[0].needShowFollowButton;
      this.currentUser = params[0].currentUser;
      if (this.feedInfo?.uid === this.currentUser?.uid) {
        this.isShowFollow = false;
      }
    }
    if (this.currentUser == null) {
      let userBasicTmp: BasicUserInfo | null | undefined = AppStorage.get(Constants.CURRENT_USER_BASIC);
      if (userBasicTmp != null && userBasicTmp !== undefined) {
        this.currentUser = userBasicTmp;
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        if (this.feedInfo != null) {
          FeedBasic({
            item: this.feedInfo,
            showFollowButton: this.isShowFollow,
            currentPageType: Constants.FEED_PAGE_TYPE_DETAIL,
            pageStack: this.pageStack,
            currentUser: this.currentUser,
            showInteraction: true
          })
        }
      }
    }.onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    }).onBackPressed(() => {
      if (this.feedInfo != null && this.feedInfo.feedId != null) {
        FeedService.getFeedDetail(this.feedInfo.feedId).then((data: Feed | null) => {
          if (data != null) {
            let navPathInfo = this.pageStack.pop(data, false)
            Logger.debug('FeedDetail pop navPathInfo=' + JSON.stringify(navPathInfo))
          }
        })
      }
      return true;
    }).backgroundColor($r('app.color.page_background_color'))
    .title(NavigationTitleBuilder('动态详情'))
  }
}

