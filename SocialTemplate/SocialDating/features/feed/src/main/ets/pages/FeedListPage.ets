import {
  BasicUserInfo,
  CommonRsp,
  CommonUtils,
  Constants,
  DateUtils,
  NavigationTitleBuilder,
  QueryFeedType,
  Comment,
  Feed,
  FollowType,
  QueryFeedResponse,
  LikeOperType,
  buildRealNameLabelForList
} from 'commons';
import { FeedDetailPageRouteParam } from '../model/FeedDetailPageRouteParam';
import { FeedListPageRouteParam } from '../model/FeedListPageRouteParam';
import Logger from 'commons/src/main/ets/utils/Logger';
import FeedService from '../service/FeedService';
import LikeService from '../service/LikeService';
import CommentService from '../service/CommentService';

@Builder
export function FeedListPageBuilder() {
  FeedListPage()
}

const ADD_BUTTON_DRAG_MAX_X = 280;
const ADD_BUTTON_DRAG_MIN_Y = 60;
const ADD_BUTTON_DRAG_MAX_Y = 550;

@Component
export struct FeedListPage {
  @Consume('pageStack') pageStack: NavPathStack;
  @State feedInfos: Feed[] | null = null;
  @State currentIndex: number = 0
  @State noMoreFlag: boolean = false;
  @State theUserToQueryFeed: BasicUserInfo | null = null;
  @State addButtonX: number = 270;
  @State addButtonY: number = 500;
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @Prop @Watch('onChange') index: number = 0;
  @State noFeedAtAll: boolean = false;
  private pageTitle: string = '';
  private needAutoGetFeeds: boolean = true;
  private currentUser: BasicUserInfo | null = null;
  private scroller: Scroller = new Scroller();
  private curPage: number = 1;
  private queryFeedType: QueryFeedType = QueryFeedType.QUERY_RECOMMEND;
  private showUserInfo: boolean = true;

  aboutToAppear(): void {
    let params: FeedListPageRouteParam[] = this.pageStack.getParamByName('FeedList') as FeedListPageRouteParam[];
    if (params.length >= 1 && params[0] != null) {
      this.needAutoGetFeeds = params[0].queryFeedType === QueryFeedType.QUERY_RECOMMEND ||
        params[0].queryFeedType === QueryFeedType.QUERY_FOLLOWED;
      this.queryFeedType = params[0].queryFeedType;
      this.theUserToQueryFeed = params[0].theUserToQueryFeed;
      if (params[0].feedListPageTitle !== undefined && params[0].feedListPageTitle != null) {
        this.pageTitle = params[0].feedListPageTitle;
      }
    }

    this.getCurrentUserBasicFromAppStorage();

    if (this.currentUser != null && this.theUserToQueryFeed != null) {
      if (this.currentUser.uid === this.theUserToQueryFeed.uid) {
        this.showUserInfo = false;
      }
    }

    this.getFeedFromServer();
  }

  private getCurrentUserBasicFromAppStorage() {
    let userBasicTmp: BasicUserInfo | null | undefined = AppStorage.get(Constants.CURRENT_USER_BASIC);
    if (userBasicTmp != null && userBasicTmp !== undefined) {
      this.currentUser = userBasicTmp;
    }
  }

  onChange() {
    if (this.index === Constants.PAGE_INDEX_FEED) {
      // 对于用户注销后重新创建的场景，在页面切换时需要刷新currentUser
      let newRegisterFlag: boolean | null | undefined = AppStorage.get(Constants.NEW_REGISTER_FLAG);
      if (newRegisterFlag != null && newRegisterFlag !== undefined && newRegisterFlag) {
        this.getCurrentUserBasicFromAppStorage();
      }
      this.getFeedFromServer();
    }
  }

  private getFeedFromServer() {
    if (this.needAutoGetFeeds) {
      FeedService.getFeedList(this.currentIndex.toString(), this.curPage).then((data: QueryFeedResponse | null) => {
        this.processQueryFeedRsp(data);
      });
    } else {
      if (this.theUserToQueryFeed != null) {
        FeedService.getFeedList(this.queryFeedType.toString(), this.theUserToQueryFeed.uid, this.curPage)
          .then((data: QueryFeedResponse | null) => {
            this.processQueryFeedRsp(data);
          });
      }
    }
  }

  private processQueryFeedRsp(data: QueryFeedResponse | null) {
    if (data != null) {
      if (data.list != null && data.list.length > 0) {
        this.feedInfos = data.list;
      }
      Logger.debug('feedInfos = ' + JSON.stringify(this.feedInfos));
      if (data.page.totalPages <= this.curPage) {
        this.noMoreFlag = true;
      }
      if (data.page.totalCount === 0) {
        this.noFeedAtAll = true;
      } else {
        this.noFeedAtAll = false
      }
    }
  }

