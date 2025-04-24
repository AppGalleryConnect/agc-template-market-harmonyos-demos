import { FeedListPageRouteParam } from 'feed';
import { QueryEnrolledActivitiesResponse } from 'activity';
import { MemberPageParam } from 'member';
import {
  GetUserResponse,
  UserFullInfo,
  MateSelectionCriteria,
  UserInfo,
  UserActionSummary,
  QueryFeedResponse,
  BasicUserInfo,
  CommonUtils,
  Constants,
  QueryFeedType,
  QueryFollowUserType
} from 'commons';
import Logger from 'commons/src/main/ets/utils/Logger';
import UserService from 'user/src/main/ets/service/UserService';
import FeedService from 'feed/src/main/ets/service/FeedService';
import ActivityService from 'activity/src/main/ets/service/ActivityService';
import { ActionSummaryPageParam, ActionSummaryPageType } from '../model/ActionSummaryPageParam';

@Builder
export function PersonalPageBuilder() {
  Personal()
}

@Component
export struct Personal {
  @Consume('pageStack') pageStack: NavPathStack;
  @State userFullInfo: UserFullInfo | null = null;
  @State userInfo: UserInfo | null = null;
  @State userActionSummary: UserActionSummary = new UserActionSummary();
  @Prop @Watch('onChange') index: number = 0;

  onChange() {
    if (this.index === Constants.PAGE_INDEX_PERSONAL) {
      this.getUserInfo();
    }
  }

  build() {
    NavDestination() {
      Column() {
        this.buildBasicInfo()
        this.buildActionHistoryArea()
        this.buildMemberArea()
        Column() {
          this.buildMyMateCriteria()
          Divider().strokeWidth('1px').width('92%')
          this.buildMyFeedRow()
          Divider().strokeWidth('1px').width('92%')
          this.buildMyOrderRow()
          Divider().strokeWidth('1px').width('92%')
          this.buildConfigRow()
        }.width('92%').backgroundColor(Color.White).borderRadius(16)
      }
    }.hideTitleBar(true).backgroundColor($r('app.color.page_background_color'))
  }

