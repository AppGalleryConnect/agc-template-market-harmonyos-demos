import {
  BasicUserInfo,
  DateUtils,
  NavigationTitleBuilder,
  UserFullInfo,
  Constants,
  UserInfo,
  buildRealNameLabelForList
} from 'commons';
import Logger from 'commons/src/main/ets/utils/Logger';
import UserService from '../service/UserService';


@Builder
export function UserListPageBuilder() {
  UserListPage()
}

const CHAR_PER_LINE = 25;
const PER_LINE_HEIGHT = 16;
const EMPTY_CONTENT_HEIGHT = 50;
const SELF_INTRO_MARGIN = 18;
const SELF_INTRO_TITLE_TEXT_HEIGHT = 34;

@Component
export struct UserListPage {
  @Consume('pageStack') pageStack: NavPathStack;
  private scroller: Scroller = new Scroller();
  private userInfos: UserInfo[] | null = null;

  aboutToAppear(): void {
    let params: UserFullInfo[][] = this.pageStack.getParamByName('UserListPage') as UserFullInfo[][];
    if (params != null) {
      let userFullInfos = params[0];
      this.userInfos = [];
      for (let idx = 0; idx < userFullInfos.length; idx++) {
        let tmp: UserFullInfo = userFullInfos[idx];
        if (tmp != null && tmp.userInfo != null) {
          this.userInfos[idx] = tmp.userInfo;
        }
      }
      Logger.debug('---userListPage=' + JSON.stringify(this.userInfos))
    }
  }

  build() {
    NavDestination() {
      Column() {
        Scroll(this.scroller) {
          Column() {
            ForEach(this.userInfos, (item: UserInfo) => {
              User({ userInfo: item })
            }, (item: UserInfo) => item.uid?.toString())
          }
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
        .scrollBarColor(0xFFF8F6F6) // 滚动条颜色
        .scrollBarWidth(5) // 滚动条宽度
        .edgeEffect(EdgeEffect.Spring)
      }
    }.onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack
    }).backgroundColor($r('app.color.page_background_color')).title(NavigationTitleBuilder('搜索结果'))
  }
}

@Component
export struct User {
  @State userInfo: UserInfo | null = null;
  @State hasFollowed: boolean = false;
  @State currentUserBasic: BasicUserInfo | null = null;

  aboutToAppear(): void {
    let userBasicTmp: BasicUserInfo | null | undefined = AppStorage.get(Constants.CURRENT_USER_BASIC);
    if (userBasicTmp != null && userBasicTmp !== undefined) {
      this.currentUserBasic = userBasicTmp;
    }
    if (this.userInfo != null) {
      this.hasFollowed = this.userInfo.hasFollowed != null && this.userInfo.hasFollowed === Constants.YES
    }
  }

  build() {
    Column() {
      Row() {
        Row() {
          Column() {
            Image(this.userInfo?.profilePictureUrl == null ? $r('app.media.head_image_default') :
              (this.userInfo.profilePictureUrl.startsWith('app.media') ? $r(this.userInfo.profilePictureUrl) :
              this.userInfo.profilePictureUrl))
              .width(72)
              .height(72)
              .clipShape(new Circle({ width: '72', height: '72' }))
              .objectFit(ImageFit.Cover)
          }.width(72).alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.Start)

          Column() {
            Row() {
              Text(this.userInfo?.nickName).fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_font_color_black')).margin({ right: 12 })
            }.margin({ left: 12 }).justifyContent(FlexAlign.Start)

            Row() {
              Text('ID: ' + this.userInfo?.userNo)
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('app.color.text_font_color_black'))
                .textAlign(TextAlign.Start).margin({ right: 12 })
              if (this.userInfo?.realNameAuthFlag != null && this.userInfo.realNameAuthFlag === Constants.YES) {
                buildRealNameLabelForList('已实名', $r('app.color.user_realname_auth_bg'))
              } else {
                buildRealNameLabelForList('未实名', $r('app.color.user_realname_un_auth_bg'))
              }
            }.margin({ left: 12 }).justifyContent(FlexAlign.Start)
          }.alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.Start).width('48%')
        }