  build() {
    if (this.needAutoGetFeeds) {
      NavDestination() {
        this.buildTabBarRow()
        Tabs({ barPosition: BarPosition.Start, index: this.currentIndex }) {
          TabContent() {
            this.buildFeedListPage()
          }

          TabContent() {
            this.buildFeedListPage()
          }
        }.barHeight(0).onChange((index: number) => {
          this.currentIndex = index
          FeedService.getFeedList(this.currentIndex.toString()).then((data: QueryFeedResponse | null) => {
            this.processQueryFeedRsp(data);
          })
        })
      }.backgroundColor($r('app.color.page_background_color'))
      .onBackPressed(() => {
        Logger.debug('FeedListRecommendPage backPressed')
        this.pageStack.pop('', false)
        return false;
      })
    } else {
      NavDestination() {
        this.buildFeedListPage()
      }
      .backgroundColor($r('app.color.page_background_color'))
      .title(NavigationTitleBuilder(this.pageTitle))
      .onBackPressed(() => {
        Logger.debug('FeedListPage backPressed')
        this.pageStack.pop('', false)
        return false;
      })
    }
  }

  @Builder
  buildTabBarRow() {
    Row() {
      Text('推荐')
        .fontColor(this.currentIndex === 0 ? $r('app.color.button_background_color') :
        $r('app.color.text_font_color_black'))
        .fontWeight(this.currentIndex === 0 ? FontWeight.Bold : FontWeight.Regular)
        .fontSize(18)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.currentIndex = 0;
        })
        .margin({ left: 120, right: 24 });

      Text('关注')
        .fontColor(this.currentIndex === 1 ?
        $r('app.color.button_background_color') : $r('app.color.text_font_color_black'))
        .fontWeight(this.currentIndex === 1 ? FontWeight.Bold : FontWeight.Regular)
        .fontSize(18)
        .fontFamily('HarmonyHeiTi')
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.currentIndex = 1;
        })
        .margin({ left: 24, right: 120 });

    }.backgroundColor($r('app.color.page_background_color')).margin({ bottom: 16 })
  }

  @Builder
  buildFeedListPage() {
    if (this.noFeedAtAll) {
      if (this.needAutoGetFeeds) {
        emptyActionPageContent(['', '你还没关注过任何人呢', '去推荐看看吧', '', '', 'app.media.img_follow'],
          this.pageStack)
      } else {
        Column() {
          emptyActionPageContent(['', '暂时还没有发布动态哦', '赶快发布动态让别人更好的认识你吧～',
            '发布动态', 'NewFeed', 'app.media.img_no_feed'],
            this.pageStack, () => {
              this.getFeedFromServer();
            })
        }.height('100%').justifyContent(FlexAlign.Center)
      }
    } else {
      Stack() {
        this.showFeeds()
        if (this.needAutoGetFeeds) {
          Row() {
            this.showCreateFeedIcon()
          }.position({ x: this.addButtonX, y: this.addButtonY })
        }
      }
    }
  }

  @Builder
  showFeeds() {
    Scroll(this.scroller) {
      Column() {
        ForEach(this.feedInfos, (item: Feed, index: number) => {
          FeedBasic({
            item: item,
            showFollowButton: (item.currentUserHasFollowed == null || item.currentUserHasFollowed === Constants.NO),
            currentPageType: Constants.FEED_PAGE_TYPE_LIST,
            pageStack: this.pageStack,
            currentUser: this.currentUser,
            showUserInfo: this.showUserInfo,
            feedChange: () => {
              Logger.debug('feedChange, item=' + JSON.stringify(item))
              this.getFeedFromServer();
            }
          }).margin({ bottom: 16, right: 6 });
        }, (item: Feed) => JSON.stringify(item));
        Blank().height(100);
        if (this.noMoreFlag) {
          Row() {
            Text('没有更多了～')
              .fontSize($r('sys.float.Body_M'))
              .fontColor('#66000000')
              .fontFamily(Constants.HARMONY_HEITI);
          }.justifyContent(FlexAlign.Center);
        }
      };
    }
    .align(Alignment.TopStart)
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .onScrollEdge((side: Edge) => {
      if (side === Edge.Bottom && !this.noMoreFlag) {
        this.curPage = this.curPage + 1;
        this.getFeedFromServer();
      }
      if (side === Edge.Top) {
        if (this.curPage > 1) {
          this.curPage = this.curPage - 1;
        }
        this.getFeedFromServer();
      }
    })
    .height('100%')
    .align(Alignment.TopStart)
  }

  @Builder
  showCreateFeedIcon() {
    Image($r('app.media.ic_new_feed'))
      .width(64)
      .height(64)
      .margin(10)
      .onClick(
        () => {
          this.pageStack.pushPathByName('NewFeed', null);
        }
      )
      .gesture(PanGesture()
        .onActionUpdate((event: GestureEvent | undefined) => {
          if (event) {
            let tmp = this.addButtonX + event.offsetX;
            let tmp1 = this.addButtonY + event.offsetY;
            Logger.debug('panGesture, x=' + tmp + ',y=' + tmp1);
            if (tmp > 0 && tmp < ADD_BUTTON_DRAG_MAX_X && tmp1 > ADD_BUTTON_DRAG_MIN_Y &&
              tmp1 < ADD_BUTTON_DRAG_MAX_Y) {
              this.offsetX = tmp;
              this.offsetY = tmp1;
            }
          }
        })
        .onActionEnd(() => {
          this.addButtonX = this.offsetX;
          this.addButtonY = this.offsetY;
        }))
  }
}

