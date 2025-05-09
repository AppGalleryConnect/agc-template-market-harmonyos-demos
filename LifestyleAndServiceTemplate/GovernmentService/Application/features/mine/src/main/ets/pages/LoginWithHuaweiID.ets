import { authentication, loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction, router } from '@kit.ArkUI';
import { connection } from '@kit.NetworkKit';
import { util } from '@kit.ArkTS';
import { CloudFunction, CloudFunctionResult, commonToast, UserInfo } from 'common';

@Component
export struct LoginWithHuaweiIDComponent {
  @Consume('pageInfos') pageInfos: NavPathStack
  logTag: string = 'QuickLoginButtonComponent';
  @StorageLink('isLogin') isLogin: boolean = false;
  domainId: number = 0x0000;
  // 第二步获取的匿名化手机号传到此处
  @State quickLoginAnonymousPhone: string = '';
  // 是否勾选协议
  @State isSelected: boolean = false;
  // 华为账号用户认证协议链接，此处仅为示例，实际开发过程中，域名不建议硬编码在本地
  private static USER_AUTHENTICATION_PROTOCOL: string =
    '';
  private static USER_SERVICE_TAG = '用户服务协议';
  private static PRIVACY_TAG = '隐私协议';

  mockUserLogin() {
    /*
     * mock登录数据
     * */
    let mockUserInfo: UserInfo = {
      'idToken': '',
      'userName': '华为用户',
      'avatar': $r('app.media.avatar'),
      'phoneNumber': '123456xxxxx789',
    }
    AppStorage.setOrCreate('userInfo', mockUserInfo)
    AppStorage.setOrCreate('isLogin', true)
    let allPath = this.pageInfos.getAllPathName()
    let currentPath = this.pageInfos.getIndexByName('LoginWithHuaweiIDComponent')
    if (allPath[currentPath[currentPath.length-1] -1] === 'Login') {
      this.pageInfos.clear();
      return
    }
    this.pageInfos.pop();
  }

