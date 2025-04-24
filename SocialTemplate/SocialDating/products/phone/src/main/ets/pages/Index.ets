import { TabItem, tabItems } from '../model/TabItem';
import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BasicUserInfo, GetUserResponse, UserInfo, Constants,MockService } from 'commons';
import { Home, Personal } from 'composite';
import { MemberPage } from 'member';
import { FeedListPage } from 'feed';
import UserService from 'user/src/main/ets/service/UserService';
import Logger from 'commons/src/main/ets/utils/Logger';

@Entry
@Component
struct Index {
  @State currentPageIndex: number = 0;
  @State currentUser: BasicUserInfo | null = null;
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pageStack) {
      if (this.currentUser != null) {
        this.buildPageTitle()
        Tabs({ barPosition: BarPosition.End, index: this.currentPageIndex }) {
          TabContent() {
            Home({ index: this.currentPageIndex })
          }.tabBar(this.buildTabBar(tabItems[Constants.PAGE_INDEX_HOME], Constants.PAGE_INDEX_HOME))
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])

          TabContent() {
            FeedListPage({ index: this.currentPageIndex })
          }.tabBar(this.buildTabBar(tabItems[Constants.PAGE_INDEX_FEED], Constants.PAGE_INDEX_FEED))
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])

          TabContent() {
            MemberPage({ index: this.currentPageIndex })
          }.tabBar(this.buildTabBar(tabItems[Constants.PAGE_INDEX_MEMBER], Constants.PAGE_INDEX_MEMBER))
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])

          TabContent() {
            Personal({ index: this.currentPageIndex })
          }.tabBar(this.buildTabBar(tabItems[Constants.PAGE_INDEX_PERSONAL], Constants.PAGE_INDEX_PERSONAL))
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        }
        .width('100%')
        .barHeight(110)
        .onChange((index: number) => {
          this.currentPageIndex = index;
        })
        .vertical(false)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .backgroundColor($r('app.color.page_background_color'))
      }
    }
    .backgroundColor($r('app.color.page_background_color'))
    .hideTitleBar(true)
    .hideToolBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  buildPageTitle() {
    Row() {
      if (this.currentPageIndex === Constants.PAGE_INDEX_HOME) {
        this.buildPageTitleText(tabItems[Constants.PAGE_INDEX_HOME].title)
      } else if (this.currentPageIndex === Constants.PAGE_INDEX_FEED) {
        this.buildPageTitleText(tabItems[Constants.PAGE_INDEX_FEED].title)
      } else if (this.currentPageIndex === Constants.PAGE_INDEX_MEMBER) {
        this.buildPageTitleText(tabItems[Constants.PAGE_INDEX_MEMBER].title)
      } else {
        this.buildPageTitleText(tabItems[Constants.PAGE_INDEX_PERSONAL].title)
      }
    }
    .width('92%')
    .height(56)
    .justifyContent(FlexAlign.Start)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  buildPageTitleText(pageTitle: string) {
    Text(pageTitle)
      .fontColor($r('app.color.text_font_color_black'))
      .fontSize(24)
      .fontWeight(FontWeight.Medium)
      .fontFamily(Constants.HARMONY_HEITI)
      .height(56)
  }

  @Builder
  buildTabBar(button: TabItem, tabIndex: number) {
    Column() {
      Image(this.currentPageIndex === tabIndex ? button.selectedImage : button.img)
        .objectFit(ImageFit.Contain)
        .width(24)
        .height(24)
        .margin({ top: 18, bottom: 4 })
      Text(button.title)
        .fontSize($r('sys.float.Body_M'))
        .fontColor(this.currentPageIndex === tabIndex ? button.selectedTitleColor :
        $r('app.color.text_font_color_gray'))
        .fontWeight(FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(110)
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Start)
    .onClick(() => {
      this.currentPageIndex = tabIndex;
    })
  }

  aboutToAppear(): void {
    MockService.init();
    this.silentLogin();
  }

  private silentLogin() {
    let loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
    loginRequest.forceLogin = false;
    let controller = new authentication.AuthenticationController();
    controller.executeRequest(loginRequest).then((data) => {
      let loginWithHuaweiIDResponse = data as authentication.LoginWithHuaweiIDResponse;
      let authCode = loginWithHuaweiIDResponse.data?.authorizationCode;
      let unionId = loginWithHuaweiIDResponse.data?.unionID;
      Logger.info('silent login success, unionId=' + unionId);
      AppStorage.setOrCreate(Constants.UNION_ID, unionId);
      this.getUserInfo(unionId);
    }).catch((error: BusinessError) => {
      Logger.error(0x0000, 'testTag', 'silentLogin failed, error: %{public}s', JSON.stringify(error));
      if (error.code === authentication.AuthenticationErrorCode.ACCOUNT_NOT_LOGGED_IN) {
        loginRequest.forceLogin = true;
        controller.executeRequest(loginRequest).then((data) => {
          let loginWithHuaweiIDResponse = data as authentication.LoginWithHuaweiIDResponse;
          let authCode = loginWithHuaweiIDResponse.data?.authorizationCode;
          let unionId = loginWithHuaweiIDResponse.data?.unionID;
          Logger.info('force login success, unionId=' + unionId);
          AppStorage.setOrCreate(Constants.UNION_ID, unionId);
          this.getUserInfo(unionId);
        })
      }
    })
  }

  getUserInfo(unionId: string | undefined) {
    Logger.debug('getUserInfo, unionId=' + unionId);
    UserService.getUserFullInfoByUnionId(unionId).then((data: GetUserResponse | null) => {
      AppStorage.setOrCreate(Constants.FIRST_LOGIN_FLAG, false);
      if (data === null || data.userFullInfo == null || data.userFullInfo.userInfo == null) {
        this.pageStack.pushPathByName('UserRegister', null, (popInfo: PopInfo) => {
          this.currentUser = popInfo.result as BasicUserInfo;
        });
      } else {
        this.currentUser = UserInfo.toBasicUserInfo(data.userFullInfo.userInfo);
        AppStorage.setOrCreate(Constants.CURRENT_USER_BASIC, this.currentUser);
        Logger.debug('-----currentUser set to  appStorage=' + JSON.stringify(this.currentUser))
      }
    })
  }
}