@Builder
export function showFeedImage(resourceUrl: string[], gridItemHeight: number) {
  if (resourceUrl != null && resourceUrl.length > 0) {
    if (resourceUrl.length === 1) {
      if (resourceUrl[0].startsWith('app.media')) {
        oneFeedImag($r(resourceUrl[0]), gridItemHeight)
      } else {
        oneFeedImag(resourceUrl[0], gridItemHeight)
      }
    } else if (resourceUrl.length < 4) {
      GridShowImage({
        resourceUrl: resourceUrl,
        rowTemplate: '1fr',
        columnTemplate: '1fr 1fr 1fr',
        gridHeight: (gridItemHeight + 10),
        gridItemHeight: gridItemHeight
      });
    } else if (resourceUrl.length < 7) {
      GridShowImage({
        resourceUrl: resourceUrl,
        rowTemplate: '1fr 1fr',
        columnTemplate: '1fr 1fr 1fr',
        gridHeight: (gridItemHeight + 10) * 2,
        gridItemHeight: gridItemHeight
      });
    } else {
      GridShowImage({
        resourceUrl: resourceUrl,
        rowTemplate: '1fr 1fr 1fr',
        columnTemplate: '1fr 1fr 1fr',
        gridHeight: (gridItemHeight + 10) * 3,
        gridItemHeight: gridItemHeight
      });
    }
  }
}

@Builder
function oneFeedImag(resourceUrl: string | Resource, gridItemHeight: number) {
  Image(resourceUrl)
    .width(gridItemHeight * 2)
    .height(gridItemHeight * 2)
    .objectFit(ImageFit.Cover)
    .borderRadius(16)
    .margin({ top: 6 })
}

const FEED_INTERACTION_MASK_HEIGHT = 160;

@Component
export struct FeedBasic {
  @State item: Feed | null = null;
  @State showFollowButton: boolean = false;
  @State currentPageType: number = Constants.FEED_PAGE_TYPE_LIST
  @State pageStack: NavPathStack | null = null;
  @State currentUser: BasicUserInfo | null = null;
  @State showCommentSheet: boolean = false;
  @State replyComment: boolean = false;
  @State newCommentTxt: string = '';
  @State clickLike: boolean = false;
  @State showInteraction: boolean = false;
  @State showUserInfo: boolean = true;
  @State showLikeDetail: boolean = false;
  @State blurRadius: number = 0;
  @State theCommentToReply: Comment | null = null;
  @State likes: BasicUserInfo[] | null = [];
  @State comments: Comment[] | null = [];
  @State likedNickNames: string = '';
  @State likedNickNamesExpandFlag: boolean = false;
  @State needShowNickNameExpand: boolean = false;
  @State feedMsgMeasuredHeight: number | Length = 0
  @State commentSheetHeight: number = Constants.COMMENT_SHEET_HEIGHT_DEFAULT;
  @State feedLikesHeight: number = 0
  @State feedCommentsHeight: number = 0
  feedChange?: () => void;

  aboutToAppear(): void {
    this.setClickLike();
    if (!this.isCurrentUserVip()) {
      this.blurRadius = 20;
    }
    this.buildLikedNickNamesPart();
  }

  private isCurrentUserVip(): boolean {
    return this.currentUser != null && this.currentUser.isVip != null && this.currentUser.isVip === Constants.YES;
  }

  private setClickLike() {
    let currentUserInLikeArr: boolean = false;
    if (this.item != null && this.item.likes != null) {
      this.likes = this.item.likes;
      for (let i = 0; i < this.item.likes.length; i++) {
        let tmp = this.item.likes[i];
        if (tmp.uid != null && tmp.uid === this.currentUser?.uid) {
          currentUserInLikeArr = true;
          break;
        }
      }
    }
    if (this.item != null && this.item.comments != null) {
      this.comments = this.item.comments;
    }
    this.clickLike = currentUserInLikeArr;
  }