  getQuickLoginAnonymousPhone() {
    // 创建授权请求，并设置参数
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // 获取手机号需要传如下scope，传参数之前需要先申请对应scope权限,才能返回对应数据
    authRequest.scopes = ['quickLoginAnonymousPhone'];
    authRequest.permissions = ['serviceauthcode'];
    // 用户是否需要登录授权，该值为true且用户未登录或未授权时，会拉起用户登录或授权页面
    authRequest.forceAuthorization = false;
    // 用于防跨站点请求伪造
    authRequest.state = util.generateRandomUUID();
    try {
      const controller = new authentication.AuthenticationController(getContext(this));
      controller.executeRequest(authRequest).then((response) => {
        const authorizationWithHuaweiIDResponse = response as authentication.AuthorizationWithHuaweiIDResponse;
        const state = authorizationWithHuaweiIDResponse.state;
        if (state !== undefined && authRequest.state !== state) {
          hilog.error(0x0000, 'testTag', `Failed to authorize. The state is different, response state: ${state}`);
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in authentication.');
        const authorizationWithHuaweiIDCredential = authorizationWithHuaweiIDResponse.data!;
        const code = authorizationWithHuaweiIDCredential.authorizationCode;
        const unionID = authorizationWithHuaweiIDCredential.unionID;
        const openID = authorizationWithHuaweiIDCredential.openID;
        const anonymousPhone = authorizationWithHuaweiIDCredential?.extraInfo?.quickLoginAnonymousPhone as string;
        if (anonymousPhone) {
          hilog.info(0x0000, 'testTag', 'Succeeded in authentication.');
          this.quickLoginAnonymousPhone = anonymousPhone;
          return;
        }
        // 开发者处理code、unionID、openID
      }).catch((err: BusinessError) => {
        this.dealAllError(err);
      });
    } catch (error) {
      this.dealAllError(error);
    }
  }

  // 定义LoginWithHuaweiIDButton展示的隐私文本，展示应用的用户服务协议、隐私协议和华为账号用户认证协议
  privacyText: loginComponentManager.PrivacyText[] = [{
    text: '已阅读并同意',
    type: loginComponentManager.TextType.PLAIN_TEXT,
  }, {
    text: '《用户服务协议》',
    tag: LoginWithHuaweiIDComponent.USER_SERVICE_TAG,
    type: loginComponentManager.TextType.RICH_TEXT,
  },
    {
      text: '和',
      type: loginComponentManager.TextType.PLAIN_TEXT,
    }, {
      text: '《隐私协议》',
      tag: LoginWithHuaweiIDComponent.PRIVACY_TAG,
      type: loginComponentManager.TextType.RICH_TEXT,
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
  agreementDialog: CustomDialogController = new CustomDialogController({
    builder: AgreementDialog({
      privacyText: this.privacyText,
      cancel: () => {
        this.agreementDialog.close();
        this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
      },
      confirm: () => {
        this.agreementDialog.close();
        this.isSelected = true;
        this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
        // 调用此方法，同意协议与登录一并完成，无需再次点击登录按钮
        this.controller.continueLogin((error: BusinessError) => {
          if (error) {
            hilog.error(this.domainId, this.logTag,
              `Failed to click agreementDialog continueLogin. errCode is ${error.code}, errMessage is ${error.message}`);
          } else {
            hilog.info(this.domainId, this.logTag,
              'Succeeded in clicking agreementDialog continueLogin.');
          }
        });
      },
      clickHyperlinkText: () => {
        this.agreementDialog.close();
      },
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
  });

  // 传递页面渲染所需的数据，如匿名手机号等
  aboutToAppear(): void {
    //   获取匿名手机号
    this.getQuickLoginAnonymousPhone()
  }

  // Toast提示
  showToast(resource: string) {
    try {
      promptAction.showToast({
        message: resource,
        duration: 2000,
      });
    } catch (error) {
      const message = (error as BusinessError).message
      const code = (error as BusinessError).code
      hilog.error(this.domainId, this.logTag, `showToast args  errCode is ${code}, errMessage is ${message}`);
    }
  }

  handleLoginWithHuaweiIDButton(error: BusinessError | undefined,
    response: loginComponentManager.HuaweiIDCredential) {
    if (error) {
      hilog.error(this.domainId, this.logTag,
        `Failed to click LoginWithHuaweiIDButton. errCode is ${error.code}, errMessage is ${error.message}`);
      if(error.code === ErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
        // 未同意协议，弹出协议弹框，推荐使用该回调方式
        this.agreementDialog.open();
        return
        }
      this.mockUserLogin()
      return;
    }
    try {
      if (this.isSelected) {
        if (response) {
          commonToast.show({
            type: 'loading',
          })
          hilog.info(this.domainId, this.logTag, 'Succeeded in clicking LoginWithHuaweiIDButton.');
          // 开发者根据实际业务情况使用以下信息
          const authCode = response.authorizationCode;
          const openID = response.openID;
          const unionID = response.unionID;
          const idToken = response.idToken;
          /*
           * 获取到authCode之后，使用云函数获取用户信息,正常来说是拿AT给后台，后台利用AT调用rest api去拿正确的手机号
           * 云函数、云数据库开发指导 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/cloudfoundation-introduction-V5
           * */
          CloudFunction.getUserInfo(authCode).then((userInfo) => {
            commonToast.hideAll()
            if ((userInfo as CloudFunctionResult).result.ret.code === 0) {
              AppStorage.setOrCreate('isLogin', true)
              AppStorage.setOrCreate('userInfo', (userInfo as CloudFunctionResult).result.result[0])
              AppStorage.setOrCreate('unionID', unionID)
              /*
               * 如果是登录跳转过来的 pop直接跳过登录
               * */
              let allPath = this.pageInfos.getAllPathName()
              let currentPath = this.pageInfos.getIndexByName('LoginWithHuaweiIDComponent')
              if (allPath[currentPath[currentPath.length-1] -1] === 'Login') {
                this.pageInfos.clear();
                return
              }
              this.pageInfos.pop();
            }
          }).catch((err: BusinessError) => {
           this.mockUserLogin()
            commonToast.hideAll()
          })
        }
      } else {
        this.agreementDialog.open();
      }
    } catch (err) {
      hilog.error(this.domainId, this.logTag,
        `Failed to LoginWithHuaweiIDButton, errCode: ${err.code}, errMessage: ${err.message}`);
      this.mockUserLogin()
    }
  }

  // 错误处理
  dealAllError(error: BusinessError): void {
    hilog.error(this.domainId, this.logTag,
      `Failed to login, errorCode is ${error.code}, errorMessage is ${error.message}`);
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column() {
            Column() {
              Image($r('app.media.ic_start_icon'))
                .width(54)
                .height(54)
                .draggable(false)
                .copyOption(CopyOptions.None)
                .onComplete(() => {
                  hilog.info(this.domainId, this.logTag, 'appIcon loading success.');
                })
                .onError(() => {
                  hilog.error(this.domainId, this.logTag, 'appIcon loading fail.');
                })

              Text('政务模板')
                .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                .fontWeight(FontWeight.Medium)
                .fontWeight(FontWeight.Bold)
                .maxFontSize($r('sys.float.ohos_id_text_size_headline8'))
                .minFontSize($r('sys.float.ohos_id_text_size_body1'))
                .maxLines(1)
                .fontColor($r('sys.color.ohos_id_color_text_primary'))
                .constraintSize({ maxWidth: '100%' })
                .margin({
                  top: 12,
                })
            }.margin({
              top: 100,
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
                  top: 8,
                })
            }.margin({
              top: 64,
            })

            Column() {
              LoginWithHuaweiIDButton({
                params: {
                  // LoginWithHuaweiIDButton支持的样式
                  style: loginComponentManager.Style.BUTTON_RED,
                  // 账号登录按钮在登录过程中展示加载态
                  extraStyle: {
                    buttonStyle: new loginComponentManager.ButtonStyle().loadingStyle({
                      show: true,
                    }),
                  },
                  // LoginWithHuaweiIDButton的边框圆角半径
                  borderRadius: 24,
                  // LoginWithHuaweiIDButton支持的登录类型
                  loginType: loginComponentManager.LoginType.QUICK_LOGIN,
                  // LoginWithHuaweiIDButton支持按钮的样式跟随系统深浅色模式切换
                  supportDarkMode: true,
                  // verifyPhoneNumber：如果华为账号用户在过去90天内未进行短信验证，是否拉起Account Kit提供的短信验证码页面
                  verifyPhoneNumber: true,
                },
                controller: this.controller,
              })
            }
            .height(40)
            .margin({
              top: 56,
            })

            Column() {
              Column() {
                Text($r('app.string.login_in_other'))
                  .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.ohos_id_text_size_button1'))
                  .focusable(true)
                  .focusOnTouch(true)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
                  .padding({ left: 8, right: 8 })
              }
              .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
              .constraintSize({ minHeight: 40 })
              .justifyContent(FlexAlign.Center)
              .borderRadius(16)
              .width('100%')
              .onClick(() => {
                this.pageInfos.replacePathByName('Login', null)
              })
            }.margin({ top: 16 })
          }.width('100%')

          Row() {
            Row() {
              Checkbox({ name: 'privacyCheckbox', group: 'privacyCheckboxGroup' })
                .width(24)
                .height(24)
                .focusable(true)
                .focusOnTouch(true)
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
                        if (item.tag === LoginWithHuaweiIDComponent.USER_SERVICE_TAG) {
                          this.pageInfos.pushPathByName('TermsOfServicePage', null)
                        } else {
                          this.pageInfos.pushPathByName('PrivacyPolicyPage', null)
                        }
                      })
                  }
                }, (item: loginComponentManager.PrivacyText, index: number) => `${item.text}_${index}}`)
              }
              .width('100%')
            }
            .margin({ left: 12 })
            .layoutWeight(1)
            .constraintSize({ minHeight: 24 })
          }
          .alignItems(VerticalAlign.Center)
          .margin({
            bottom: Number(AppStorage.get('bottomRectHeight')),
          })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .constraintSize({ minHeight: '100%' })
        .margin({
          left: 16,
          right: 16,
        })
      }
      .width('100%')
      .height('100%')
      .padding({
        top: Number(AppStorage.get('topRectHeight')),
      })
    }
    .hideTitleBar(true)
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
  }
}

