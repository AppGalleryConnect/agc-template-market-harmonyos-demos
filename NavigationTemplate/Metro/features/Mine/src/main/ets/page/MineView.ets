import { MainEntryVM } from 'commonlib';
import { authentication } from '@kit.AccountKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { BaseTitle } from 'componentlib';

@CustomDialog
@Component
struct CustomDialogExample {
  controller?: CustomDialogController;
  @Link isConnected: boolean
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  build() {
    Column() {

      Text('账号解除关联')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
      Text('请确认是否解除账号关联？')
      Row() {
        Button('取消')
          .fontColor($r('app.color.color_checked'))
          .backgroundColor($r('app.color.background_white'))
          .onClick(() => {
            if (this.controller !== undefined) {
              this.cancel();
              this.controller.close();
            }
          })
        Button('确定')
          .onClick(() => {
            const cancelRequest = new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
            cancelRequest.state = util.generateRandomUUID(); // 建议使用generateRandomUUID生成state
            try {
              const controller = new authentication.AuthenticationController(getContext(this));
              controller.executeRequest(cancelRequest, (error: BusinessError<Object>, data) => {
                if (error) {
                  return;
                }
                const cancelAuthorizationResponse = data as authentication.CancelAuthorizationResponse;
                const state = cancelAuthorizationResponse.state;
                if (state && cancelRequest.state !== state) {
                  hilog.error(0x0000, 'testTag', `Failed to cancel. The state is different, response state: ${state}`);
                  return;
                }
                hilog.info(0x0000, 'testTag', 'Succeeded in canceling.');
              });
            } catch (error) {
            }
            this.isConnected = false
            if (this.controller !== undefined) {
              this.controller.close();
              this.cancel();
            }
          })
          .fontColor($r('app.color.color_checked'))
          .backgroundColor($r('app.color.background_white'))
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width(224)

    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(HorizontalAlign.Center)
    .width(328)
    .height(139)
    .borderRadius(32)
  }
}

@Component
export struct MineView {
  @State isConnected: boolean = false
  @State phoneNumber: string = '123****8901'
  vm: MainEntryVM = MainEntryVM.instance;
  dialogController: CustomDialogController | null = new CustomDialogController({
    width: 328,
    height: 139,
    cornerRadius: 32,
    backgroundColor: $r('app.color.background_white'),
    builder: CustomDialogExample({
      isConnected: this.isConnected,
      cancel: () => {
      },
      confirm: () => {
      },
    }),
    autoCancel: true,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss();
      }
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss();
      }
    },
    alignment: DialogAlignment.Center,
  })

  @Builder
  MineTitleBuilder() {
    Text('我的')
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Medium)
  }

  build() {
    Column() {
      BaseTitle({
        customTitle: () => {
          this.MineTitleBuilder()
        }
      })

      Column() {
        Row() {
          Row({ space: 12 }) {
            Image(this.isConnected ? $r('app.media.headPicture') : $r('app.media.profilePhoto'))
              .borderRadius(32)
              .width(64)
              .height(64)
            Column() {
              Text('华为用户')
                .fontColor($r('app.color.font_gray'))
                .fontSize(18)
              if (this.isConnected) {
                Row({ space: 4 }) {
                  Image($r('app.media.ic_public_mobilephone'))
                    .width(16)
                    .height(16)
                  Text(this.phoneNumber)
                    .fontColor($r('app.color.font_gray'))
                    .fontSize(12)
                }
                .justifyContent(FlexAlign.Start)
                .margin({ top: 8 })
              }
            }
            .alignItems(HorizontalAlign.Start)
          }

          Row() {
            Image(this.isConnected ? $r('app.media.ic_public_link') : $r('app.media.ic_public_not_link'))
              .width(16)
              .height(16)
            Text(this.isConnected ? '解除关联' : '关联账号')
              .fontSize(14)
              .fontColor(this.isConnected ? $r('app.color.font_blue') : $r('app.color.font_black'))
              .margin({ left: 4 })
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .borderRadius(14)
          .backgroundColor(this.isConnected ? $r('app.color.background_unconnected_account') : $r('app.color.background_connect_account'))
          .padding({left: 8, right: 8, top: 4, bottom: 4})
          .onClick(() => {
            if (this.isConnected) {
              if (this.dialogController !== null) {
                this.dialogController.open();
              }

            } else {
              // 创建授权请求，并设置参数
              const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
              // 获取手机号需要传如下scope，传参数之前需要先申请对应scope权限,才能返回对应数据
              authRequest.scopes = ['phone'];
              // 获取code需传如下permission
              authRequest.permissions = ['serviceauthcode'];
              // 用户是否需要登录授权，该值为true且用户未登录或未授权时，会拉起用户登录或授权页面
              authRequest.forceAuthorization = true;
              // 用于防跨站点请求伪造
              authRequest.state = util.generateRandomUUID();
              // 执行请求
              try {
                const controller = new authentication.AuthenticationController(getContext(this));
                controller.executeRequest(authRequest).then((data) => {
                  const authorizationWithHuaweiIDResponse = data as authentication.AuthorizationWithHuaweiIDResponse;
                  const state = authorizationWithHuaweiIDResponse.state;
                  if (state && authRequest.state !== state) {
                    hilog.error(0x0000, 'testTag',
                      `Failed to authorize. The state is different, response state: ${state}`);
                    return;
                  }
                  hilog.info(0x0000, 'testTag', 'Succeeded in authentication.');
                  const authorizationWithHuaweiIDCredential = authorizationWithHuaweiIDResponse.data!;
                  const code = authorizationWithHuaweiIDCredential.authorizationCode;
                  const unionID = authorizationWithHuaweiIDCredential.unionID;
                  const openID = authorizationWithHuaweiIDCredential.openID;
                  this.isConnected = true

                  // 开发者处理code、unionID、openID
                }).catch((err: BusinessError) => {
                  this.dealAllError(err);
                });
              } catch (error) {
                this.dealAllError(error);
              }
            }
          })
        }
        .backgroundColor(Color.White)
        .margin({ top: 6 })
        .borderRadius(16)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Top)
        .padding({right: 12, top: 12, bottom: 9, left: 12})
        .width('100%')

        Column() {
          this.mineList('用户协议', 'UserAgreementPage')
          Divider()
            .width(303)
          this.mineList('隐私协议', 'PrivacyAgreementPage')
        }
        .borderRadius(16)
        .backgroundColor($r('app.color.background_white'))
        .margin({ top: 12 })
      }
      .padding({left: 16, right: 16})


    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_color'))
  }

  dealAllError(err: BusinessError<void>) {
    throw new Error('Method not implemented.');
  }

  @Builder
  mineList(text: string, pushPath: string) {
    Row() {
      Row() {
        Text(text)
      }
      .margin({ left: 10 })

      Image($r('app.media.right_arrow'))
        .margin({ right: 10 })
        .width(15)
        .height(15)
        .onClick(() => {
          this.vm.navStack.pushPath({ name: pushPath })
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height(50)
  }
}