  build() {
    if (this.showInteraction) {
      Scroll() {
        Column() {
          this.showFeedBasic()
          this.buildFeedInteraction()
        }
      }.backgroundColor(Color.White).borderRadius(16).width('92%').scrollBar(BarState.Off)
    } else {
      Column() {
        this.showFeedBasic()
      }.backgroundColor(Color.White).borderRadius(16).width('92%')
    }
  }

  @Builder
  showFeedBasic() {
    if (this.showUserInfo) {
      this.buildFeedUserRow();
    }
    this.buildFeedMsg()
    this.buildFeedImg()
    this.buildFeedInteractionSummary()
  }

  @Builder
  buildFeedInteraction() {
    Column() {
      Column() {
        if (this.hasLikes()) {
          Row() {
            if (this.needShowNickNameExpand) {
              Text() {
                Span(this.likedNickNames)
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('app.color.place_holder_text_color'))
                  .fontFamily(Constants.HARMONY_HEITI)
                  .fontWeight(FontWeight.Regular)
                  .margin({ right: 16 })
                Span(this.likedNickNamesExpandFlag ? ' 收起' : ' 展开')
                  .fontColor('#FF0A59F7')
                  .backgroundColor(Color.Transparent)
                  .fontSize($r('sys.float.Body_S'))
                  .fontFamily(Constants.HARMONY_HEITI)
                  .fontWeight(FontWeight.Regular)
                  .onClick(() => {
                    //如果之前展开标志是false，说明之前未展开，本次点击则构造全部点赞信息
                    if (!this.likedNickNamesExpandFlag) {
                      this.buildLikedNickNamesAll();
                    } else {
                      this.buildLikedNickNamesPart();
                    }
                    this.likedNickNamesExpandFlag = !this.likedNickNamesExpandFlag;
                  })
              }.copyOption(CopyOptions.LocalDevice)
            } else {
              Text(this.likedNickNames)
                .copyOption(CopyOptions.LocalDevice)
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('app.color.place_holder_text_color'))
                .fontFamily(Constants.HARMONY_HEITI)
                .fontWeight(FontWeight.Regular)
            }
          }
          .width('92%')
          .margin({ bottom: this.hasComments() ? 4 : 12 })
          .alignSelf(ItemAlign.Start)
          .onAreaChange((oldArea, newArea) => {
            this.feedLikesHeight = parseInt(newArea.height.toString())
          })
        }
        if (this.hasComments()) {
          Column() {
            Blank().height(6)
            ForEach(this.comments, (comment: Comment, index: number) => {
              Row() {
                Text() {
                  Span(comment.nickName).margin({ left: 12 }).fontColor($r('app.color.button_background_color'))
                  if (comment.commentType != null && comment.commentType === Constants.COMMENT_TYPE_REPLY) {
                    Span('回复')
                    Span(comment.recipientNickName).fontColor($r('app.color.button_background_color'))
                  }
                  Span(': ')
                  Span(comment.content)
                }
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('app.color.text_font_color_black'))
                .copyOption(CopyOptions.InApp)
                .margin({ left: 12, right: 12 })
                .textAlign(TextAlign.Start)
              }
              .margin({ top: 8, bottom: 8 })
              .width('100%')
              .onClick(() => {
                this.replyComment = !this.replyComment;
                this.theCommentToReply = comment;
              })
              .enabled(this.currentUser != null && this.currentUser.isVip === Constants.YES)
            }, (comment: Comment, index: number) => comment.commentId?.toString())
            Blank().height(6)
          }
          .onAreaChange((oldArea, newArea) => {
            this.feedCommentsHeight = parseInt(newArea.height.toString())
          })
          .backgroundColor($r('app.color.page_background_color'))
          .width('92%')
          .margin({ bottom: 16, top: 4 })
          .borderRadius(8)
          .bindSheet($$this.replyComment,
            this.CommentSheetBuilder(this.theCommentToReply, this.item, this.currentUser),
            {
              showClose: false,
              dragBar: false,
              preferType: SheetType.BOTTOM,
              backgroundColor: '#FFDEE0E6',
              height: this.commentSheetHeight
            })
        }
        // 当需要遮挡，且有点赞或评论时，如果点赞或评论的高度不到遮蔽区的高度，那么加一个Blank，保证遮蔽区能正常显示
        if (this.blurRadius !== 0 && (this.hasComments() || this.hasLikes()) &&
          this.feedLikesHeight + this.feedCommentsHeight < FEED_INTERACTION_MASK_HEIGHT) {
          Blank().height(FEED_INTERACTION_MASK_HEIGHT - this.feedLikesHeight - this.feedCommentsHeight);
        }
      }.blur(this.blurRadius)
    }
    .overlay(this.FeedInteractionDetailMask(this.pageStack), { align: Alignment.Start })
    .align(Alignment.TopStart)
  }

  @Builder
  FeedInteractionDetailMask(pageStack: NavPathStack | null): CustomBuilder {
    Column() {
      if (!this.isCurrentUserVip() && (this.hasComments() || this.hasLikes())) {
        Blank().height(32)
        Row() {
          Column() {
            Image($r('app.media.img_member_guide')).width(101).height(96)
          }.width(101)

          Column() {
            Text('开通会员后，就可以任意查看点赞的人和评论咯～')
              .fontSize($r('sys.float.Body_S'))
              .width('100%')
              .textAlign(TextAlign.Start)
              .fontFamily(Constants.HARMONY_HEITI)
              .fontColor($r('app.color.text_font_color_black'))
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 14 })
            Button('开通会员查看')
              .backgroundColor($r('app.color.button_background_color'))
              .fontSize($r('sys.float.Body_S'))
              .width('100%')
              .fontColor($r('sys.color.font_on_primary'))
              .fontColor($r('app.color.text_font_color_black'))
              .fontWeight(FontWeight.Regular)
              .onClick(() => {
                if (pageStack != null) {
                  pageStack.pushPathByName('Member', null, (popInfo: PopInfo) => {
                    let basicUserInfo = popInfo.result as BasicUserInfo;
                    if (this.currentUser != null) {
                      Logger.debug('subscribe membership, currentUser=' + JSON.stringify(basicUserInfo))
                      this.currentUser.isVip = basicUserInfo.isVip;
                      if (this.isCurrentUserVip()) {
                        this.blurRadius = 0;
                      }
                    }
                  });
                }
              })
          }.width('60%')
        }.justifyContent(FlexAlign.Start).width('92%')
      }
    }.height(this.isCurrentUserVip() || (!this.hasComments() && !this.hasLikes()) ? 0 : FEED_INTERACTION_MASK_HEIGHT)
    .onClick(() => {
      Logger.debug('mask column clicked')
    })
  }

  @Builder
  buildFeedInteractionSummary() {
    Column() {
      Row() {
        this.buildFeedTime();
      }.width('92%').justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center).margin({ top: 6, bottom: 12 })

      Divider().strokeWidth(1).width('92%').color('#E5E5E5')
      Row() {
        this.buildLikeSummary()
        this.buildMsgSummary()
      }.width('92%').justifyContent(FlexAlign.End).alignItems(VerticalAlign.Center).margin({ top: 12, bottom: 16 })
    }
  }

  @Builder
  buildFeedTime() {
    Row() {
      if (this.item != null) {
        Text(DateUtils.formatDateToMinutes(new Date(this.item.creationDate)))
          .fontSize($r('sys.float.Body_S'))
          .textAlign(TextAlign.Start)
          .fontColor($r('app.color.text_font_color_gray'))
          .fontFamily(Constants.HARMONY_HEITI)
      }
    }
  }

  @Builder
  buildMsgSummary() {
    Row() {
      if (this.item != null) {
        Image($r('app.media.message'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Fill)
          .margin({ right: 2 })
          .onClick(() => {
            //只有详情页才允许发表评论，所以判断showInteraction为true时才弹出半模态弹窗
            if (this.showInteraction) {
              this.showCommentSheet = !this.showCommentSheet;
            }
          })
          .bindSheet($$this.showCommentSheet,
            this.CommentSheetBuilder(null, this.item, this.currentUser),
            {
              showClose: false,
              dragBar: false,
              preferType: SheetType.BOTTOM,
              backgroundColor: '#FFDEE0E6',
              height: this.commentSheetHeight
            });

        this.showInteractionCount(InteractionCountType.Comment)
      }
    }.width(60)
  }

  @Builder
  showInteractionCount(type: InteractionCountType) {
    Text(this.getInteractionCount(type))
      .width(42)
      .fontSize($r('sys.float.Body_S'))
      .fontColor(this.clickLike && type === InteractionCountType.Like ? $r('app.color.button_background_color') :
      $r('app.color.text_font_color_gray'))
      .textAlign(TextAlign.JUSTIFY)
      .onClick(() => {
        if (this.currentPageType === Constants.FEED_PAGE_TYPE_LIST) {
          this.pageStack?.pushPathByName('FeedDetail',
            new FeedDetailPageRouteParam(this.item, this.showFollowButton, null, this.currentUser), (pop: PopInfo) => {
              Logger.debug('FeedListPage interactionCount on FeedDetail pop, feed= ' + JSON.stringify(pop.result))
              this.item = JSON.parse(JSON.stringify(pop.result as Feed));
              this.setClickLike()
              this.buildLikedNickNamesPart();
              if (this.feedChange !== undefined) {
                this.feedChange();
              }
            });
        }
      })
  }

  getInteractionCount(type: InteractionCountType): string {
    if (type === InteractionCountType.Like) {
      if (this.hasLikes() && this.likes != null) {
        return this.likes.length.toString();
      }
      return '0';
    } else {
      if (this.hasComments() && this.comments != null) {
        return this.comments.length.toString();
      }
      return '0';
    }
  }

  @Builder
  buildLikeSummary() {
    Row() {
      if (this.item != null) {
        Image(this.clickLike ? $r('app.media.has_thumbup') : $r('app.media.thumbup'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Fill)
          .onClick(() => {
            let likeOperType = LikeOperType.DoLike;
            // 如果本次点击前clickLike是true，即之前已经点过赞，那么本次点击为取消点赞；否则本次点击为点赞操作
            if (this.clickLike) {
              likeOperType = LikeOperType.CancelLike;
            }
            this.clickLike = !this.clickLike;
            LikeService.likeFeed(this.currentUser?.uid, this.item?.feedId, likeOperType)
              .then((data: CommonRsp | null) => {
                if (this.item != null && this.item.feedId != null) {
                  FeedService.getFeedDetail(this.item?.feedId).then((data: Feed | null) => {
                    if (data != null) {
                      this.item = data;
                      this.setClickLike();
                      this.buildLikedNickNamesPart();
                      if (this.feedChange !== undefined) {
                        this.feedChange();
                      }
                    }
                  });
                }
              });
          })
          .margin({ right: 2 });

        this.showInteractionCount(InteractionCountType.Like);
      }
    }.width(60)
  }

  @Builder
  buildFeedImg() {
    if (this.item?.resourceUrl) {
      Row() {
        showFeedImage(this.item.resourceUrl, Constants.FEED_IMAGE_SIZE);
      }
      .padding({ left: 12, right: 12 })
      .margin({ top: 6, bottom: 6 })
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .onClick(() => {
        if (this.currentPageType === Constants.FEED_PAGE_TYPE_LIST) {
          this.pageStack?.pushPathByName('FeedDetail',
            new FeedDetailPageRouteParam(this.item, this.showFollowButton, null, this.currentUser), (pop: PopInfo) => {
              Logger.debug('FeedListPage interactionCount on FeedDetail pop, feed= ' + JSON.stringify(pop.result))
              if (pop.result != null) {
                this.item = JSON.parse(JSON.stringify(pop.result as Feed));
                this.setClickLike()
                this.buildLikedNickNamesPart();
                if (this.feedChange !== undefined) {
                  this.feedChange();
                }
              }
            });
        }
      })
    }
  }

  @Builder
  buildFeedMsg() {
    if (this.item?.feedMsg) {
      Row() {
        Text(this.item.feedMsg)
          .fontSize($r('sys.float.Body_M'))
          .fontFamily(Constants.HARMONY_HEITI)
          .fontColor($r('app.color.text_font_color_black'))
          .onAreaChange((oldArea, newArea) => {
            this.feedMsgMeasuredHeight = newArea.height
          })
      }
      .padding({ left: 12, right: 12 })
      .width('100%')
      .margin({ top: 12, bottom: 6 })
    }
  }

  @Builder
  buildFeedUserRow() {
    Row() {
      Row() {
        Column() {
          Image(this.item?.profilePictureUrl == null ? $r('app.media.head_image_default') :
            (this.item.profilePictureUrl.startsWith('app.media') ? $r(this.item.profilePictureUrl) :
            this.item.profilePictureUrl))
            .width(72)
            .height(72)
            .clipShape(new Circle({ width: '72', height: '72' }))
            .objectFit(ImageFit.Cover)
        }.width(72).alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.Start)

        Column() {
          Row() {
            Text(this.item?.nickName).fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_font_color_black')).margin({ right: 12 })
          }.margin({ left: 12, bottom: 8 }).justifyContent(FlexAlign.Start)

          Row() {
            Text('ID: ' + this.item?.userNo)
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('app.color.text_font_color_black'))
              .textAlign(TextAlign.Start).margin({ right: 12 })
            if (this.item?.realNameAuthFlag != null && this.item.realNameAuthFlag === Constants.YES) {
              buildRealNameLabelForList('已实名', $r('app.color.user_realname_auth_bg'))
            } else {
              buildRealNameLabelForList('未实名', $r('app.color.user_realname_un_auth_bg'))
            }
          }.margin({ left: 12 }).justifyContent(FlexAlign.Start)
        }.alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.Start)
      }

      Column() {
        if (this.currentUser?.uid !== this.item?.uid) {
          Button(this.showFollowButton ? '+关注' : '已关注')
            .backgroundColor(this.showFollowButton ? $r('app.color.light_grey_bg') :
            $r('app.color.button_background_color'))
            .fontColor(this.showFollowButton ? $r('app.color.text_font_color_black') : Color.White)
            .fontSize($r('sys.float.Body_M'))
            .fontFamily(Constants.HARMONY_HEITI)
            .fontWeight(FontWeight.Regular)
            .height(32)
            .width(76)
            .onClick(() => {
              if (this.item != null && this.item.uid != null && this.currentUser != null &&
                this.currentUser.uid != null) {
                if (this.showFollowButton) {
                  FeedService.followUser(this.item.uid, this.currentUser.uid, FollowType.Follow)
                    .then((data: CommonRsp | null) => {
                      this.afterFollowProcess(data);
                    })
                } else {
                  FeedService.followUser(this.item.uid, this.currentUser.uid, FollowType.UnFollow)
                    .then((data: CommonRsp | null) => {
                      this.afterFollowProcess(data);
                    });
                }
              }
              this.showFollowButton = !this.showFollowButton;
            })
        }
      }
      .alignItems(HorizontalAlign.End)
      .width(76)
    }
    .height(72)
    .padding({ left: 12, right: 12 })
    .margin({ top: 12, bottom: 8 })
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  private afterFollowProcess(data: CommonRsp | null) {
    if (data != null && data.retCode === Constants.RET_SUCCESS_CODE &&
      this.feedChange !== undefined) {
      this.feedChange();
    }
  }

  @Builder
  CommentSheetBuilder(theCommentToReply: Comment | null, feed: Feed | null,
    currentUser: BasicUserInfo | null): CustomBuilder {
    Row() {
      TextArea({
        text: this.newCommentTxt,
        placeholder: theCommentToReply == null ? '发表评论：' : '回复' + theCommentToReply.nickName,
      })
        .defaultFocus(true)
        .width('83%')
        .caretColor($r('sys.color.font_emphasize'))
        .placeholderFont({ size: 14, family: Constants.HARMONY_HEITI })
        .placeholderColor($r('sys.color.font_secondary'))
        .borderRadius(8)
        .maxLines(Constants.COMMENT_MAX_LINES)
        .maxLength(Constants.COMMENT_MAX_LENGTH)
        .fontSize($r('sys.float.Body_M'))
        .fontColor(Color.Black)
        .backgroundColor('#FFFFFF')
        .onAreaChange((oldArea, newArea) => {
          this.calcCommentSheetHeight(newArea, oldArea);
        })
        .onChange((value: string) => {
          this.newCommentTxt = value
        })
        .margin({ left: 16 })

      Image(CommonUtils.isBlank(this.newCommentTxt) ? $r('app.media.ic_public_paperplane_gray') :
      $r('app.media.ic_public_paperplane'))
        .width(24)
        .height(24)
        .margin({ left: 12, right: 16 })
        .enabled(!CommonUtils.isBlank(this.newCommentTxt))
        .onClick(() => {
          Logger.debug('comment=' + this.newCommentTxt)
          if (this.item != null && currentUser != null) {
            CommentService.createComment(currentUser.uid, this.item.feedId, this.newCommentTxt,
              theCommentToReply)
              .then((data: CommonRsp | null) => {
                if (this.theCommentToReply != null) {
                  this.replyComment = !this.replyComment;
                  // theCommentToReply置空，否则影响下次判断
                  this.theCommentToReply = null;
                } else {
                  this.showCommentSheet = !this.showCommentSheet;
                }
                if (this.item?.feedId != null) {
                  FeedService.getFeedDetail(this.item.feedId).then((res: Feed | null) => {
                    if (res != null) {
                      this.item = res;
                      this.comments = this.item.comments;
                      if (this.feedChange !== undefined) {
                        this.feedChange();
                      }
                    }
                  })
                }
              })
          }
          this.newCommentTxt = '';
        });
    }.margin({ top: 16 })
  }

  private calcCommentSheetHeight(newArea: Area, oldArea: Area) {
    let newHeight = parseInt(newArea.height.toString());
    let oldHeight = parseInt(oldArea.height.toString());
    if (oldHeight === 0) {
      this.commentSheetHeight = Constants.COMMENT_SHEET_HEIGHT_DEFAULT;
    } else {
      this.commentSheetHeight += (newHeight - oldHeight);
      if (this.commentSheetHeight < Constants.COMMENT_SHEET_HEIGHT_DEFAULT) {
        this.commentSheetHeight = Constants.COMMENT_SHEET_HEIGHT_DEFAULT;
      }
    }
  }

  private hasComments(): boolean {
    if (this.item == null || this.comments == null) {
      return false;
    }
    return this.comments.length !== undefined && this.comments.length > 0;
  }

  private hasLikes(): boolean {
    if (this.item == null || this.likes == null) {
      return false;
    }
    return this.likes.length !== undefined && this.likes.length > 0;
  }

  buildLikedNickNamesAll() {
    if (this.likes == null) {
      this.likedNickNames = '';
      return;
    }
    let likedNickNames: string = '';
    for (let i = 0; i < this.likes.length - 1; i += 1) {
      likedNickNames += this.likes[i].nickName;
      likedNickNames += Constants.CHINESE_PAUSE_MARK;
    }
    likedNickNames += this.likes[this.likes.length-1].nickName;
    if (this.likes.length > 3) {
      likedNickNames += '等' + this.likes.length + '人'
    }
    likedNickNames += '点赞了';
    this.likedNickNames = likedNickNames;
  }

  buildLikedNickNamesPart() {
    Logger.debug('this.likes=' + JSON.stringify(this.likes))
    let likedNickNames: string = '';
    if (this.likes != null) {
      for (let i = 0; i < this.likes.length; i += 1) {
        likedNickNames += this.likes[i].nickName;
        if (i > 3 && likedNickNames.length > Constants.DEFAULT_SHOW_LIKE_TEXT_LEN) {
          this.needShowNickNameExpand = true;
          break;
        }
        likedNickNames += Constants.CHINESE_PAUSE_MARK;
      }
      likedNickNames = likedNickNames.substring(0, likedNickNames.length - 1)
      if (this.likes.length > 3) {
        likedNickNames += '等' + this.likes.length + '人';
      }
      likedNickNames += '点赞了';
    }
    this.likedNickNames = likedNickNames;
  }
}

