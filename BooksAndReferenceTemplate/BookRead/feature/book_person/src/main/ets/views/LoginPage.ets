import { authentication, loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { Constants, TCRouter, UserInfo } from 'common';
import { AvatarIcon } from '../comp/SelectAvatarCard';

@ComponentV2
export struct LoginPage {
  logTag: string = 'LoginPage';
  domainId: number = 0x0000;
  @Local userInfo: UserInfo | undefined = undefined;
  @Local avatarIcon: AvatarIcon | undefined = undefined;
  @Local quickLoginAnonymousPhone: ResourceStr = $r('app.string.phone_number');
  @Local isSelected: boolean = false;
  private USER_AUTHENTICATION_TAG = '华为账号用户认证协议';
  private USER_SERVICE_TAG = '用户服务协议';
  private PRIVACY_TAG = '隐私协议';
  // 定义LoginWithHuaweiIDButton展示的隐私文本，展示应用的用户服务协议、隐私协议和华为账号用户认证协议
  privacyText: loginComponentManager.PrivacyText[] = [{
    text: '已阅读并同意',
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: '《用户服务协议》',
    tag: this.USER_SERVICE_TAG,
    type: loginComponentManager.TextType.RICH_TEXT
  }, {
    text: '和',
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: '《隐私协议》',
    tag: this.PRIVACY_TAG,
    type: loginComponentManager.TextType.RICH_TEXT
  }, {
    text: '。',
    type: loginComponentManager.TextType.PLAIN_TEXT
  }];
  // 构造LoginWithHuaweiIDButton组件的控制器
  controller: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
      /**
       * 当应用使用自定义的登录页时，如果用户未同意协议，需要设置协议状态为NOT_ACCEPTED，当用户同意协议后再设置
       * 协议状态为ACCEPTED，才可以使用华为账号一键登录功能
       */
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton((error: BusinessError | undefined,
        response: loginComponentManager.HuaweiIDCredential) => {
        this.handleLoginWithHuaweiIDButton(error, response);
      })
      .onClickEvent((error: BusinessError, clickEvent: loginComponentManager.ClickEvent) => {
        if (error) {
          this.dealAllError(error);
          return;
        }
        hilog.info(this.domainId, this.logTag, `onClickEvent clickEvent: ${clickEvent}`);
      });

  // 传递页面渲染所需的数据，如匿名手机号等
  aboutToAppear(): void {

  }

  // Toast提示
  showToast(resource: string) {
    try {
      promptAction.showToast({
        message: resource,
        duration: 2000
      });
    } catch (error) {
      const message = (error as BusinessError).message
      const code = (error as BusinessError).code
      hilog.error(this.domainId, this.logTag, `showToast args  errCode is ${code}, errMessage is ${message}`);
    }
  }

  openAgreementDialog() {
    promptAction.showDialog({
      title: '用户协议与隐私条款',
      message: '已阅读并同意 《用户服务协议》和《隐私协议》。',
      buttons: [
        {
          text: '取消',
          color: $r('app.color.button_color')
        },
        {
          text: '同意并登录',
          color: $r('app.color.button_color')
        }
      ]
    }, (err, data) => {
      if (data.index === 1) {
        this.isSelected = true;
        this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
        // 调用此方法，同意协议与登录一并完成，无需再次点击登录按钮
        this.controller.continueLogin((error: BusinessError) => {
          if (error) {
            hilog.error(this.domainId, this.logTag,
              `Failed to login with agreementDialog. errCode is ${error.code}, errMessage is ${error.message}`);
          } else {
            hilog.info(this.domainId, this.logTag,
              'Succeeded in clicking agreementDialog continueLogin.');
          }
        });
      }
    })
  }

  handleLoginWithHuaweiIDButton(error: BusinessError | undefined,
    response: loginComponentManager.HuaweiIDCredential) {
    if (error) {
      hilog.error(this.domainId, this.logTag,
        `Failed to login with LoginWithHuaweiIDButton. errCode is ${error.code}, errMessage is ${error.message}`);
      if (error.code === ErrorCode.ERROR_CODE_NETWORK_ERROR) {
        AlertDialog.show(
          {
            message: '网络未连接，请检查网络设置。',
            offset: { dx: 0, dy: -12 },
            alignment: DialogAlignment.Bottom,
            autoCancel: false,
            confirm: {
              value: '知道了',
              action: () => {
              }
            }
          }
        );
      } else if (error.code === ErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
        this.openAgreementDialog();
      } else if (error.code === ErrorCode.ERROR_CODE_LOGIN_OUT) {
        // 华为账号未登录提示
        this.showToast('华为账号未登录，请重试');
      } else if (error.code === ErrorCode.ERROR_CODE_NOT_SUPPORTED) {
        // 不支持该scopes或permissions提示
        this.showToast('该scopes或permissions不支持');
      } else if (error.code === ErrorCode.ERROR_CODE_PARAMETER_ERROR) {
        // 参数错误提示
        this.showToast('参数错误');
      } else {
        // 其他提示系统或服务异常
        // 需要申请一键登录权限 降级为授权获取用户信息
        this.getQuickLoginAnonymousPhone();
      }
      return;
    }
    try {
      if (this.isSelected) {
        if (response) {
          hilog.info(this.domainId, this.logTag, 'Succeeded in clicking LoginWithHuaweiIDButton.');
          // 开发者根据实际业务情况使用以下信息
          const authCode = response.authorizationCode;
          const openID = response.openID;
          const unionID = response.unionID;
          const idToken = response.idToken;
        }
      } else {
        this.openAgreementDialog();
      }
    } catch (err) {
      hilog.error(this.domainId, this.logTag,
        `Failed to login with LoginWithHuaweiIDButton, errCode: ${err.code}, errMessage: ${err.message}`);
      AlertDialog.show(
        {
          message: '服务或网络异常，请稍后重试',
          offset: { dx: 0, dy: -12 },
          alignment: DialogAlignment.Bottom,
          autoCancel: false,
          confirm: {
            value: '知道了',
            action: () => {
            }
          }
        }
      );
    }
  }

  // 错误处理
  dealAllError(error: BusinessError): void {
    hilog.error(this.domainId, this.logTag,
      `Failed to login, errorCode is ${error.code}, errorMessage is ${error.message}`);
  }

  getQuickLoginAnonymousPhone() {
    // 创建授权请求，并设置参数
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // 获取手机号需要传如下scope，传参数之前需要先申请对应scope权限,才能返回对应数据
    // authRequest.scopes = ['phone'];
    // 获取头像昵称需要传如下scope
    authRequest.scopes = ['profile'];
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
        // 开发者处理code
        if (code) {
          const authorizationWithHuaweiIDCredential = authorizationWithHuaweiIDResponse.data!;
          const avatarUri = authorizationWithHuaweiIDCredential.avatarUri as string;
          const nickName = authorizationWithHuaweiIDCredential.nickName as string;
          const openId = authorizationWithHuaweiIDResponse.data?.openID as string;
          this.userInfo = {
            id: openId,
            avatarUrl: avatarUri,
            nickName: nickName,
            telephone: 'a1xxxx1111'
          }

          AppStorage.setOrCreate('userInfo', this.userInfo);
          emitter.emit(Constants.LOGIN_CHANGE);
          TCRouter.pop();
        } else {
          promptAction.showToast({ message: '账号关联失败' })
        }
      }).catch((err: BusinessError) => {
        this.dealAllError(err);
      });
    } catch (error) {
      this.dealAllError(error);
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Scroll() {
          Column() {
            Column() {
              Column() {
                Image($r('app.media.startIcon'))
                  .width(48)
                  .height(48)
                  .draggable(false)
                  .borderRadius(50)
                  .copyOption(CopyOptions.None)
                  .onComplete(() => {
                    hilog.info(this.domainId, this.logTag, 'appIcon loading success.');
                  })
                  .onError(() => {
                    hilog.error(this.domainId, this.logTag, 'appIcon loading fail.');
                  })

                Text($r('app.string.app_name'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                  .fontWeight(FontWeight.Medium)
                  .fontWeight(FontWeight.Bold)
                  .maxFontSize($r('sys.float.ohos_id_text_size_headline8'))
                  .minFontSize($r('sys.float.ohos_id_text_size_body1'))
                  .maxLines(1)
                  .fontColor($r('sys.color.font_secondary'))
                  .constraintSize({ maxWidth: '100%' })
                  .margin({
                    top: 12,
                  })

                Text($r('app.string.app_description'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                  .fontWeight(FontWeight.Regular)
                  .constraintSize({ maxWidth: '100%' })
                  .margin({
                    top: 8,
                  })
              }.margin({
                top: 100
              })

              Column() {
                Text(this.quickLoginAnonymousPhone)
                  .fontSize(36)
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                  .fontWeight(FontWeight.Bold)
                  .lineHeight(48)
                  .textAlign(TextAlign.Center)
                  .maxLines(1)
                  .constraintSize({ maxWidth: '100%', minHeight: 48 })

                Text('华为账号绑定号码')
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                  .fontWeight(FontWeight.Regular)
                  .lineHeight(19)
                  .textAlign(TextAlign.Center)
                  .maxLines(1)
                  .constraintSize({ maxWidth: '100%' })
                  .margin({
                    top: 8
                  })
              }.margin({
                top: 64
              })

              Column() {
                LoginWithHuaweiIDButton({
                  params: {
                    // LoginWithHuaweiIDButton支持的样式
                    style: loginComponentManager.Style.BUTTON_RED,
                    // 账号登录按钮在登录过程中展示加载态
                    extraStyle: {
                      buttonStyle: new loginComponentManager.ButtonStyle().loadingStyle({
                        show: true
                      })
                    },
                    // LoginWithHuaweiIDButton的边框圆角半径
                    borderRadius: 24,
                    // LoginWithHuaweiIDButton支持的登录类型
                    loginType: loginComponentManager.LoginType.QUICK_LOGIN,
                    // LoginWithHuaweiIDButton支持按钮的样式跟随系统深浅色模式切换
                    supportDarkMode: true,
                    // verifyPhoneNumber：如果华为账号用户在过去90天内未进行短信验证，是否拉起Account Kit提供的短信验证码页面
                    verifyPhoneNumber: true
                  },
                  controller: this.controller
                })
              }
              .height(40)
              .margin({
                top: 56
              })
            }.width('100%')

            Row() {
              Row() {
                Checkbox({ name: 'privacyCheckbox', group: 'privacyCheckboxGroup' })
                  .width(24)
                  .height(24)
                  .focusable(true)
                  .focusOnTouch(true)
                  .margin({ top: 0 })
                  .select(this.isSelected)
                  .onChange((value: boolean) => {
                    if (value) {
                      this.isSelected = true;
                      this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
                    } else {
                      this.isSelected = false;
                      this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
                    }
                    hilog.info(this.domainId, this.logTag, `agreementChecked: ${value}`);
                  })
              }

              Row() {
                Text() {
                  ForEach(this.privacyText, (item: loginComponentManager.PrivacyText) => {
                    if (item?.type === loginComponentManager.TextType.PLAIN_TEXT && item?.text) {
                      Span(item?.text)
                        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                        .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                        .fontWeight(FontWeight.Regular)
                        .fontSize($r('sys.float.ohos_id_text_size_body3'))
                    } else if (item?.type === loginComponentManager.TextType.RICH_TEXT && item?.text) {
                      Span(item?.text)
                        .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                        .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                        .fontWeight(FontWeight.Medium)
                        .fontSize($r('sys.float.ohos_id_text_size_body3'))
                        .focusable(true)
                        .focusOnTouch(true)
                        .onClick(() => {
                          // 应用需要根据item.tag实现协议页面的跳转逻辑
                          hilog.info(this.domainId, this.logTag, `click privacy text tag: ${item.tag}`);
                          // 华为账号用户认证协议
                          if (item.tag === this.PRIVACY_TAG) {
                            TCRouter.push(Constants.PRIVACY_ROUTE, true);
                          } else {
                            TCRouter.push(Constants.PRIVACY_ROUTE, false);
                          }
                        })
                    }
                  }, (item: loginComponentManager.PrivacyText) => item.text.toString())
                }
                .width('100%')
              }
              .margin({ left: 12 })
              .layoutWeight(1)
              .constraintSize({ minHeight: 24 })
            }
            .alignItems(VerticalAlign.Top)
            .margin({
              top: 16,
              bottom: 16
            })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .constraintSize({ minHeight: '100%' })
          .margin({
            left: 16,
            right: 16
          })
        }
        .padding({ bottom: 20 })
        .width(Constants.FULL_SIZE)
        .height(Constants.FULL_SIZE)
      }
    }
    .hideTitleBar(true)
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
  }
}

export enum ErrorCode {
  // 账号未登录
  ERROR_CODE_LOGIN_OUT = 1001502001,
  // 该账号不支持一键登录，如海外账号
  ERROR_CODE_NOT_SUPPORTED = 1001500003,
  // 网络错误
  ERROR_CODE_NETWORK_ERROR = 1001502005,
  // 用户未同意用户协议
  ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED = 1005300001,
  // 参数错误
  ERROR_CODE_PARAMETER_ERROR = 401
}