@CustomDialog
export struct AgreementDialog {
  logTag: string = 'AgreementDialog';
  domainId: number = 0x0000;
  dialogController?: CustomDialogController;
  cancel: () => void = () => {
  };
  confirm: () => void = () => {
  };
  clickHyperlinkText: () => void = () => {
  };
  privacyText: loginComponentManager.PrivacyText[] = [];

  build() {
    Column() {
      Row() {
        Text('用户协议与隐私条款')
          .id('loginPanel_agreement_dialog_privacy_title')
          .maxFontSize($r('sys.float.ohos_id_text_size_headline8'))
          .minFontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
      }
      .alignItems(VerticalAlign.Center)
      .constraintSize({ minHeight: 56, maxWidth: 400 })
      .margin({
        left: $r('sys.float.ohos_id_max_padding_start'),
        right: $r('sys.float.ohos_id_max_padding_start'),
      })

      Row() {
        Text() {
          ForEach(this.privacyText, (item: loginComponentManager.PrivacyText) => {
            if (item?.type === loginComponentManager.TextType.PLAIN_TEXT && item?.text) {
              Span(item?.text)
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .fontColor($r('sys.color.ohos_id_color_text_primary'))
                .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                .fontWeight(FontWeight.Regular)
            } else if (item?.type === loginComponentManager.TextType.RICH_TEXT && item?.text) {
              Span(item?.text)
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .fontColor('#CE0E2D')
                .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                .fontWeight(FontWeight.Medium)
                .focusable(true)
                .focusOnTouch(true)
            }
          }, (item: loginComponentManager.PrivacyText, index: number) => `${item.text}_${index}}`)
        }
        .width('100%')
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(10)
        .textAlign(TextAlign.Start)
        .focusable(true)
        .focusOnTouch(true)
        .padding({ left: 24, right: 24 })
      }.width('100%')

      Flex({
        direction: FlexDirection.Row,
      }) {
        Button('取消',
          { type: ButtonType.Capsule, stateEffect: true })
          .id('loginPanel_agreement_cancel_btn')
          .fontColor($r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.ohos_id_text_size_button1'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .backgroundColor(Color.Transparent)
          .fontWeight(FontWeight.Medium)
          .focusable(true)
          .focusOnTouch(true)
          .constraintSize({ minHeight: 40, maxWidth: 400 })
          .width('50%')
          .onClick(() => {
            hilog.info(this.domainId, this.logTag, 'AgreementDialog cancel.');
            this.cancel();
          })

        Button('同意并登录',
          { type: ButtonType.Capsule, stateEffect: true })
          .id('loginPanel_agreement_dialog_huawei_id_login_btn')
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor($r('sys.color.comp_background_emphasize'))
          .fontSize($r('sys.float.ohos_id_text_size_button1'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .fontWeight(FontWeight.Medium)
          .focusable(true)
          .focusOnTouch(true)
          .constraintSize({ minHeight: 40, maxWidth: 400 })
          .width('50%')
          .onClick(() => {
            hilog.info(this.domainId, this.logTag, 'AgreementDialog confirm.');
            this.confirm();
          })
      }
      .margin({
        top: 8,
        left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
        right: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
        bottom: 16,
      })
    }
    .padding({
      left: 16,
      right: 16,
    })
  }
}

export enum ErrorCode {
  // 账号未登录
  ERROR_CODE_LOGIN_OUT = 1001502001,
  // 该账号不支持一键登录，如儿童账号、海外账号
  ERROR_CODE_NOT_SUPPORTED = 1001500003,
  // 网络错误
  ERROR_CODE_NETWORK_ERROR = 1001502005,
  // 用户未同意用户协议
  ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED = 1005300001
}