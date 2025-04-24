import {
  BasicUserInfo,
  Constants,
  NavigationTitleBuilder,
  QueryFeedType,
  UserFullInfo,
  QueryFeedResponse,
  Feed
} from 'commons';
import { ActionSummaryPageParam, ActionSummaryPageType } from '../model/ActionSummaryPageParam';
import { User } from 'user'
import { FeedBasic, emptyActionPageContent, FeedListPageRouteParam } from 'feed'
import Logger from 'commons/src/main/ets/utils/Logger';
import FeedService from 'feed/src/main/ets/service/FeedService';
import UserService from 'user/src/main/ets/service/UserService';

@Builder
export function ActionSummaryPageBuilder() {
  ActionSummaryPage()
}


/**
 * 操作汇总页面
 */
@Component
export struct ActionSummaryPage {
  @Consume('pageStack') pageStack: NavPathStack;
  @State userFullInfos: UserFullInfo[] | null = null;
  @State feeds: Feed[] | null = null;
  @State pageType: ActionSummaryPageType = ActionSummaryPageType.FollowUser;
  @State currentIndex: number = 0;
  @State currentUserBasic: BasicUserInfo | null | undefined = null;
  @State noMoreFeedFlag: boolean = false;
  @State noFeedAtAll: boolean = false;
  private scroller: Scroller = new Scroller();
  private tab1Content: string[] = [];
  private tab2Content: string[] = [];
  private queryFeedType: QueryFeedType = QueryFeedType.QUERY_MY_LIKE;
  private feedPage = 1;

  aboutToAppear(): void {
    let params: ActionSummaryPageParam[] =
      this.pageStack.getParamByName('ActionSummaryPage') as ActionSummaryPageParam[];
    if (params.length >= 1) {
      let actionSummaryPageParam: ActionSummaryPageParam = params[0]
      this.tab1Content = actionSummaryPageParam.emptyTab1Info;
      this.tab2Content = actionSummaryPageParam.emptyTab2Info;
      this.userFullInfos = actionSummaryPageParam.userInfos;
      this.feeds = actionSummaryPageParam.feeds;
      this.pageType = actionSummaryPageParam.pageType;
      this.setQueryFeedType();
    }
    this.currentUserBasic = AppStorage.get(Constants.CURRENT_USER_BASIC)
    this.prepareData();
  }

  private setQueryFeedType() {
    if (this.pageType === ActionSummaryPageType.Like) {
      this.queryFeedType =
        this.currentIndex === 0 ? QueryFeedType.QUERY_MY_LIKE : QueryFeedType.QUERY_LIKED_BY_OTHERS;
    } else if (this.pageType === ActionSummaryPageType.Comment) {
      this.queryFeedType =
        this.currentIndex === 0 ? QueryFeedType.QUERY_MY_COMMENTED : QueryFeedType.QUERY_COMMENTED_BY_OTHERS;
    }
  }

  build() {
    NavDestination() {
      Tabs({ index: this.currentIndex }) {
        this.buildTab(this.tab1Content, 0)
        this.buildTab(this.tab2Content, 1)
      }.onChange((index: number) => {
        this.currentIndex = index;
        this.setQueryFeedType();
        this.prepareData();
      })
    }.backgroundColor($r('app.color.page_background_color')).title(NavigationTitleBuilder(this.getPageTitle()))
    .onBackPressed(() => {
      this.pageStack.pop('', false)
      return false;
    })
  }

  private prepareData() {
    if (this.currentUserBasic != null && this.currentUserBasic !== undefined &&
      this.currentUserBasic.uid != null) {
      if (this.pageType === ActionSummaryPageType.FollowUser) {
        UserService.queryFollowedUser(this.currentUserBasic.uid, this.currentIndex)
          .then((data: UserFullInfo[]) => {
            this.userFullInfos = data;
          });
      } else if (this.pageType === ActionSummaryPageType.Like) {
        FeedService.getFeedList(this.queryFeedType.toString(), this.currentUserBasic.uid, this.feedPage)
          .then((data: QueryFeedResponse | null) => {
            this.processQueryFeedRsp(data)
          });
      } else {
        FeedService.getFeedList(this.queryFeedType.toString(), this.currentUserBasic.uid, this.feedPage)
          .then((data: QueryFeedResponse | null) => {
            this.processQueryFeedRsp(data)
          });
      }
    }
  }

  processQueryFeedRsp(data: QueryFeedResponse | null) {
    if (data != null) {
      if (data.list != null && data.list.length > 0) {
        this.feeds = data.list;
      }
      if (data.list.length === 0 || data.page.totalPages === this.feedPage) {
        this.noMoreFeedFlag = true;
      }
      if (data.page.totalCount === 0) {
        this.noFeedAtAll = true;
      } else {
        this.noFeedAtAll = false;
      }
    }
  }