  @Builder
  buildBasicInfo() {
    Row() {
      Row() {
        Column() {
          Image(this.userInfo?.profilePictureUrl == null ? $r('app.media.head_image_default') :
            (this.userInfo?.profilePictureUrl.startsWith('app.media') ?
            $r(this.userInfo?.profilePictureUrl) : this.userInfo?.profilePictureUrl))
            .width(72)
            .height(72)
            .clipShape(new Circle({ width: '72', height: '72' }))
            .objectFit(ImageFit.Cover)
            .margin({ left: '5vp', top: '5vp' })
            .borderRadius(16)
        }.overlay(this.EditIconBuilder(), { align: Alignment.BottomEnd })

        Column() {
          Text(this.userInfo?.nickName)
            .fontSize($r('sys.float.Body_M')).fontWeight(FontWeight.Medium).fontFamily(Constants.HARMONY_HEITI)
            .margin({ left: '16vp', right: '5vp', bottom: '5vp' })
          Text('ID: ' + this.userInfo?.userNo)
            .margin({ left: '16vp', right: '5vp', bottom: '5vp' })
            .fontSize($r('sys.float.Body_S')).fontFamily(Constants.HARMONY_HEITI)
        }.alignItems(HorizontalAlign.Start)
      }

      Column() {
        if (this.userInfo?.realNameAuthFlag == null ||
          this.userInfo?.realNameAuthFlag === Constants.REAL_NAME_AUTH_NO) {
          Button('去实名')
            .backgroundColor($r('app.color.light_grey_bg'))
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_M'))
            .fontFamily(Constants.HARMONY_HEITI)
            .width(80)
            .height(40)
            .borderRadius('20vp')
            .onClick(() => {
              this.pageStack.pushPathByName('RealNameAuthPage', null, (pop: PopInfo) => {
                this.refreshUserInfo(pop);
              });
            })
        } else {
          Text('已实名')
            .backgroundColor($r('app.color.user_realname_auth_bg'))
            .borderRadius(16)
            .fontFamily(Constants.HARMONY_HEITI)
            .width(60)
            .height(36)
            .fontSize($r('sys.float.Body_M'))
            .textAlign(TextAlign.Center)
        }
      }
    }.onClick(() => {
      this.pageStack.pushPathByName('MyDetailPage', null, (popInfo: PopInfo) => {
        this.userFullInfo = popInfo.result as UserFullInfo;
        this.userInfo = this.userFullInfo.userInfo;
      });
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .width('92%').margin({ bottom: 12 })
  }

  private refreshUserInfo(pop: PopInfo) {
    if (pop != null) {
      let userInfoTmp = pop.result as UserInfo;
      if (userInfoTmp != null) {
        this.userInfo = userInfoTmp;
      }
    }
  }

  @Builder
  buildActionHistoryArea() {
    Row() {
      Column() {
        Row() {
          Text('关注')
            .margin({ right: 4 })
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('app.color.text_font_color_black'))
            .fontFamily(Constants.HARMONY_HEITI)
            .fontWeight(FontWeight.Regular)
          Text(CommonUtils.transCount(this.userActionSummary.followUserCount))
            .fontWeight(500)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('app.color.text_font_color_black'))
            .fontFamily(Constants.HARMONY_HEITI)
            .fontWeight(FontWeight.Regular)
        }
      }.width('21%').onClick(() => {
        if (this.userActionSummary.followUserCount === 0) {
          this.pageStack.pushPathByName('ActionSummaryPage',
            new ActionSummaryPageParam(Constants.EMPTY_FOLLOW_PAGE_TAB1, Constants.EMPTY_FOLLOW_PAGE_TAB2,
              ActionSummaryPageType.FollowUser, null, null), () => {
              this.getUserInfo();
            });
        } else {
          if (this.userFullInfo != null && this.userFullInfo.userInfo != null &&
            this.userFullInfo.userInfo.uid != null) {
            UserService.queryFollowedUser(this.userFullInfo.userInfo.uid, QueryFollowUserType.QUERY_FOLLOWED_BY_ME)
              .then((data: UserFullInfo[]) => {
                this.pageStack.pushPathByName('ActionSummaryPage',
                  new ActionSummaryPageParam(Constants.EMPTY_FOLLOW_PAGE_TAB1, Constants.EMPTY_FOLLOW_PAGE_TAB2,
                    ActionSummaryPageType.FollowUser, data, null), () => {
                    this.getUserInfo();
                  })
              })
          }
        }
      })

      Column() {
        Row() {
          Text('赞过')
            .margin({ right: 4 })
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('app.color.text_font_color_black'))
            .fontFamily(Constants.HARMONY_HEITI)
            .fontWeight(FontWeight.Regular)
          Text(CommonUtils.transCount(this.userActionSummary.likedCount))
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('app.color.text_font_color_black'))
            .fontFamily(Constants.HARMONY_HEITI)
            .fontWeight(FontWeight.Regular)
        }
      }.width('21%').onClick(() => {
        if (this.userActionSummary.likedCount === 0) {
          this.pageStack.pushPathByName('ActionSummaryPage',
            new ActionSummaryPageParam(Constants.EMPTY_LIKE_PAGE_TAB1, Constants.EMPTY_LIKE_PAGE_TAB2,
              ActionSummaryPageType.Like, null, null), () => {
              this.getUserInfo();
            });
        } else {
          if (this.userFullInfo != null && this.userFullInfo.userInfo != null &&
            this.userFullInfo.userInfo.uid != null) {
            FeedService.getFeedList(QueryFeedType.QUERY_MY_LIKE.toString(), this.userFullInfo.userInfo.uid)
              .then((data: QueryFeedResponse | null) => {
                this.pageStack.pushPathByName('ActionSummaryPage',
                  new ActionSummaryPageParam(Constants.EMPTY_LIKE_PAGE_TAB1, Constants.EMPTY_LIKE_PAGE_TAB2,
                    ActionSummaryPageType.Like, null, data?.list), () => {
                    this.getUserInfo();
                  });
              })
          }
        }
      })

