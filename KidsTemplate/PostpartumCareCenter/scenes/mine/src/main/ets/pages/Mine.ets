import { AssociatePhone, MainEntryVM, TitleTop } from '@ohos_agcit/postpartum_care_center_uicomponents';
import { ServiceItem } from '@ohos_agcit/postpartum_care_center_utils';
import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { dealAllError } from '../common/Constants';
import { showToast } from '../common/ShowToast';

@Entry
@ComponentV2
export struct Mine {
  logTag: string = 'PrepareLoginPage';
  domainId: number = 0x0000;
  @Local message: string = '我的';
  @Param vm: MainEntryVM = MainEntryVM.instance;

  build() {
    Stack() {
      Image($r('app.media.background_pic'))
        .width('100%')
        .height(200)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);

      Column() {
        TitleTop({ title: $r('app.string.title_mine') });
        Column() {
          Column() {
            Row({ space: 12 }) {
              Image(this.vm.userInfo.isLogin && this.vm.userInfo.avatar !== '' ? this.vm.userInfo.avatar : $r('app.media.ic_user_default'))
                .width(48)
                .height(48)
                .borderRadius(100)

              Column({ space: 8 }) {
                Text(this.vm.userInfo.isLogin && this.vm.userInfo.nickname !== '' ? this.vm.userInfo.nickname : '点击登录')
                  .fontSize($r('app.string.font_size_18'))
                  .fontFamily('HarmonyHeiTi')
                  .fontWeight(FontWeight.Medium)
                  .fontColor('rgba(0,0,0,0.90)');
              }
              .width('70%')
              .alignItems(HorizontalAlign.Start);
            }
            .width('100%');
          }
          .padding($r('app.string.margin_s'))
          .margin({ top: $r('app.string.margin_xs'), bottom: $r('app.string.margin_s') })
          .backgroundColor('#FFFFFF')
          .borderRadius($r('app.string.border_radius_16'))
          .onClick(() => {
            if (this.vm.userInfo.isLogin) {
              this.vm.navStack.pushPathByName('PersonalInformation', undefined);
            } else {
              this.getQuickLoginAnonymousPhone();
            }
          });
          Column() {
            Text('常用服务')
              .width('100%')
              .height(56)
              .fontSize($r('app.string.font_size_18'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Bold)
              .fontColor('rgba(0,0,0,0.90)')
              .padding({ top: $r('app.string.padding_24'), bottom: $r('app.string.padding_8') })
              .textAlign(TextAlign.Start);

            List() {
              ForEach(this.vm.serviceItems, (item: ServiceItem, index: number) => {
                ListItem() {
                  Column() {
                    Row() {
                      Image($r(item.logo))
                        .width(24)
                        .height(24);

                      Text(item.name)
                        .fontColor('rgba(0,0,0,0.90)')
                        .fontSize('app.string.font_size_16')
                        .fontFamily('HarmonyHeiTi')
                        .fontWeight(FontWeight.Medium)
                        .textAlign(TextAlign.Start)
                        .margin({ left: $r('app.string.margin_ms') });

                      Blank();

                      Text(item.linkNextPageDesc)
                        .fontSize($r('app.string.font_size_14'))
                        .fontFamily('HarmonyHeiTi')
                        .fontWeight(FontWeight.Regular)
                        .fontColor('rgba(0,0,0,0.60)')
                        .textAlign(TextAlign.Start)
                        .margin({ right: $r('app.string.margin_xxs') });

                      Image($r('app.media.chevron_right'))
                        .width(12)
                        .height(24);
                    }
                    .width('100%')
                    .height(56)
                    .onClick(() => {
                      this.vm.navStack.pushPathByName(item.linkNextPagePath, null);
                    });

                    if (index !== this.vm.serviceItems.length - 1) {
                      Divider()
                        .margin({ left: $r('app.string.margin_40') })
                        .color('rgba(0,0,0,0.05)')
                        .strokeWidth(1);
                    }
                  };
                }
                .height(68);
              }, (item: ServiceItem) => JSON.stringify(item));
            }
            .width('100%');
          }
          .backgroundColor('#FFFFFF')
          .padding({
            left: $r('app.string.padding_12'),
            right: $r('app.string.padding_12'),
            bottom: $r('app.string.padding_4'),
          })
          .justifyContent(FlexAlign.Start)
          .width('100%')
          .borderRadius($r('app.string.border_radius_16'));
        }
        .margin({
          left: $r('app.string.padding_16'),
          right: $r('app.string.padding_16'),
        });
      }
      .align(Alignment.TopStart);
    }
    .width('100%')
    .height('100%')
    .clip(false)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .backgroundColor('#F1F3F5')
    .alignContent(Alignment.TopStart);
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
      const params: Record<string, Object> = { 'anonymousPhone': quickLoginAnonymousPhone };
      this.vm.navStack.pushPathByName('QuickLoginPage', params);
    } else {
      // If the anonymous mobile number cannot be obtained, an error message is displayed.
      const hint: string = getContext().resourceManager.getStringSync($r('app.string.get_mobile_number_error'));
      showToast(hint);
    }
  }



}