        Column() {
          Button(this.hasFollowed ? '已关注' : '+关注')
            .height(32)
            .width(76)
            .backgroundColor(this.hasFollowed ? $r('app.color.button_background_color') : $r('app.color.light_grey_bg'))
            .fontSize($r('sys.float.Body_M'))
            .fontColor(this.hasFollowed ? Color.White : $r('app.color.text_font_color_black'))
            .fontFamily(Constants.HARMONY_HEITI)
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              if (this.currentUserBasic != null && this.currentUserBasic.uid != null && this.userInfo != null &&
                this.userInfo.uid != null) {
                UserService.followUser(this.currentUserBasic.uid, this.userInfo.uid, this.userInfo.hasFollowed)
              }
              this.hasFollowed = !this.hasFollowed;
            })
        }
        .justifyContent(FlexAlign.End)
        .alignItems(HorizontalAlign.End)
        .width(76)
      }
      .height(72)
      .padding({ left: 12, right: 12 })
      .margin({ top: 12, bottom: 8 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      UserSelfIntro({ userInfo: this.userInfo })

      UserLabels({ userInfo: this.userInfo });

    }.backgroundColor(Color.White).borderRadius(16).margin(5).width('92%')
  }
}

function getSelfIntroTextHeight(selfIntroduction: string | null | undefined): number {
  if (selfIntroduction == null || selfIntroduction === undefined || selfIntroduction.length < CHAR_PER_LINE) {
    return EMPTY_CONTENT_HEIGHT;
  }
  return (Math.ceil(selfIntroduction.length / CHAR_PER_LINE)) * PER_LINE_HEIGHT + SELF_INTRO_MARGIN;
}


@Component
export struct UserSelfIntro {
  @Prop userInfo: UserInfo | null = null;

  build() {
    Row() {
      Column() {
        Text('Ta说')
          .fontSize(16)
          .margin({ left: 12, top: 12, bottom: 6 })
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Start)
          .fontColor($r('app.color.text_font_color_black'))
        Text(this.userInfo?.selfIntroduction)
          .height(getSelfIntroTextHeight(this.userInfo?.selfIntroduction))
          .fontSize(14)
          .margin({
            left: 12,
            top: 6,
            bottom: 12,
            right: 12
          })
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.color.text_font_color_black'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)
          .align(Alignment.TopStart)
      }.alignItems(HorizontalAlign.Start)
    }
    .width('92%')
    .height(getSelfIntroTextHeight(this.userInfo?.selfIntroduction) + SELF_INTRO_TITLE_TEXT_HEIGHT)
    .borderRadius(16)
    .margin({
      left: 12,
      right: 12,
      top: 6,
      bottom: 6
    })
    .backgroundImage($r('app.media.intro_background'))
    .backgroundImageSize(ImageSize.FILL);
  }
}


@Component
export struct UserLabels {
  @Prop userInfo: UserInfo | null = null;

  build() {
    Row() {
      if (this.userInfo != null) {
        Column() {
          Row() {
            UserLabel({
              labelValue:
              Constants.getMarriageStatusDisplayValue(this.userInfo.marriageStatus)
            });
            UserLabel({ labelValue: DateUtils.getAge(this.userInfo.birth) + Constants.AGE });
            if (this.userInfo.height) {
              UserLabel({ labelValue: Constants.HEIGHT_PREFIX + this.userInfo.height + 'cm' });
            }
          }.width('100%').justifyContent(FlexAlign.SpaceEvenly)

          Row() {
            if (this.userInfo.education) {
              UserLabel({ labelValue: Constants.getEducationDisplayValue(this.userInfo.education) });
            }
            if (this.userInfo.job) {
              UserLabel({ labelValue: this.userInfo.job });
            }
            if (this.userInfo.currentResidence) {
              UserLabel(
                { labelValue: Constants.CURRENT_RESIDENCE_PREFIX + (this.userInfo.currentResidence) });
            }
          }.width('100%').justifyContent(FlexAlign.SpaceEvenly)
        }.alignItems(HorizontalAlign.Start);
      }
    }.width('92%').margin({ top: 6, bottom: 8 })
  }
}

@Component
export struct UserLabel {
  @Prop labelValue: string

  build() {
    Text(this.labelValue)
      .backgroundColor($r('app.color.user_label_background'))
      .width(94)
      .height($r('app.integer.user_label_height'))
      .borderRadius($r('app.integer.user_label_border_radius'))
      .textAlign(TextAlign.Center)
      .align(Alignment.Center)
      .alignSelf(ItemAlign.Center)
      .margin($r('app.integer.user_label_margin'))
      .fontSize($r('sys.float.Body_M'))
      .fontFamily(Constants.HARMONY_HEITI)
      .fontWeight(FontWeight.Regular);
  }
}