enum InteractionCountType {
  Like,
  Comment
}

@Builder
export function emptyActionPageContent(tabContent: string[], pageStack: NavPathStack, callback?: () => void) {
  Column() {
    Row() {
      Image($r(tabContent[5])).width(120).height(120).objectFit(ImageFit.Auto);
    }.justifyContent(FlexAlign.Center).height(150);

    Row() {
      Text(tabContent[1]).fontSize($r('sys.float.Body_M'))
        .fontFamily(Constants.HARMONY_HEITI)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('app.color.text_font_color_medium_gray'))
    }.margin({ top: 4 });

    Row() {
      Text(tabContent[2]).fontSize($r('sys.float.Body_M'))
        .fontFamily(Constants.HARMONY_HEITI)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('app.color.text_font_color_medium_gray'))
    }.align(Alignment.Center).margin({ bottom: 16 });

    if (!CommonUtils.isBlank(tabContent[3]) && !CommonUtils.isBlank(tabContent[4])) {
      Row() {
        Button(tabContent[3])
          .backgroundColor($r('app.color.button_background_color'))
          .width('92%')
          .fontSize($r('sys.float.Body_L'))
          .fontFamily(Constants.HARMONY_HEITI)
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            pageStack.pushPathByName(tabContent[4], null, (pop: PopInfo) => {
              Logger.info('emptyActionPageContent, page ' + tabContent[4] + ' returned')
              if (callback !== undefined) {
                callback();
              }
            })
          });
      };
    }

    Blank().height(271);
  }
}


@Component
export struct GridShowImage {
  @Prop resourceUrl: string[];
  @State rowTemplate: string | null = null;
  @State columnTemplate: string | null = null;
  @State gridHeight: number | null = null;
  @State gridItemHeight: number | null = null;

  build() {
    Grid() {
      ForEach(this.resourceUrl, (imageResource: string, index: number) => {
        GridItem() {
          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            if (imageResource.startsWith('app.media')) {
              Image($r(imageResource))
                .borderRadius(8)
                .width(this.gridItemHeight)
                .height(this.gridItemHeight)
                .objectFit(ImageFit.Cover)
            } else {
              Image(imageResource)
                .borderRadius(8)
                .width(this.gridItemHeight)
                .height(this.gridItemHeight)
                .objectFit(ImageFit.Cover)
            }
          }
        }
      }, (imageResource: string) => imageResource);
    }
    .width('100%')
    .rowsTemplate(this.rowTemplate)
    .columnsTemplate(this.columnTemplate)
    .height(this.gridHeight)
  }
}