import {
  CallTelDialogBuilder,
  Constants,
  getCancelLoginUtil,
  HttpCode,
  HttpRequestApi,
  NavHeaderBar,
  StoreInfo,
} from 'common/Index';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';
import fs from '@ohos.file.fs';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';

@Component
export struct PersonalCenterPage {
  @Consume('pageStack') pageStack: NavPathStack
  @State windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Image($r('app.media.mask'))
          .width(Constants.FULL_SIZE)
          .height(274)
        Column() {
          NavHeaderBar({
            title: $r('app.string.personal_center'),
            hasBackButton: false,
            hasBgColor: false,
            isMainPage: true,
          })
          Scroll() {
            Column() {
              UserMsgCard().margin({ top: 10 })
              MyCenter()
              HelpCenter()
            }
          }.layoutWeight(1).scrollBar(BarState.Off).align(Alignment.Top);

        }
        .alignItems(HorizontalAlign.Start)
        .width(Constants.FULL_SIZE)
        .padding({
          left: 12,
          right: 12,
        })
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.background_secondary'))
    }.hideTitleBar(true)
  }
}

@Component
struct UserMsgCard {
  @StorageLink('authCode') authCode: string = ''
  @StorageLink('userName') userName: string = ''
  @StorageLink('userIconPath') userIconPath: string = ''
  @StorageLink('userTel') @Watch('change') userTel: string = ''
  @State isRelative: boolean = false
  @State avatarUri: string = `file://${getContext().filesDir}/${this.userIconPath}`

  aboutToAppear(): void {
    this.change()
  }

  change() {
    if (this.userTel) {
      this.userTel =
        `${this.userTel.substring(0, this.userTel.length - 8)}****${this.userTel.substring(this.userTel.length - 4)}`
    }
    this.isRelative = !!this.userTel
  }

  build() {
    Row() {
      Row() {
        if (this.isRelative) {
          FunctionalButton({
            params: {
              // OpenType.CHOOSE_AVATAR表示Button为选择头像类型
              openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
              label: '',
              // 调整Button样式
              styleOption: {
                styleConfig: new functionalButtonComponentManager.ButtonConfig()
                  .type(ButtonType.Normal)
                  .backgroundImage(this.avatarUri ? this.avatarUri : $r('app.media.ic_default_hd'))
                  .backgroundImageSize(ImageSize.Cover)
                  .width(64)
                  .height(64)
                  .borderRadius(50)
                  .backgroundColor('#E5E5E5'),
              },
            },
            // OpenType为“CHOOSE_AVATAR”时，回调必须选择“onChooseAvatar”
            controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((err,
              data) => {
              if (err) {
                // 错误日志处理
                hilog.error(0x0000, 'testTag', 'error： %{public}d %{public}s', err.code, err.message);
                return;
              }
              // 成功日志处理
              hilog.info(0x0000, 'testTag', 'succeeded in choosing avatar');
              let file: fs.File = null!;
              try {
                file = fs.openSync(data.avatarUri, fs.OpenMode.READ_ONLY)
                this.userIconPath = `${util.generateRandomUUID(false)}.jpg`
                let imagePath = `${getContext().filesDir}/${this.userIconPath}`
                fs.copyFileSync(file.fd, imagePath)
                this.avatarUri = 'file://' + imagePath
              } catch (error) {
                let err: BusinessError = error as BusinessError;
                console.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
              } finally {
                fs.closeSync(file);
              }
            }),
          })
        } else {
          Image($r('app.media.ic_default_hd'))
            .width(64)
            .height(64)
            .borderRadius(50)
        }

        Column() {
          if (this.isRelative) {
            Text(this.userName)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))

            Row() {
              Image($r('app.media.icon_phone')).width(16)
              Text(this.userTel)
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_secondary'))
                .margin({ left: 2 })
            }.margin({ top: 12, left: 1 })
          } else {
            Text($r('app.string.no_relative')).fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_secondary'))
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
      }

      Row() {
        Row() {
          Image(this.isRelative ? $r('app.media.ic_relatived') : $r('app.media.connect'))
            .width(12)
            .height(12)
            .margin({ right: 4 })
          Text(this.isRelative ? $r('app.string.disassociate') : $r('app.string.associate_account'))
            .fontSize($r('sys.float.Body_S'))
            .fontColor(this.isRelative ? $r('sys.color.font_on_primary') : $r('sys.color.multi_color_09'))
        }
        .padding({
          left: 10,
          right: 10,
          top: 6,
          bottom: 6,
        })
        .borderRadius(14)
        .backgroundColor(this.isRelative ? $r('sys.color.multi_color_09') : $r('sys.color.background_secondary'))
        .onClick(() => {
          if (this.isRelative) {
            this.cancelRelative()
          } else {
            this.getQuickLoginAnonymousPhone()
          }
        })
      }
      .height(Constants.FULL_SIZE)
      .alignItems(this.isRelative ? VerticalAlign.Top : VerticalAlign.Center)

    }
    .width(Constants.FULL_SIZE)
    .justifyContent(FlexAlign.SpaceBetween)
    .height(112)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding({
      left: 16,
      right: 16,
      top: 24,
      bottom: 24,
    })
  }

