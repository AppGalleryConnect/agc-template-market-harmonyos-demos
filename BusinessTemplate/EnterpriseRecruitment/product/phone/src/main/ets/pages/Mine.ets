import { Avatar, AvoidArea, CommonConstants, Route, TitleBar, UserInfo } from '@ohos_agcit/common_component';
import MineListItem from '../mine/MineListItem';
import { AppStorageV2, PersistenceV2, router } from '@kit.ArkUI';
import { MyDataSource } from '@ohos_agcit/common_component';
import { authentication } from '@kit.AccountKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { dealAllError } from './mine/common/Constants';
import { showToast } from './mine/common/ShowToast';
import { QuickLoginInfo } from './mine/clazz/QuickLoginInfo';


@Entry
@ComponentV2
export struct Mine {
  logTag: string = 'PrepareLoginPage';
  domainId: number = 0x0000;
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  routes: Route[] = CommonConstants.ROUTES;
  data: MyDataSource<Route> = new MyDataSource();

  aboutToAppear() {
    for (let i = 0; i <= Route.length - 1; i++) {
      this.data.pushData(this.routes[i]); // 在API12及以后的工程中使用app.media.app_icon
    }
  }

  build() {
    Column() {
      Column() {
        TitleBar({ text: $r('app.string.mine') })
          .width('100%')
          .height('75%')
      }
      .padding({ top: '2%', left: '6%', right: '6%' })
      .height('8%')
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Column() {
        // information area
        Column() {
          Row() {
            Avatar({
              avatar: this.userInfo.isLogin && this.userInfo.avatar !== '' ? this.userInfo.avatar :
              $r('app.media.ic_avatar')
            })

            Text(this.userInfo.isLogin ? this.userInfo?.nickname : $r('app.string.mine_login'))
              .fontWeight(FontWeight.Medium)
              .fontSize($r('app.float.font_size_20'))
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Start)
              .margin({ left: 10 })

            Blank()

            Image($r('app.media.ic_public_arrow_right'))
              .fillColor($r('sys.color.ohos_id_color_foreground'))
              .opacity(0.2)
              .width(12)
              .height(24)
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .padding({ left: '5%', right: '3.5%' })
          .height('50vp')
          .width('100%')
          .onClick(() => {
            if (this.userInfo.isLogin) {
              router.pushUrl({
                url: 'pages/mine/PersonalInformation',
                params: {}
              }, router.RouterMode.Standard)
            } else {
              this.getQuickLoginAnonymousPhone();
            }
          })
        }
        .height('12%')
        .width(CommonConstants.FULL_WIDTH)
        .backgroundColor(Color.White)
        .borderRadius(CommonConstants.COMMON_RADIUS)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .margin({ top: '1%' })

        // service
        Column() {
          Text('常用服务')
            .fontSize($r('app.float.font_size_22'))
            .fontWeight(800)
            .fontColor(Color.Black)
            .margin({ top: 25, left: 30 })
            .textAlign(TextAlign.Start)
            .height('15%')
            .width(CommonConstants.FULL_WIDTH)

          Scroll() {
            Column() {
              LazyForEach(this.data, (item: Route, index: number) => {
                Column() {
                  MineListItem({
                    imagePath: item.img,
                    text: item.title,
                    onClickItem: (event: ClickEvent) => {
                      if (event) {
                        this.toPage(item.path)
                      }
                    }
                  })

                  if (index !== this.routes.length - 1) {
                    Row()
                      .height(0.5)
                      .backgroundColor($r('app.color.divider_gray'))
                      .width('93%')
                  }
                }
              })
            }
          }
        }
        .backgroundColor(Color.White)
        .borderRadius(CommonConstants.COMMON_RADIUS)
        .width(CommonConstants.FULL_WIDTH)
        .margin({ top: 20 })
        .height('35%')
      }
      .padding({
        left: '6%',
        right: '6%'
      })
    }
    .padding({ top: px2vp(this.avoidArea.topRectHeight) + 10 })
    .backgroundColor($r('app.color.common_background'))
    .height(CommonConstants.FULL_HEIGHT)
    .width(CommonConstants.FULL_WIDTH)
  }

  private toPage(url: string): void {
    router.pushUrl({ url: url }, router.RouterMode.Standard)
  }

  // Obtain the anonymous mobile number.
  getQuickLoginAnonymousPhone() {

    // Create an authorization request.
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // User information requested by the app.
    authRequest.scopes = ['quickLoginAnonymousPhone'];
    // In the one-tap sign-in scenario, forceAuthorization must be set to false.
    authRequest.forceAuthorization = false;
    const controller = new authentication.AuthenticationController();
    try {
      controller.executeRequest(authRequest).then((response: authentication.AuthorizationWithHuaweiIDResponse) => {
        // Obtain the UnionID, OpenID, and anonymous mobile number.
        const unionID = response.data?.unionID;
        const openID = response.data?.openID;
        const quickLoginAnonymousPhone = response.data?.extraInfo?.quickLoginAnonymousPhone as string;
        AppStorage.setOrCreate('quickLoginAnonymousPhone', quickLoginAnonymousPhone);
        this.jumpLoginPage(quickLoginAnonymousPhone);
        hilog.info(this.domainId, this.logTag,
          `Succeeded in authorizing. QuickLoginAnonymousPhone is ${quickLoginAnonymousPhone}`);
      }).catch((error: BusinessError) => {
        hilog.error(this.domainId, this.logTag,
          `Failed to authorize. errCode is ${error.code}, errMessage is ${error.message}`);
        dealAllError(error);
        showToast(error);
      });
    } catch (error) {
      hilog.error(this.domainId, this.logTag,
        `Failed to authorize. errCode is ${error.code}, errMessage is ${error.message}`);
    }
  }

  // Redirect to another page.
  private jumpLoginPage(quickLoginAnonymousPhone: string) {
    if (quickLoginAnonymousPhone) {
      // Obtain the anonymous mobile number, pass it, and redirect to the one-tap sign-in screen.
      // const params: Record<string, Object> = { 'anonymousPhone': quickLoginAnonymousPhone };
      const params: QuickLoginInfo = new QuickLoginInfo(quickLoginAnonymousPhone);
      router.pushUrl({
        url: 'pages/mine/QuickLoginPage',
        params: params
      }, router.RouterMode.Standard)
      // this.appPathStack?.pushPathByName('QuickLoginPage', params, true);
    } else {
      // If the anonymous mobile number cannot be obtained, an error message is displayed.
      const hint: string = getContext().resourceManager.getStringSync($r('app.string.get_mobile_number_error'));
      showToast(hint);
    }
  }
}