import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { CommonConstants, StringUtil } from '@ohos_agcit/children_education_utils';
import { authentication } from '@kit.AccountKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { User } from '@ohos_agcit/children_education_datasource';

@ComponentV2
export struct LoginState {
  logTag: string = 'PrepareLoginPage';
  domainId: number = 0x0000;
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Consumer(CommonConstants.IS_VIP) isVip: boolean = false;
  @Consumer(CommonConstants.USER_INFO) user: User = new User();

  build() {
    Row() {
      Row() {
        Image(this.user.isLogin && StringUtil.isNotEmpty(this.user.userAvatar) ? this.user.userAvatar : $r('app.media.avatar'))
          .width(45)
          .height(45)
          .borderRadius(100)
          .margin({ right: 14 })
          .onClick(() => {
            if (this.user.isLogin) {
              this.appPathStack.pushPathByName('PersonalInformation', undefined);
            } else {
              this.getQuickLoginAnonymousPhone();
            }
          });

        Column({ space: 5 }) {
          Text(this.user.isLogin ? this.user.userName : '点击登录')
            .fontSize(16)
            .fontFamily('鸿蒙黑体')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.black'))
            .onClick(() => {
              if (this.user.isLogin) {
                this.appPathStack.pushPathByName('PersonalInformation', undefined);
              } else {
                this.getQuickLoginAnonymousPhone();
              }
            });
        };

        if (this.isVip) {
          Row() {
            Image($r('app.media.non_members'))
              .width('4%')
              .fillColor($r('sys.color.black'));

            Text($r('app.string.is_vip'))
              .fontSize(10)
              .fontWeight(FontWeight.Regular)
              .fontFamily('鸿蒙黑体')
              .padding({
                left: 2,
              });
          }
          .margin({
            left: '2%',
          })
          .border({
            radius: 4,
            width: {
              top: 2,
              bottom: 2,
              left: 4,
              right: 4,
            },
            color: '#F8E6CE',
          })
          .backgroundColor('#F8E6CE');
        }
        Blank();
        if (!this.isVip) {
          Button($r('app.string.start_vip'))
            .backgroundColor('#F8E6CE')
            .fontColor($r('sys.color.black'))
            .fontSize(12)
            .width('30%')
            .height(28)
            .onClick(() => {
              let tabIndexData: emitter.EventData = {
                data: {
                  'tabIndex': 1,
                },
              };
              emitter.emit(CommonConstants.TAB_INDEX, tabIndexData);
            });
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({ right: 12, left: 12 });
    }
    .margin({ left: 8, right: 12 })
    .height(72)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .width(CommonConstants.FULL_PERCENT);
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
        // dealAllError(error);
        // showToast(error);
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
      const params: Record<string, Object> = { 'anonymousPhone': quickLoginAnonymousPhone };
      this.appPathStack.pushPathByName('QuickLoginPage', params, true);
    } else {
      // If the anonymous mobile number cannot be obtained, an error message is displayed.
      const hint: string = getContext().resourceManager.getStringSync($r('app.string.get_mobile_number_error'));
      // showToast(hint);
    }
  }
}