  @Builder
  buildTab(tabInfo: string[], idx: number) {
    TabContent() {
      if (this.pageType === ActionSummaryPageType.FollowUser) {
        if (this.userFullInfos == null || this.userFullInfos.length === 0) {
          this.noContentPage(tabInfo);
        } else {
          this.scrollShowUsers()
        }
      } else {
        if (this.noFeedAtAll) {
          this.noContentPage(tabInfo);
        } else {
          this.scrollShowFeeds()
        }
      }
    }.tabBar(this.buildTabBar(tabInfo[0], idx)).height('100%')
  }

  @Builder
  noContentPage(tabInfo: string[]) {
    if (tabInfo[4] === 'NewFeed') {
      emptyActionPageContent(tabInfo, this.pageStack, () => {
        Logger.debug('action summary Page onPop, tabInfo=' + JSON.stringify(tabInfo) + ', currentUser=' +
        JSON.stringify(this.currentUserBasic))
        if (this.currentUserBasic != null) {
          this.pageStack.pushPathByName('FeedList',
            new FeedListPageRouteParam(QueryFeedType.QUERY_BY_USER, this.currentUserBasic,
              this.currentUserBasic), (pop: PopInfo) => {
              Logger.debug('FeedList pop to action summary page')
              let navPathInfo = this.pageStack.pop('', false);
              Logger.debug('navPathInfo=' + JSON.stringify(navPathInfo))
            });
        }
      })
    } else {
      emptyActionPageContent(tabInfo, this.pageStack, () => {
        Logger.debug('action summary page, feedListPage on pop, this.pageType=' + this.pageType + ' currentUser=' +
        JSON.stringify(this.currentUserBasic))
        let navPathInfo = this.pageStack.pop('', false);
        Logger.debug('action summary page, the pop path=' + JSON.stringify(navPathInfo))
      });
    }
  }

  @Builder
  scrollShowUsers() {
    Scroll(this.scroller) {
      Column() {
        ForEach(this.userFullInfos, (item: UserFullInfo) => {
          if (item != null && item.userInfo != null) {
            User({ userInfo: item.userInfo });
          }
        }, (item: UserFullInfo) => JSON.stringify(item.userInfo));
      };
    }
    .align(Alignment.TopStart)
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Auto)
    .scrollBarColor(0xFFF8F6F6)
    .scrollBarWidth(5)
    .edgeEffect(EdgeEffect.Spring)
    .height('100%')
  }

  @Builder
  scrollShowFeeds() {
    Scroll(this.scroller) {
      Column() {
        ForEach(this.feeds, (item: Feed) => {
          FeedBasic({
            item: item,
            showFollowButton: item.currentUserHasFollowed == null || item.currentUserHasFollowed === Constants.NO,
            currentPageType: Constants.FEED_PAGE_TYPE_LIST,
            pageStack: this.pageStack,
            currentUser: this.currentUserBasic,
            showInteraction: false,
            feedChange: () => {
              this.prepareData();
            }
          }).margin({ bottom: 16 });
        }, (item: Feed) => item.feedId?.toString());
        Blank().width(100);
        if (this.noMoreFeedFlag) {
          Row() {
            Text('没有更多了～').fontSize($r('sys.float.Body_M'))
              .fontColor('#66000000')
          }.justifyContent(FlexAlign.Center).margin({ top: 16, bottom: 16 });
        }
      };
    }
    .align(Alignment.TopStart)
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Auto)
    .scrollBarColor(0xFFF8F6F6) // 滚动条颜色
    .scrollBarWidth(5) // 滚动条宽度
    .edgeEffect(EdgeEffect.Spring)
    .onScrollEdge((side: Edge) => {
      this.onScrollEdge(side);
    })
    .height('100%')
  }

  private onScrollEdge(side: Edge) {
    if (side === Edge.Bottom) {
      if (this.scroller.isAtEnd()) {
        if (!this.noMoreFeedFlag && this.currentUserBasic != null) {
          this.feedPage += 1;
          this.getFeedFromServer();
        }
      }
    }
    if (side === Edge.Top) {
      if (this.feedPage > 1) {
        this.feedPage -= 1;
        this.getFeedFromServer();
      }
    }
  }

  private getFeedFromServer() {
    if (this.currentUserBasic != null) {
      FeedService.getFeedList(this.queryFeedType.toString(), this.currentUserBasic.uid, this.feedPage)
        .then((data: QueryFeedResponse | null) => {
          this.processQueryFeedRsp(data);
        });
    }
  }

  @Builder
  buildTabBar(tabName: string, tabIndex: number) {
    Column({ space: '6vp' }) {
      Text(tabName)
        .fontSize(18)
        .fontColor(this.currentIndex === tabIndex ? $r('app.color.button_background_color') :
        $r('app.color.title_font_color'))
        .fontWeight(FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = tabIndex;
    })
  }

  getPageTitle(): string {
    if (this.pageType === ActionSummaryPageType.FollowUser) {
      return '关注'
    } else if (this.pageType === ActionSummaryPageType.Like) {
      return '点赞'
    } else {
      return '评论'
    }
  }
}
