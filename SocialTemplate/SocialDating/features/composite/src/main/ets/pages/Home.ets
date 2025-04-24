import { ActivityInfo, QueryActivityResponse } from 'activity';
import {
  GetUserResponse,
  UserFullInfo,
  UserInfo,
  BasicUserInfo,
  Constants,
  DateUtils,
  QueryFeedType,
  UiUtils,
  FollowType
} from 'commons';
import { Matchmaker, contactMatchmakerBuilder, bindSheetTitleBuilder } from 'member';
import { FeedListPageRouteParam } from 'feed';
import { UserSelfIntro, UserLabels } from 'user';
import { GridShowImage } from 'feed';

import MatchMakerService from 'member/src/main/ets/service/MatchMakerService';
import FeedService from 'feed/src/main/ets/service/FeedService';
import Logger from 'commons/src/main/ets/utils/Logger';
import UserService from 'user/src/main/ets/service/UserService';
import ActivityService from 'activity/src/main/ets/service/ActivityService';

const HOME_OPER_DRAG_MIN_RIGHT = 20;
const HOME_OPER_DRAG_MAX_RIGHT = 320;
const HOME_OPER_DRAG_MIN_BOTTOM = 60;
const HOME_OPER_DRAG_MAX_BOTTOM = 500;
const MIN_UP_OFFSET = -300;

@Builder
export function HomePageBuilder() {
  Home()
}

@Component
export struct Home {
  @State currentIndex: number = 0
  @Consume('pageStack') pageStack: NavPathStack;
  @State selectedCity: string = '南京';
  private selectCityIdx: number = 0
  private activitiesScroller: Scroller = new Scroller();
  @State arr: Array<ActivityInfo> = [];
  @State selectedActivity: ActivityInfo | null = null;
  @State recommendUserFullInfo: UserFullInfo | null = null;
  @State followClicked: boolean = false;
  private userInfoScroller: Scroller = new Scroller();
  private recommendNumber = 1;
  private matchMaker: Matchmaker | null = null;
  @State ta: string = 'TA';
  @State currentUser: BasicUserInfo | null = null;
  @State isShowContactMatchmaker: boolean = false;
  @State operButtonsRight: number = 20;
  @State operButtonsBottom: number = 50;
  @State offsetRight: number = 20;
  @State offsetBottom: number = 50;
  @State userContentHeight: number = 0;
  @State userContainerHeight: number = 0;
  @State getNextFlag: boolean = false;
  @State getLastFlag: boolean = false;
  @Prop @Watch('onChange') index: number = 0;

  onChange() {
    if (this.index === Constants.PAGE_INDEX_HOME) {
      if (this.currentUser == null) {
        this.getCurrentUser()
      }
      let newRegisterFlag: boolean | null | undefined = AppStorage.get(Constants.NEW_REGISTER_FLAG);
      // 切页面到首页时，对于用户注销后又重新新注册的场景，需重新获取推荐用户；其他情况，需要刷新当前推荐用户的信息
      if (newRegisterFlag != null && newRegisterFlag !== undefined && newRegisterFlag) {
        this.getCurrentUser();
        this.recommendNumber = 1;
        this.getRecommendUser(this.recommendNumber);
      } else {
        if (this.recommendUserFullInfo != null && this.recommendUserFullInfo.userInfo != null) {
          UserService.getUserFullInfoByUnionId(this.recommendUserFullInfo.userInfo.hwUnionId)
            .then((data: GetUserResponse | null) => {
              if (data != null && data.userFullInfo != null && data.userFullInfo.userInfo != null) {
                this.followClicked = data.userFullInfo.userInfo.hasFollowed != null &&
                  data.userFullInfo.userInfo.hasFollowed === Constants.YES
              }
            })
        }
      }
    }
  }

  aboutToAppear(): void {
    this.getCurrentUser();
    if (this.currentUser != null) {
      this.getRecommendUser(this.recommendNumber);
    }
    MatchMakerService.queryMatchMaker().then((data: Matchmaker[]) => {
      this.matchMaker = data[0];
    })
  }