  getQuickLoginAnonymousPhone() {
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
    try {
      const controller = new authentication.AuthenticationController(getContext(this));
      controller.executeRequest(authRequest).then((data) => {
        const authorizationWithHuaweiIDResponse = data as authentication.AuthorizationWithHuaweiIDResponse;
        const state = authorizationWithHuaweiIDResponse.state;
        if (state !== undefined && authRequest.state !== state) {
          hilog.error(0x0000, 'testTag', `Failed to authorize. The state is different, response state: ${state}`);
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in authentication.');
        const authorizationWithHuaweiIDCredential = authorizationWithHuaweiIDResponse.data!;
        const code = authorizationWithHuaweiIDCredential.authorizationCode;
        this.authCode = code ?? ''
        // 开发者处理code
        if (code) {
          HttpRequestApi.getOpenLoginHm(encodeURIComponent(code)).then((res) => {
            if (res.status === HttpCode.SUCCESS) {
              let tel = res.userTel ?? ''
              this.userTel = `${tel.substring(0, tel.length - 8)}****${tel.substring(tel.length - 4)}`
              this.isRelative = true
            } else {
              promptAction.showToast({ message: '账号关联失败，请重试~' })
            }
          }).catch(() => {
            promptAction.showToast({ message: '账号关联失败' })
          })
        } else {
          promptAction.showToast({ message: '账号关联失败' })
        }
      }).catch((err: BusinessError<Object>) => {
        this.dealAllError(err);
      });
    } catch (error) {
      this.dealAllError(error);
    }

  }

  cancelRelative() {
    // 创建取消授权请求，并设置参数
    const cancelRequest = new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
    cancelRequest.state = util.generateRandomUUID(); // 建议使用generateRandomUUID生成state

    // 执行取消授权请求，并处理结果
    try {
      const controller = new authentication.AuthenticationController(getContext(this));
      controller.executeRequest(cancelRequest, (error: BusinessError<Object>, data) => {
        if (error) {
          this.dealAllError(error);
          return;
        }
        const cancelAuthorizationResponse = data as authentication.CancelAuthorizationResponse;
        const state = cancelAuthorizationResponse.state;
        if (state && cancelRequest.state !== state) {
          hilog.error(0x0000, 'testTag', `Failed to cancel. The state is different, response state: ${state}`);
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in canceling.');
        getCancelLoginUtil().then(() => {
          this.isRelative = false
          this.userTel = ''
        })
      });
    } catch (error) {
      this.dealAllError(error);
    }
  }

  // 错误处理
  dealAllError(error: BusinessError<Object>): void {
    hilog.error(0x0000, 'testTag',
      `Failed to login, errorCode is ${error.code}, errorMessage is ${error.message}`);
    promptAction.showToast({ message: '账号关联失败' })
  }
}

@Component
struct MyCenter {
  @Consume('pageStack') pageStack: NavPathStack
  @Consume('currentIndex') currentIndex: number
  @State wallet: string = AppStorage.get('wallet') as string ?? '0.00'
  @State totalScore: string = AppStorage.get('totalScore') as string

  @Styles
  cardStyle(){
    .layoutWeight(1)
    .padding({
      left: 18,
      right: 18,
      top: 15,
      bottom: 15,
    })
    .borderRadius(8)
    .backgroundColor(Color.White)
  }

  build() {
    Column() {
      Row({ space: 16 }) {
        Row() {
          Column() {
            Text($r('app.string.wallet')).fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'))
            Text($r('app.string.yuan_params', `${this.wallet}`))
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.multi_color_09')).margin({ top: 4 })
          }.alignItems(HorizontalAlign.Start)

          Image($r('app.media.wallet')).width(32)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .cardStyle()

        Row() {

          Column() {
            Text($r('app.string.my_coupon')).fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'))
            Text($r('app.string.my_coupon_desc'))
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 4 })
          }.alignItems(HorizontalAlign.Start)

          Image($r('app.media.coupon')).width(32)
        }
        .cardStyle()
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          this.pageStack.pushPath({
            name: 'MyCouponsPage', param: null, onPop: (popInfo) => {
              this.currentIndex = popInfo.result as number
            },
          })
        })

      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)

      Row({ space: 16 }) {
        Row() {
          Column() {
            Text($r('app.string.points')).fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'))
            Text($r('app.string.points_param', `${this.totalScore}`))
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.multi_color_09')).margin({ top: 4 })
          }.alignItems(HorizontalAlign.Start)

          Image($r('app.media.ic_score_card')).width(32)
        }
        .cardStyle()
        .justifyContent(FlexAlign.SpaceBetween)

        Row().layoutWeight(1)
      }.justifyContent(FlexAlign.Start).margin({ top: 12 })

    }
    .width(Constants.FULL_SIZE)
    .margin({ top: 12 })
  }
}

