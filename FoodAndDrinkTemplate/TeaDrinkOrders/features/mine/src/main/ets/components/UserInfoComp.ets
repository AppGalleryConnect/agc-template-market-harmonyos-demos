import {
  Constants,
  HttpCode,
  HttpRequest,
  HttpRequestApi,
  LoadingDialogUtil,
  RouterMap,
  UserIconModel,
  UserInfoModel,
} from 'common/Index';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { AppStorageV2, PersistenceV2, promptAction } from '@kit.ArkUI';
import { MembershipComp } from './MembershipComp';

@ComponentV2
export struct UserInfoComp {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local userIconInfo: UserIconModel = PersistenceV2.connect(UserIconModel, () => new UserIconModel())!;
  @Local authCode: string = ''

  @Computed
  get avatarUri(): string {
    return `file://${getContext().filesDir}/${this.userIconInfo.userIconPath}`
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Row() {
          if (this.userInfo.isRelative) {
            Image(this.userIconInfo.isSaved ? this.avatarUri : $r('app.media.ic_user_img'))
              .width(64)
              .height(64)
              .borderRadius(50)
            Column() {
              Text(this.userInfo.userInfo.name)
                .fontSize(18)
                .fontWeight(500)
                .fontColor($r('sys.color.font_primary'))
              Row() {
                Image($r('app.media.icon_phone')).width(16)
                Text(this.userInfo.getTel())
                  .fontSize(18)
                  .fontColor($r('sys.color.mask_secondary'))
                  .margin({ left: 2 })
              }.margin({ top: 6 }).justifyContent(FlexAlign.Start)
            }
            .alignItems(HorizontalAlign.Start)
            .padding({ left: 12, top: 6 })
            .height(64)
          } else {
            Image($r('app.media.default_hd'))
              .width(64)
              .height(64)
              .borderRadius(50)
            Column() {
              Text($r('app.string.no_relate'))
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
            }.justifyContent(FlexAlign.Center)
            .padding({ left: 12 })
            .height(64)
          }
        }.onClick(() => {
          if (this.userInfo.isRelative) {
            this.pageStack?.pushPathByName(RouterMap.USER_INFO_PAGE, null)
          } else {
            promptAction.showToast({ message: $r('app.string.no_relative_account_msg') })
          }
        })

        Row() {
          Image($r('app.media.ic_connect')).width(10).height(10).margin({ right: 5 })
          Text(this.userInfo.isRelative ? $r('app.string.disassociate') : $r('app.string.associate_account'))
            .fontSize(10)
            .fontColor(this.userInfo.isRelative ? '#B9DC4B' : '#486602')
            .margin({ left: 4 })
        }
        .padding({
          top: 5,
          bottom: 5,
          right: 8,
          left: 8,
        })
        .borderRadius(11)
        .backgroundColor(this.userInfo.isRelative ? '#182200' : '#0D000000')
        .onClick(() => {
          if (this.userInfo.isRelative) {
            this.cancelRelative()
          } else {
            LoadingDialogUtil.openLoadingDialog()
            this.getQuickLoginAnonymousPhone()
          }
        })
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        right: 8,
        left: 8,
      })

      MembershipComp()
    }

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
            if (res.code === HttpCode.SUCCESS) {
              let tel = res.data.userTel ?? ''
              this.userInfo.userInfo.userTel = `${tel.substring(0, tel.length - 8)}****${tel.substring(tel.length - 4)}`
              this.userInfo.isRelative = true
            } else {
              promptAction.showToast({ message: $r('app.string.relate_account_msg1') })
            }
          }).catch(() => {
            promptAction.showToast({ message: $r('app.string.relate_account_msg2') })
          }).finally(() => {
            LoadingDialogUtil.close()
          })
        } else {
          promptAction.showToast({ message: $r('app.string.relate_account_msg2') })
          LoadingDialogUtil.close()
        }
      }).catch((err: BusinessError<Object>) => {
        this.dealAllError(err);
        LoadingDialogUtil.close()
      });
    } catch (error) {
      this.dealAllError(error);
      LoadingDialogUtil.close()
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
        HttpRequest.getCancelLogin().then(() => {
          this.userInfo.isRelative = false
          this.userInfo.userInfo.userTel = ''
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