  private getCurrentUser() {
    let userBasicTmp: BasicUserInfo | null | undefined = AppStorage.get(Constants.CURRENT_USER_BASIC);
    if (userBasicTmp != null && userBasicTmp !== undefined) {
      this.currentUser = userBasicTmp;
    } else {
      UserService.getUserFullInfoByUnionId(AppStorage.get(Constants.UNION_ID)).then((data: GetUserResponse | null) => {
        if (data != null && data.userFullInfo != null && data.userFullInfo.userInfo != null) {
          this.currentUser = UserInfo.toBasicUserInfo(data.userFullInfo.userInfo)
        }
      })
    }
  }

  build() {
    NavDestination() {
      this.buildTabBarRow()

      Tabs({ barPosition: BarPosition.Start, index: this.currentIndex }) {
        TabContent() {
          this.recommendUser();
        }

        TabContent() {
          this.activityList();
        }
      }.barHeight(0)
      .onChange((index: number) => {
        this.currentIndex = index
        if (this.currentIndex === 1) {
          this.getActivities();
        }
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.page_background_color'))
  }

  @Builder
  buildTabBarRow() {
    Row() {
      Row() {
        if (this.currentIndex === 0) {
          Image($r('app.media.adjustment'))
            .width(24)
            .height(24)
            .onClick(() => {
              this.pageStack.pushPathByName('UserSearchPage', null);
            })
        } else {
          Blank().width(24).height(24)
        }
        Text('推荐')
          .fontColor(this.currentIndex === 0 ?
          $r('app.color.button_background_color') : $r('app.color.text_font_color_black'))
          .fontWeight(this.currentIndex === 0 ? FontWeight.Bold : FontWeight.Regular)
          .fontSize(18)
          .fontFamily(Constants.HARMONY_HEITI)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.currentIndex = 0;
          })
          .margin({ left: 80 })
      }.margin({ right: 24 })

      Row() {
        Text('活动')
          .fontColor(this.currentIndex === 1 ? $r('app.color.button_background_color') :
          $r('app.color.text_font_color_black'))
          .fontWeight(this.currentIndex === 1 ? FontWeight.Bold : FontWeight.Regular)
          .fontSize(18)
          .fontFamily(Constants.HARMONY_HEITI)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.currentIndex = 1;
          });
      }.margin({ left: 24, right: 120 })
    }.backgroundColor($r('app.color.page_background_color')).margin({ bottom: 16 })
  }

  @Builder
  buildRecommendTabBar() {
    Row() {
      if (this.currentIndex === 0) {
        Image($r('app.media.adjustment'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.pageStack.pushPathByName('UserSearchPage', null);
          })
      } else {
        Blank().width(24).height(24)
      }
      Text('推荐')
        .fontColor(this.currentIndex === 0 ?
        $r('app.color.button_background_color') : $r('app.color.title_font_color'))
        .fontWeight(this.currentIndex === 0 ? FontWeight.Bold : FontWeight.Regular)
        .fontSize(18)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.Center)
        .margin({ left: 80 })
        .onClick(() => {
          this.currentIndex = 0;
        })
    }
    .margin({ right: 24 })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  buildActivityTabBar() {
    Row() {
      Text('活动')
        .fontColor(this.currentIndex === 1 ? $r('app.color.button_background_color') :
        $r('app.color.title_font_color'))
        .fontWeight(this.currentIndex === 1 ? FontWeight.Bold : FontWeight.Regular)
        .fontSize(18)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.currentIndex = 1;
        });
    }
    .margin({ left: 24, right: 120 })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  activityList() {
    Column() {
      this.selectCity()
      this.scrollActivities()
    }.height('100%').justifyContent(FlexAlign.Start).align(Alignment.TopStart)
  }

  @Builder
  scrollActivities() {
    Scroll(this.activitiesScroller) {
      Column() {
        ForEach(getFutureActivities(this.arr), (item: ActivityInfo) => {
          this.ActivityImageButton(item)
        }, (item: ActivityInfo) => item.activityId.toString())
        if (getHistoryActivities(this.arr).length > 0) {
          Row() {
            Text('往期活动')
              .fontFamily(Constants.HARMONY_HEITI)
              .width(56)
              .height(20)
              .fontColor($r('app.color.title_font_color'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular);
          }.justifyContent(FlexAlign.Center)

          Divider().strokeWidth(1).margin({ top: 7, bottom: 16 }).width('92%');
          ForEach(getHistoryActivities(this.arr), (item: ActivityInfo) => {
            this.ActivityImageButton(item)
          }, (item: ActivityInfo) => item.activityId.toString())
        }
        Blank().height(50);
      }.width('100%')
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .scrollBarColor(Color.Gray)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  ActivityImageButton(item: ActivityInfo) {
    Image($r(item.resource0Url))
      .objectFit(ImageFit.Auto)
      .width('92%')
      .height(166)
      .margin({ bottom: '16vp' })
      .borderRadius(16)
      .overlay(this.ActivityInfo(item), { align: Alignment.TopStart })
      .onClick(() => {
        Logger.debug('getActivity data=' + JSON.stringify(item));
        this.pageStack.pushPathByName('ActivityDetail', item)
      })
  }

  @Builder
  ActivityInfo(item: ActivityInfo): CustomBuilder {
    Column() {
      Row() {
        Text(DateUtils.formatDateToMmDd(new Date(item.activityStartTime)))
          .fontSize(24)
          .fontColor(Color.White)
          .fontFamily(Constants.HARMONY_HEITI)
          .fontWeight(FontWeight.Medium)
      }.width('92%').margin({ top: 12, bottom: 4 }).justifyContent(FlexAlign.Start)

      Row() {
        Text(item.name + '-')
          .fontSize(24)
          .fontColor(Color.White)
          .fontFamily(Constants.HARMONY_HEITI)
          .fontWeight(FontWeight.Bold)
        Text(item.city + '专场')
          .fontSize(18)
          .fontColor(Color.White)
          .fontFamily(Constants.HARMONY_HEITI)
          .fontWeight(FontWeight.Medium)
      }.width('92%').margin({ bottom: 26 }).justifyContent(FlexAlign.Start)

      Row() {
        Column() {
          Row() {
            Text(item.subTitle)
              .fontSize(14)
              .fontColor(Color.White)
              .fontFamily(Constants.HARMONY_HEITI)
              .fontWeight(FontWeight.Medium)
          }.margin({ bottom: 2 })

          Row() {
            this.activityTextInfo(DateUtils.formatDateToDay(new Date(item.activityStartTime)) + '-' +
            DateUtils.formatDateToDay(new Date(item.activityEndTime)))
            this.activityTextInfo(item.city)
            this.activityTextInfo((item.activityUserNumber / 2) + '男' + (item.activityUserNumber / 2) + '女')
          }
        }.justifyContent(FlexAlign.Start).width('70%').alignItems(HorizontalAlign.Start).margin({ left: 12 })

        Column() {
          if (item.activityEndTime <= new Date().getTime()) {
            this.buildActivityTip('已结束')
          } else {
            if (item.activityEnrolledCount >= item.activityUserNumber) {
              this.buildActivityTip('已报满')
            } else {
              Image($r('app.media.ic_right_arrow')).width(24).height(24).backgroundColor('#E6FFFFFF')
                .clipShape(new Circle({ width: '24', height: '24' }))
            }
          }
        }.width('30%').justifyContent(FlexAlign.End).alignItems(HorizontalAlign.Center).margin({ right: 12 })
      }
      .borderRadius(16)
      .width('92%')
      .height(50)
      .backgroundColor('#33FE553C')
      .justifyContent(FlexAlign.Start)
    }
  }

  @Builder
  activityTextInfo(info: string) {
    Text(info)
      .fontSize(10)
      .fontColor(Color.White)
      .fontFamily(Constants.HARMONY_HEITI).margin({ right: 16 })
  }

  @Builder
  buildActivityTip(msg: string) {
    Text(msg)
      .fontSize($r('sys.float.Body_M'))
      .width(60)
      .height(24)
      .fontColor($r('app.color.title_font_color'))
      .fontFamily(Constants.HARMONY_HEITI)
      .fontWeight(FontWeight.Regular)
      .backgroundColor('#99FFFFFF')
      .borderRadius(16)
      .textAlign(TextAlign.Center)
      .margin({ right: 12 })
  }

  @Builder
  selectCity() {
    Stack() {
      Image($r('app.media.icon_location')).width(16).height(16).margin({ left: 12 })
      Select(this.buildCitySelectOptions())
        .selected(this.selectCityIdx)
        .value('活动地区： ' + this.selectedCity)
        .arrowPosition(ArrowPosition.END)
        .menuAlign(MenuAlignType.START, { dx: 0, dy: -8 })
        .font({ size: 12, family: Constants.HARMONY_HEITI, weight: FontWeight.Medium })
        .fontColor($r('app.color.title_font_color'))
        .optionFont({ size: 16, family: Constants.HARMONY_HEITI, weight: FontWeight.Medium })
        .optionFontColor($r('app.color.text_font_color_black'))
        .optionHeight(190)
        .optionWidth(224)
        .onSelect((index: number, text?: string | undefined) => {
          this.selectCityIdx = index;
          if (text) {
            this.selectedCity = text;
            this.getActivities();
          }
        })
        .margin({ left: 12 })
        .backgroundColor(Color.Transparent)
    }.width('92%').alignContent(Alignment.Start)
  }

  @Builder
  recommendUser() {
    Stack() {
      Column() {
        this.showUser()
      }

      Column() {
        Image($r('app.media.icon_matchmaker'))
          .width(40)
          .height(40)
          .margin(5)
          .onClick(() => {
            if (this.currentUser != null && this.currentUser.isVip === Constants.YES) {
              this.isShowContactMatchmaker = !this.isShowContactMatchmaker;
            } else {
              this.pageStack.pushPathByName('Member', null, (popInfo: PopInfo) => {
                let basicUserInfo = popInfo.result as BasicUserInfo;
                Logger.debug('userInfo after member=' + JSON.stringify(basicUserInfo))
                if (basicUserInfo != null) {
                  this.currentUser = basicUserInfo;
                  if (basicUserInfo.isVip === Constants.YES) {
                    this.isShowContactMatchmaker = true;
                  }
                }
              });
            }
          })
          .bindSheet($$this.isShowContactMatchmaker, contactMatchmakerBuilder(this.matchMaker, () => {
            this.isShowContactMatchmaker = !this.isShowContactMatchmaker;
          }), {
            detents: [360],
            preferType: SheetType.BOTTOM,
            title: bindSheetTitleBuilder('联系红娘')
          })

        Image(this.followClicked ? $r('app.media.icon_follow') : $r('app.media.icon_followed'))
          .width(40)
          .height(40)
          .margin(5)
          .onClick(() => {
            this.followClicked = !this.followClicked
            if (this.recommendUserFullInfo != null && this.recommendUserFullInfo.userInfo != null &&
              this.recommendUserFullInfo.userInfo.uid != null && this.currentUser != null &&
              this.currentUser.uid != null) {
              if (this.followClicked) {
                FeedService.followUser(this.recommendUserFullInfo.userInfo.uid, this.currentUser.uid,
                  FollowType.Follow);
              } else {
                FeedService.followUser(this.recommendUserFullInfo.userInfo.uid, this.currentUser.uid,
                  FollowType.UnFollow);
              }
            }
          })

        Image($r('app.media.icon_cross')).width(40).height(40).margin(5).onClick(() => {
          if (this.recommendNumber >= this.getMaxRecommend()) {
            this.getUIContext()
              .showAlertDialog(UiUtils.buildAlertDialogOption('已达推荐用户数的上限~ 开通会员可获得更多推荐哦'))
          } else {
            this.recommendNumber += 1;
            this.getRecommendUser(this.recommendNumber);
          }
        })
      }.position({ right: this.operButtonsRight, bottom: this.operButtonsBottom })
      .gesture(PanGesture()
        .onActionUpdate((event: GestureEvent | undefined) => {
          if (event) {
            let tmp = this.offsetRight - event.offsetX;
            let tmp1 = this.offsetBottom - event.offsetY;
            if (tmp > HOME_OPER_DRAG_MIN_RIGHT && tmp < HOME_OPER_DRAG_MAX_RIGHT && tmp1 > HOME_OPER_DRAG_MIN_BOTTOM &&
              tmp1 < HOME_OPER_DRAG_MAX_BOTTOM) {
              this.operButtonsRight = tmp;
              this.operButtonsBottom = tmp1;
            }
          }
        })
        .onActionEnd(() => {
          this.offsetRight = this.operButtonsRight;
          this.offsetBottom = this.operButtonsBottom;
        }))
    }
  }

  @Builder
  showUser() {
    Scroll(this.userInfoScroller) {
      Column() {
        this.showAlbum()
        this.showNameAndId()
        this.showSelfIntro()
        this.showUserLabels()
        this.showMateCriteria()
        this.showFeed()
        //强制加一个行，解决操作按钮遮挡的问题
        Blank().height(50)
      }.onAreaChange((oldValue, newValue) => {
        this.userContentHeight = newValue.height as number
      })
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Auto)
    .scrollBarColor(0xFFF8F6F6)
    .scrollBarWidth(5)
    .edgeEffect(EdgeEffect.Spring)
    .onAreaChange((oldValue, newValue) => {
      this.userContainerHeight = newValue.height as number
    })
    .onDidScroll((xOffset: number, yOffset: number, scrollState: ScrollState) => {
      let maxScroll = this.userContentHeight - this.userContainerHeight + 100;
      let currentOffset = this.userInfoScroller.currentOffset().yOffset;
      Logger.debug('currentOffset=' + currentOffset)
      //currentOffset>0, 向下滑动，超过最大限度时获取下一个用户
      if (currentOffset > 0 && currentOffset > maxScroll) {
        Logger.debug('currentOffset=' + currentOffset + ', maxScroll=' + maxScroll)
        if (!this.getNextFlag) {
          this.getNextFlag = true;
        }
      } else if (currentOffset < 0 && currentOffset < MIN_UP_OFFSET) {
        // currentOffset<0, 表示向上滑动，如果小于负的最大限度，则获取上一个用户
        if (!this.getLastFlag) {
          this.getLastFlag = true;
        }
      }
    })
    .onScrollStop(() => {
      if (this.getNextFlag) {
        if (this.recommendNumber < this.getMaxRecommend()) {
          this.recommendNumber += 1;
          this.getRecommendUser(this.recommendNumber);
        }
        this.getNextFlag = false;
      }
      if (this.getLastFlag) {
        if (this.recommendNumber > 1) {
          this.recommendNumber -= 1;
          this.getRecommendUser(this.recommendNumber);
        }
        this.getLastFlag = false;
      }
    })

  }

  @Builder
  showUserLabels() {
    UserLabels({ userInfo: this.recommendUserFullInfo?.userInfo });
  }

  @Builder
  showFeed() {
    Column() {
      if (this.recommendUserFullInfo != null) {
        Row() {
          Column() {
            this.buildTitle(this.ta + '的动态')
          }.width('90%').alignItems(HorizontalAlign.Start)

          Column() {
            Image($r('app.media.ic_right_arrow'))
              .width(24).height(24).margin({ top: 12, bottom: 12, right: 12 })
          }.width('10%').alignItems(HorizontalAlign.End)
        }.onClick(() => {
          this.prepareToFeedListPage();
        })

        if (this.recommendUserFullInfo.recentFeedImages != null &&
          this.recommendUserFullInfo.recentFeedImages.length > 0) {
          Row() {
            if (this.recommendUserFullInfo.recentFeedImages.length < 4) {
              GridShowImage({
                resourceUrl: this.recommendUserFullInfo.recentFeedImages,
                rowTemplate: '1fr',
                columnTemplate: '1fr 1fr 1fr',
                gridHeight: (Constants.FEED_IMAGE_SIZE + 10),
                gridItemHeight: Constants.FEED_IMAGE_SIZE
              });
            } else if (this.recommendUserFullInfo.recentFeedImages.length < 7) {
              GridShowImage({
                resourceUrl: this.recommendUserFullInfo.recentFeedImages,
                rowTemplate: '1fr 1fr',
                columnTemplate: '1fr 1fr 1fr',
                gridHeight: (Constants.FEED_IMAGE_SIZE + 10) * 2,
                gridItemHeight: Constants.FEED_IMAGE_SIZE
              });
            } else {
              GridShowImage({
                resourceUrl: this.recommendUserFullInfo.recentFeedImages,
                rowTemplate: '1fr 1fr 1fr',
                columnTemplate: '1fr 1fr 1fr',
                gridHeight: (Constants.FEED_IMAGE_SIZE + 10) * 3,
                gridItemHeight: Constants.FEED_IMAGE_SIZE
              });
            }
          }.margin({ left: 12, bottom: 12 }).onClick(() => {
            this.prepareToFeedListPage()
          })
        } else {
          Row() {
            Text(this.ta + '还没有发布过动态呢~')
              .width('92%')
              .align(Alignment.Center)
              .height(Constants.FEED_IMAGE_SIZE)
              .backgroundColor($r('app.color.user_empty_content'))
              .borderRadius(10)
              .margin({ bottom: '5vp' });
          }
        }
      }
    }.width('92%').borderRadius(16).backgroundColor(Color.White).margin({ top: 10 })
  }

  private prepareToFeedListPage() {
    if (this.recommendUserFullInfo != null && this.recommendUserFullInfo.userInfo != null &&
      this.recommendUserFullInfo.userInfo.uid != null) {
      this.pageStack.pushPathByName('FeedList',
        new FeedListPageRouteParam(QueryFeedType.QUERY_BY_USER, this.currentUser,
          UserInfo.toBasicUserInfo(this.recommendUserFullInfo.userInfo), this.ta + '的动态'));
    }
  }

  @Builder
  showMateCriteria() {
    Row() {
      if (this.recommendUserFullInfo?.mateSelectionCriteria != null) {
        Column() {
          Row() {
            this.buildTitle(this.ta + '的理想型')
          }.alignSelf(ItemAlign.Start)

          RangeRow({
            start: this.recommendUserFullInfo?.mateSelectionCriteria.ageStart,
            end: this.recommendUserFullInfo?.mateSelectionCriteria.ageEnd, prefix: Constants.AGE_PREFIX
          });
          RangeRow({
            start: this.recommendUserFullInfo?.mateSelectionCriteria.heightStart,
            end: this.recommendUserFullInfo?.mateSelectionCriteria.heightEnd, prefix: Constants.HEIGHT_PREFIX
          });
          EnumRow({
            dataValue: this.recommendUserFullInfo?.mateSelectionCriteria.marriageStatus,
            displayValues: Constants.MARRIAGE_STATUS_DISPLAY_VALUES, itemName: Constants.MARRIAGE_STATUS_PREFIX
          });
          EnumRow({
            dataValue: this.recommendUserFullInfo?.mateSelectionCriteria.monthlyIncome,
            displayValues: Constants.MONTHLY_INCOME_DISPLAY_VALUES, itemName: Constants.INCOME_PREFIX
          });
          EnumRow({
            dataValue: this.recommendUserFullInfo?.mateSelectionCriteria.education,
            displayValues: Constants.EDUCATION_DISPLAY_VALUES,
            itemName: Constants.EDUCATION_PREFIX
          });
          EnumRow({
            dataValue: this.recommendUserFullInfo?.mateSelectionCriteria.hasChildren,
            displayValues: Constants.HAS_CHILDREN_DISPLAY_VALUES, itemName: Constants.HAS_CHILDREN_PREFIX
          });
          EnumRow({
            dataValue: this.recommendUserFullInfo?.mateSelectionCriteria.expectationOfChildren,
            displayValues: Constants.EXPECTATION_OF_CHILDREN_DISPLAY_VALUES, itemName: Constants.EXPECTATION_OF_CHILDREN
          });
          EnumRow({
            dataValue: this.recommendUserFullInfo?.mateSelectionCriteria.smoking,
            displayValues: Constants.SMOKING_DISPLAY_VALUES,
            itemName: Constants.SMOKING_PREFIX
          });
          EnumRow({
            dataValue: this.recommendUserFullInfo?.mateSelectionCriteria.drinking,
            displayValues: Constants.DRINKING_DISPLAY_VALUES,
            itemName: Constants.DRINKING_PREFIX
          });
          DataRow({
            dataValue: this.recommendUserFullInfo?.mateSelectionCriteria.currentResidence,
            itemName: Constants.CURRENT_RESIDENCE_PREFIX
          });
          DataRow({
            dataValue: this.recommendUserFullInfo?.mateSelectionCriteria.originFrom,
            itemName: Constants.ORIGIN_FROM_PREFIX
          });

        }.width('85%')

        Column() {
          Image($r('app.media.mate_criteria_bg')).width(45).height(60)
        }.justifyContent(FlexAlign.End)
      }
    }
    .width('92%').borderRadius(8).margin(6).backgroundColor(Color.White)
  }

  @Builder
  showSelfIntro() {
    UserSelfIntro({ userInfo: this.recommendUserFullInfo?.userInfo })
  }

  @Builder
  showNameAndId() {
    Row() {
      Row() {
        Column() {
          Image($r(this.recommendUserFullInfo?.userInfo?.profilePictureUrl))
            .width(44)
            .height(44)
            .borderRadius(16)
            .clipShape(new Circle({ width: '44', height: '44' }))
        }.margin({ left: 12, right: 12 })

        Column() {
          Text(this.recommendUserFullInfo?.userInfo?.nickName)
            .fontSize($r('sys.float.Body_M')).fontFamily(Constants.HARMONY_HEITI).fontWeight(FontWeight.Bold)
            .margin({ bottom: '5vp' });
          Text('ID: ' + this.recommendUserFullInfo?.userInfo?.userNo)
            .fontSize($r('sys.float.Body_M')).fontFamily(Constants.HARMONY_HEITI).fontWeight(FontWeight.Regular)
        }.alignItems(HorizontalAlign.Start)
      }

      Column() {
        if (this.recommendUserFullInfo?.userInfo?.realNameAuthFlag === Constants.REAL_NAME_AUTH_YES) {
          this.showRealNameAuthLabel('已实名', $r('app.color.user_realname_auth_bg'))
        } else {
          this.showRealNameAuthLabel('未实名', $r('app.color.user_realname_un_auth_bg'))
        }
      }.width(70).margin({ right: 12 })
    }
    .width('92%')
    .height(68)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin(5)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  showRealNameAuthLabel(label: string, bgColor: Resource) {
    Text(label)
      .backgroundColor(bgColor)
      .borderRadius(10)
      .fontSize($r('sys.float.Body_M'))
      .width(70)
      .height(32)
      .textAlign(TextAlign.Center)
  }

  @Builder
  showAlbum() {
    Row() {
      if (this.getPicPath(this.recommendUserFullInfo) === '') {
        Text('用户相册里没有图片~')
          .width('92%')
          .align(Alignment.Center)
          .textAlign(TextAlign.Center)
          .height(166)
          .backgroundColor($r('app.color.user_empty_content'))
          .borderRadius(16)
          .margin({
            left: '5vp',
            right: '5vp',
            bottom: '5vp',
            top: '8vp'
          });
      } else {
        Image($r(this.getPicPath(this.recommendUserFullInfo)))
          .width('92%')
          .height(166)
          .borderRadius(16)
          .objectFit(ImageFit.Auto)
          .margin({
            left: '16vp',
            right: '16vp',
            bottom: '8vp',
            top: '5vp'
          })
      }
    }
  }

  @Builder
  buildTitle(titleValue: string) {
    Text(titleValue)
      .fontSize(16)
      .fontFamily(Constants.HARMONY_HEITI)
      .margin({ left: 12, top: 12, bottom: 12 })
      .fontWeight(FontWeight.Medium)
      .textAlign(TextAlign.Start)
  }

  getPicPath(userFullInfo: UserFullInfo | null): string {
    let albumTmp: Array<string> | null | undefined = userFullInfo?.userInfo?.album;
    if (albumTmp != null && albumTmp !== undefined && albumTmp.length > 0) {
      return albumTmp[0];
    }
    return '';
  }

  getRecommendUser(curPage: number): void {
    UserService.getRecommendUsers(AppStorage.get(Constants.UNION_ID), curPage)
      .then((data: UserFullInfo[]) => {
        if (data != null && data.length > 0) {
          if (data[0] != null) {
            this.recommendUserFullInfo = data[0]
            this.ta = getTa(data[0]);
            if (data[0].userInfo != null) {
              this.followClicked = data[0].userInfo.hasFollowed != null &&
                data[0].userInfo.hasFollowed === Constants.YES
            }
          }
        }
      }
      )
  }

  getMaxRecommend(): number {
    if (this.currentUser == null || this.currentUser.isVip == null || this.currentUser.isVip === Constants.NO) {
      return Constants.MAX_RECOMMEND_USER_NORMAL;
    } else {
      return Constants.MAX_RECOMMEND_USER_VIP;
    }
  }

  getActivities(): void {
    ActivityService.queryActivities(this.selectedCity).then((data: QueryActivityResponse | null) => {
      if (data != null) {
        this.arr = data.list;
      }
    })
  }

  buildCitySelectOptions(): SelectOption[] {
    let selectOptions: SelectOption[] = [];
    let cities: string[] = getContext(this).resourceManager.getStringArrayByNameSync('activity_supported_cities');
    for (let i = 0; i < cities.length; i++) {
      selectOptions[i] = { value: cities[i] }
    }
    return selectOptions;
  }
}

function getFutureActivities(arr: ActivityInfo[]): ActivityInfo[] {
  return arr.filter((value: ActivityInfo, index: number, futureActivities: ActivityInfo[]) => {
    let current = new Date().getTime();
    return value != null && value.activityStartTime > current;
  })
}

function getHistoryActivities(arr: ActivityInfo[]): ActivityInfo[] {
  return arr.filter((value: ActivityInfo, index: number, futureActivities: ActivityInfo[]) => {
    let current = new Date().getTime();
    return value != null && value.activityStartTime <= current;
  })
}

function getTa(recommendUserFullInfo: UserFullInfo | null): string {
  if (recommendUserFullInfo == null || recommendUserFullInfo.userInfo == null ||
    recommendUserFullInfo.userInfo.gender == null) {
    return 'TA';
  }
  return recommendUserFullInfo.userInfo.gender === Constants.GENDER_MALE ? '他' : '她';
}


@Component
export struct RangeRow {
  @Prop start: number | null | undefined;
  @Prop end: number | null | undefined;
  @Prop prefix: string;

  build() {
    if (this.start != null || this.end != null) {
      Row() {
        Text('#' + this.prefix)
          .width('40%')
          .fontSize($r('sys.float.Body_M'))
          .height($r('app.integer.user_label_height'))
          .borderRadius($r('app.integer.user_label_border_radius'))
          .textAlign(TextAlign.Start)
        if (this.start != null && this.end != null) {
          Text(this.start + ' - ' + this.end)
            .height($r('app.integer.user_label_height'))
            .fontSize($r('sys.float.Body_M'))
            .textAlign(TextAlign.Center)
            .align(Alignment.Center)
            .alignSelf(ItemAlign.Center)
        } else if (this.start != null && this.end == null) {
          Text(this.start + Constants.ABOVE)
            .height($r('app.integer.user_label_height'))
            .fontSize($r('sys.float.Body_M'))
            .textAlign(TextAlign.Center)
            .align(Alignment.Center)
            .alignSelf(ItemAlign.Center)
        } else if (this.start == null && this.end != null) {
          Text(this.end + Constants.BELOW)
            .height($r('app.integer.user_label_height'))
            .fontSize($r('sys.float.Body_M'))
            .textAlign(TextAlign.Center)
            .align(Alignment.Center)
            .alignSelf(ItemAlign.Center)
        }
      }.width('92%')
    }
  }
}

@Component
export struct EnumRow {
  @Prop dataValue: string | null | undefined;
  @Prop displayValues: string[];
  @Prop itemName: string

  build() {
    if (this.dataValue != null && this.dataValue !== undefined && this.dataValue !== '') {
      Row() {
        Text('#' + this.itemName)
          .width('40%')
          .height($r('app.integer.user_label_height'))
          .fontSize($r('sys.float.Body_M'))
          .borderRadius($r('app.integer.user_label_border_radius'))
          .textAlign(TextAlign.Start)
        ForEach(this.dataValue.split(','), (item: string) => {
          Text(this.displayValues[parseInt(item)])
            .height($r('app.integer.user_label_height'))
            .fontSize($r('sys.float.Body_M'))
            .textAlign(TextAlign.Center)
            .align(Alignment.Center)
            .alignSelf(ItemAlign.Center)
          Blank().width(5)
        }, (item: string) => item)
      }.width('92%')
    }
  }
}

@Component
export struct DataRow {
  @Prop dataValue: string | null | undefined;
  @Prop itemName: string

  build() {
    if (this.dataValue != null && this.dataValue !== undefined && this.dataValue !== '') {
      Row() {
        Text('#' + this.itemName)
          .width('40%')
          .fontSize($r('sys.float.Body_M'))
          .height($r('app.integer.user_label_height'))
          .borderRadius($r('app.integer.user_label_border_radius'))
          .textAlign(TextAlign.Start)
        Text(this.dataValue)
          .height($r('app.integer.user_label_height'))
          .fontSize($r('sys.float.Body_M'))
          .textAlign(TextAlign.Center)
          .align(Alignment.Center)
          .alignSelf(ItemAlign.Center)
      }.align(Alignment.Start).width('92%')
    }
  }
}