      Column() {
        Row() {
          Text('评论')
            .margin({ right: 4 })
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('app.color.text_font_color_black'))
            .fontFamily(Constants.HARMONY_HEITI)
            .fontWeight(FontWeight.Regular)
          Text(CommonUtils.transCount(this.userActionSummary.commentCount))
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('app.color.text_font_color_black'))
            .fontFamily(Constants.HARMONY_HEITI)
            .fontWeight(FontWeight.Regular)
        }
      }.width('21%').align(Alignment.Start).onClick(() => {
        if (this.userActionSummary.commentCount === 0) {
          this.pageStack.pushPathByName('ActionSummaryPage',
            new ActionSummaryPageParam(Constants.EMPTY_COMMENT_PAGE_TAB1, Constants.EMPTY_COMMENT_PAGE_TAB2,
              ActionSummaryPageType.Comment, null, null), () => {
              this.getUserInfo();
            });
        } else {
          if (this.userFullInfo != null && this.userFullInfo.userInfo != null &&
            this.userFullInfo.userInfo.uid != null) {
            FeedService.getFeedList(QueryFeedType.QUERY_MY_COMMENTED.toString())
              .then((data: QueryFeedResponse | null) => {
                this.pageStack.pushPathByName('ActionSummaryPage',
                  new ActionSummaryPageParam(Constants.EMPTY_COMMENT_PAGE_TAB1, Constants.EMPTY_COMMENT_PAGE_TAB2,
                    ActionSummaryPageType.Comment, null, data?.list), () => {
                    this.getUserInfo();
                  });
              })
          }
        }
      })
    }.width('92%').margin({ bottom: 12 })
  }

  @Builder
  buildMemberArea() {
    Column() {
      Row() {
        Column() {
          Text('开通会员即可使用更多功能')
            .fontSize($r('sys.float.Body_M'))
            .margin({ left: 12 })
            .fontFamily(Constants.HARMONY_HEITI)
            .fontWeight(FontWeight.Regular)
            .fontColor(Color.White)
            .textAlign(TextAlign.Start)
            .width('100%')
        }.width('70%').alignItems(HorizontalAlign.Start)

        Column() {
          Button(this.isVip() ? '去续费' : '开通')
            .backgroundColor($r('app.color.button_background_color'))
            .fontSize($r('sys.float.Body_M'))
            .width(76)
            .height(32)
            .margin({ left: 12, right: 12 })
            .onClick(() => {
              this.pageStack.pushPathByName('Member', new MemberPageParam(this.isVip()), (popInfo: PopInfo) => {
                let basicUserInfo = popInfo.result as BasicUserInfo;
                Logger.debug('userInfo after member=' + JSON.stringify(basicUserInfo))
                if (basicUserInfo != null && this.userFullInfo != null && this.userFullInfo.userInfo != null) {
                  this.userInfo = this.userFullInfo.userInfo;
                }
              });
            })
        }.width('30%').alignItems(HorizontalAlign.End)
      }
      .width('92%')
      .height(50)
      .backgroundImage($r('app.media.member_search'))
      .backgroundImageSize(ImageSize.FILL)
      .margin({ bottom: 12 })
    }
  }

  private isVip(): boolean {
    return this.userInfo != null && this.userInfo.isVip != null && this.userInfo.isVip === Constants.YES;
  }

  @Builder
  buildMyMateCriteria() {
    Row() {
      Image($r('app.media.icon_mate_criteria')).width(24).height(24).margin(12)

      Text('择偶标准')
        .fontSize($r('sys.float.Body_M')).width('75%').textAlign(TextAlign.Start).margin({ top: 12, bottom: 12 })

      Image($r('app.media.ic_right_arrow'))
        .width(24)
        .height(24)
        .margin({ left: 12, right: 12 })
        .objectFit(ImageFit.Fill)
    }.width('100%').height(48).alignItems(VerticalAlign.Center).onClick(() => {
      this.pageStack.pushPathByName('MateCriteriaPage', this.userFullInfo, (popInfo: PopInfo) => {
        Logger.debug('------popResult=' + JSON.stringify(popInfo.result))
        if (this.userFullInfo != null) {
          this.userFullInfo.mateSelectionCriteria = JSON.parse(JSON.stringify(popInfo.result as MateSelectionCriteria));
        }
      });
    });
  }

  @Builder
  buildMyFeedRow() {
    Row() {
      Image($r('app.media.icon_my_feed')).width(24).height(24).margin(12)

      Text('我的动态')
        .fontSize($r('sys.float.Body_M')).width('75%').textAlign(TextAlign.Start).margin({ top: 12, bottom: 12 })

      Image($r('app.media.ic_right_arrow'))
        .width(24)
        .height(24)
        .margin({ left: 12, right: 12 })
        .objectFit(ImageFit.Fill)
    }.width('100%').height(48).alignItems(VerticalAlign.Center).onClick(() => {
      if (this.userFullInfo != null && this.userFullInfo.userInfo != null &&
        this.userFullInfo.userInfo.uid != null) {
        let currentUser: BasicUserInfo = UserInfo.toBasicUserInfo(this.userFullInfo.userInfo);
        // 我的动态，所以查询时传入了2个currentUser
        this.pageStack.pushPathByName('FeedList',
          new FeedListPageRouteParam(QueryFeedType.QUERY_BY_USER, currentUser, currentUser, '我的动态'),
          (popInfo: PopInfo) => {
            this.getUserInfo();
          });
      }
    });
  }

  @Builder
  buildMyOrderRow() {
    Row() {
      Image($r('app.media.icon_my_order')).width(24).height(24).margin(12)
      Text('我的订单')
        .fontSize($r('sys.float.Body_M')).width('75%').textAlign(TextAlign.Start).margin({ top: 12, bottom: 12 })

      Image($r('app.media.ic_right_arrow'))
        .width(24)
        .height(24)
        .objectFit(ImageFit.Fill)
        .margin({ left: 12, right: 16 })

    }.width('100%').height(48).alignItems(VerticalAlign.Center).onClick(() => {
      if (this.userFullInfo != null && this.userFullInfo.userInfo != null &&
        this.userFullInfo.userInfo.uid != null) {
        ActivityService.queryEnrolledActivities(this.userFullInfo.userInfo.uid)
          .then((data: QueryEnrolledActivitiesResponse | null) => {
            if (data != null) {
              this.pageStack.pushPathByName('MyActivitiesPage', data.list);
            }
          })
      }
    })
  }

  @Builder
  buildConfigRow() {
    Row() {
      Image($r('app.media.icon_config')).width(24).height(24).margin(12)
      Text('设置')
        .fontSize($r('sys.float.Body_M')).width('75%').textAlign(TextAlign.Start).margin({ top: 12, bottom: 12 })

      Image($r('app.media.ic_right_arrow'))
        .width(24)
        .height(24)
        .objectFit(ImageFit.Fill)
        .margin({ left: 12, right: 12 })

    }.width('100%').height(48).alignItems(VerticalAlign.Center).onClick(() => {
      this.pageStack.pushPathByName('ConfigPage', null, () => {
        Logger.debug('PersonalPage, onConfigPagePop');
        let newRegisterFlag: boolean | null | undefined = AppStorage.get(Constants.NEW_REGISTER_FLAG);
        if (newRegisterFlag != null && newRegisterFlag !== undefined && newRegisterFlag) {
          Logger.debug('PersonalPage, newRegisterFlag is true')
          this.getUserInfo();
          Logger.debug('PersonalPage pageStack=' + JSON.stringify(this.pageStack))
        }
      })
    });
  }

  aboutToAppear(): void {
    this.getUserInfo();
  }

  private getUserInfo() {
    let unionId: string | undefined = AppStorage.get(Constants.UNION_ID);
    UserService.getUserFullInfoByUnionId(unionId).then((data: GetUserResponse | null) => {
      if (data != null && data.userFullInfo != null) {
        this.userFullInfo = data.userFullInfo;
        if (data.userFullInfo.userInfo != null) {
          this.userInfo = data.userFullInfo.userInfo;
        }
        if (this.userFullInfo.userActionSummary != null) {
          this.userActionSummary = this.userFullInfo.userActionSummary;
        }
      }
    });
  }

  @Builder
  EditIconBuilder(): CustomBuilder {
    Image($r('app.media.icon_edit_user')).width(20).height(20)
  }
}

