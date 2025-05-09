import { promptAction, router } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { RouteEntryVM, UserInfo } from 'common'
import { authentication, loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';

@Builder
export function LoginBuilder() {
  Login()
}

@Component
export struct Login {
  build() {
    NavDestination() {
      Column() {
        Column() {
          QuickLoginButtonComponent()
        }
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.comp_background_list_card'))
    }.hideTitleBar(false)
  }
}

@Component
struct QuickLoginButtonComponent {
  @StorageLink('isLogin') isLogin: boolean = AppStorage.get('isLogin') ?? false;
  vm: RouteEntryVM = RouteEntryVM.instance;
  logTag: string = 'QuickLoginButtonComponent';
  domainId: number = 0x0000;
  // 匿名化手机号
  @State quickLoginAnonymousPhone: string = '123****1234';
  // 是否勾选协议
  @State isSelected: boolean = false;
  private static USER_AUTHENTICATION_PROTOCOL: string =''
  private static USER_SERVICE_TAG = '用户服务协议';
  private static PRIVACY_TAG = '隐私协议';
  private static USER_AUTHENTICATION_TAG = '华为账号用户认证协议';
  // 定义LoginWithHuaweiIDButton展示的隐私文本，展示应用的用户服务协议、隐私协议和华为账号用户认证协议
  privacyText: loginComponentManager.PrivacyText[] = [{
    text: '已阅读并同意',
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: '《隐私协议》',
    tag: QuickLoginButtonComponent.PRIVACY_TAG,
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
        if (error) {
          this.dealAllError(error);
          return;
        }
        if (response) {
          // 获取到Authorization Code
          const authorizationCode = response.authorizationCode;
          hilog.info(0x0000, 'testTag', 'Succeeded in getting response.');
          this.loginWithHuawei()
          return;
        }
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
              `Failed to login with agreementDialog. errCode is ${error.code}, errMessage is ${error.message}`);
          } else {
            hilog.info(this.domainId, this.logTag,
              'Succeed in clicking agreementDialog continueLogin.');
          }
        });
      },
      clickHyperlinkText: () => {
        this.agreementDialog.close();
        this.jumpToPrivacyWebView();
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
  });

  aboutToAppear(): void {
    this.getQuickLoginAnonymousPhone()
  }

  // Toast提示
  showToast(resource: string) {
    try {
      promptAction.showToast({
        message: resource,
        duration: 2000,
        bottom: 80
      });
    } catch (error) {
      const message = (error as BusinessError).message
      const code = (error as BusinessError).code
      hilog.error(this.domainId, this.logTag, `showToast args  errCode is ${code}, errMessage is ${message}`);
    }
  }

  // 跳转华为账号用户认证协议页,该页面需在工程main_pages.json文件配置
  jumpToPrivacyWebView() {
    router.pushUrl({
      // 在工程main_pages.json文件配置跳转页，具体可参考AccountKit开发指南使用华为账号一键登录WebPage示例代码
      url: 'pages/WebPage',
      params: {
        isFromDialog: true,
        url: QuickLoginButtonComponent.USER_AUTHENTICATION_PROTOCOL,
      }
    }, (err) => {
      if (err) {
        hilog.error(this.domainId, this.logTag,
          `Failed to jumpToPrivacyWebView, errCode is ${err.code}, errMessage is ${err.message}`);
      }
    });
  }

  loginWithHuawei() {
    // 创建登录请求，并设置参数
    let authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    authRequest.scopes = ['profile'];
    authRequest.permissions = ['idtoken'];
    authRequest.forceAuthorization = true;
    authRequest.state = util.generateRandomUUID();
    authRequest.idTokenSignAlgorithm = authentication.IdTokenSignAlgorithm.PS256;
    // 执行登录请求，并处理结果
    try {
      let controller = new authentication.AuthenticationController(getContext(this));
      controller.executeRequest(authRequest, (err, data) => {
        if (err) {
          hilog.error(0x0000, 'testTag', 'login fail, error: %{public}s', JSON.stringify(err));
          return;
        }
        let loginWithHuaweiIDResponse = data as authentication.LoginWithHuaweiIDResponse;
        let state = loginWithHuaweiIDResponse.state;
        if (state !== undefined && authRequest.state !== state) {
          hilog.error(0x0000, 'testTag', 'login fail,The state is different: %{public}s',
            JSON.stringify(loginWithHuaweiIDResponse));
          return;
        }
        hilog.info(0x0000, 'testTag', 'login success, %{public}s', JSON.stringify(loginWithHuaweiIDResponse));

        let loginWithHuaweiIDCredential = loginWithHuaweiIDResponse.data!;
        // 登录成功
        AppStorage.setOrCreate('userInfo', loginWithHuaweiIDCredential)
        this.isLogin = true
        this.vm.pop();
      });
    } catch (error) {
      hilog.error(0x0000, 'testTag', 'login failed: %{public}s', JSON.stringify(error));
    }
  }
  mockUserLogin() {
    /*
     * mock登录数据
     * */
    let mockUserInfo: UserInfo = {
      'idToken': '',
      'nickName': '华为用户',
      'avatarUri': $r('app.media.hd_un_login'),
      'openID' : '',
      'unionID' : '',
      'phoneNumber': '123****1234',
    }
    AppStorage.setOrCreate('userInfo', mockUserInfo)
    AppStorage.setOrCreate('isLogin', true)
    this.vm.pop();
  }

  handleLoginWithHuaweiIDButton(error: BusinessError | undefined,
    response: loginComponentManager.HuaweiIDCredential) {
    if (error) {
      hilog.error(this.domainId, this.logTag,
        `Failed to login with LoginWithHuaweiIDButton. errCode is ${error.code}, errMessage is ${error.message}`);
      if (error.code === ErrorCode.ERROR_CODE_NETWORK_ERROR) {
        this.showNetWrong()
      }else if (error.code === ErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
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
          hilog.info(this.domainId, this.logTag, 'Succeed in clicking LoginWithHuaweiIDButton.');
          // 开发者根据实际业务情况使用以下信息
          const authCode = response.authorizationCode;
          const openID = response.openID;
          const unionID = response.unionID;
          const idToken = response.idToken;
        }
      } else {
        this.agreementDialog.open();
      }
    } catch (err) {
      hilog.error(this.domainId, this.logTag,
        `Failed to login with LoginWithHuaweiIDButton, errCode: ${err.code}, errMessage: ${err.message}`);
      this.mockUserLogin()
    }
  }

  showNetWrong(){
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

  // 错误处理
  dealAllError(error: BusinessError): void {
    hilog.error(this.domainId, this.logTag,
      `Failed to login, errorCode is ${error.code}, errorMessage is ${error.message}`);
  }

  getQuickLoginAnonymousPhone() {
    // 创建授权请求，并设置参数
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // 获取匿名手机号需传quickLoginAnonymousPhone这个scope，传参之前需要先申请“华为账号一键登录”权限
    //(权限名称为：quickLoginMobilePhone),后续才能获取匿名手机号数据
    authRequest.scopes = ['quickLoginAnonymousPhone'];
    // 用于防跨站点请求伪造
    authRequest.state = util.generateRandomUUID();
    // 一键登录场景该参数只能设置为false
    authRequest.forceAuthorization = false;
    const controller = new authentication.AuthenticationController();
    try {
      controller.executeRequest(authRequest).then((response: authentication.AuthorizationWithHuaweiIDResponse) => {
        // 获取到UnionID、OpenID、匿名手机号
        const unionID = response.data?.unionID;
        const openID = response.data?.openID;
        const anonymousPhone = response.data?.extraInfo?.quickLoginAnonymousPhone as string;
        if (anonymousPhone) {
          hilog.info(this.domainId, this.logTag, 'Succeeded in authentication.');
          this.quickLoginAnonymousPhone = anonymousPhone;
          return;
        }
        hilog.info(this.domainId, this.logTag, 'Succeeded in authentication. AnonymousPhone is empty.');
        // 未获取到匿名手机号需要跳转到应用自定义的登录页面
      }).catch((error: BusinessError) => {
        this.dealAllError(error);
      })
    } catch (error) {
      this.dealAllError(error);
    }
  }

  build() {
    Scroll() {
      Column() {

        Column() {
          Column() {
            Image($r('app.media.logo'))
              .width(48)
              .height(48)
              .draggable(false)
              .copyOption(CopyOptions.None)
              .onComplete(() => {
                hilog.info(this.domainId, this.logTag, 'appIcon loading success.');
              })
              .onError(() => {
                hilog.error(this.domainId, this.logTag, 'appIcon loading fail.');
              })

            Text('公交模板')
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

            Text('') // 应用描述
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
                      // 隐私协议
                      if (item.tag === QuickLoginButtonComponent.PRIVACY_TAG) {
                        this.vm.toRouteDetail('PrivacyPolicyDetailPage');
                      }
                    })
                }
              }, (item: loginComponentManager.PrivacyText, index: number) => {
                return item?.tag + index.toString();
              })
            }
            .width('100%')
          }
          .margin({ left: 12 })
          .layoutWeight(1)
          .constraintSize({ minHeight: 24 })
        }
        .alignItems(VerticalAlign.Top)
        .margin({
          bottom: 16,
          top: 16
        })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .constraintSize({ minHeight: '100%' })
      .margin({
        left: 16,
        right: 16
      })
    }
    .width('100%')
    .height('100%')
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
  private static USER_AUTHENTICATION_TAG = '华为账号用户认证协议';

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
        right: $r('sys.float.ohos_id_max_padding_start')
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
                .onClick(() => {
                  // 应用需要根据item.tag实现协议页面的跳转逻辑
                  hilog.info(this.domainId, this.logTag, `click privacy text tag: ${item.tag}`);
                  // 华为账号用户认证协议
                  if (item.tag === AgreementDialog.USER_AUTHENTICATION_TAG) {
                    hilog.info(this.domainId, this.logTag, 'AgreementDialog click.');
                    this.clickHyperlinkText();
                  }
                })
            }
          }, (item: loginComponentManager.PrivacyText, index: number) => {
            return item?.tag + index.toString();
          })
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
        direction: FlexDirection.Row
      }) {
        Button('取消',
          { type: ButtonType.Capsule, stateEffect: true })
          .id('loginPanel_agreement_cancel_btn')
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
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
          .backgroundColor($r('app.color.system_color_green'))
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
        bottom: 16
      })
    }
    .padding({
      left: 16,
      right: 16
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