@Component
struct HelpCenter {
  @Consume('pageStack') pageStack: NavPathStack
  @Consume('storeInfo') storeInfo?: StoreInfo
  @State callTelSheet: boolean = false

  build() {
    Column() {
      Text($r('app.string.help_center'))
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .margin({ left: 12 })
      Column() {
        Row() {
          Row() {
            Image($r('app.media.question')).width(16).height(16)
            Text($r('app.string.faqs'))
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_primary'))
              .margin({ left: 12 })
          }

          Image($r('app.media.right_arrow')).width(16).height(16)
        }
        .width(Constants.FULL_SIZE)

        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          this.pageStack.pushPath({ name: 'FrequentQuestionPage' })
        })

        Divider().margin({ left: 28, top: 12, bottom: 12 })
        Row() {
          Row() {
            Image($r('app.media.telephone')).width(16).height(16)
            Text($r('app.string.customer_phone'))
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_primary'))
              .margin({ left: 12 })
          }

          Image($r('app.media.right_arrow')).width(16).height(16)
        }
        .width(Constants.FULL_SIZE)
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          // 拨打商家电话
          this.callTelSheet = true
        })
        .bindSheet($$this.callTelSheet, CallTelDialogBuilder(this.storeInfo?.tel || '', () => {
          this.callTelSheet = false
        }), {
          height: 309,
          blurStyle: BlurStyle.Thick,
          showClose: false,
        });
      }
      .padding(12)
      .margin({ top: 12 })
      .width(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(16)
    }.margin({ top: 16 }).alignItems(HorizontalAlign.Start)
  }
}