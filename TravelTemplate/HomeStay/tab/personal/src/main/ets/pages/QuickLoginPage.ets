import { authentication, loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import promptAction from '@ohos.promptAction';
import { BusinessError } from '@kit.BasicServicesKit';
import { LoginErrorCode } from '../model/Index';
import { AgreementDialog } from 'component';
import { Logger } from 'util';
import { AccountUtil } from 'account';
import { Constants, NavPathName } from 'constant';

@Builder
export function QuickLoginPageBuilder() {
  QuickLoginPage();
}

@Component
export struct QuickLoginPage {
  logTag: string = 'QuickLoginButtonComponent';
  domainId: number = 0x0000;
  loginData: Record<string, Object> = {
    'isLogin': false,
    'show': '',
    'hint': '',
  };
  @State unionID: string = '';
  @State openID: string = '';
  // 是否勾选协议
  @State isSelected: boolean = false;
  // 弹窗是否已开启
  private customerDiaLogOpen: boolean = false;
  error?: BusinessError;
  response: loginComponentManager.HuaweiIDCredential = {} as loginComponentManager.HuaweiIDCredential;
  // 控制登录中不可点击协议和复选框的状态变量
  @State enableStatus: boolean = true;
  @State anonymousPhone: string = '';
  privacyText: loginComponentManager.PrivacyText[] = [{
    text: '已同意并阅读 ',
    type: loginComponentManager.TextType.PLAIN_TEXT,
  }, {
    text: '《用户协议》',
    type: loginComponentManager.TextType.RICH_TEXT,
  }, {
    text: ' 和 ',
    type: loginComponentManager.TextType.PLAIN_TEXT,
  }, {
    text: '《隐私政策》',
    type: loginComponentManager.TextType.RICH_TEXT,
  }, {
    text: '. ',
    type: loginComponentManager.TextType.PLAIN_TEXT,
  }];
  controller: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
      // 需要用户同意协议才能完成华为账号登录，请先设置协议状态为NOT_ACCEPTED，当用户同意协议后设置协议状态为ACCEPTED，才可以完成华为账号登录
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton((error: BusinessError, response: loginComponentManager.HuaweiIDCredential) => {
        // 处理用户点击一键登录按钮逻辑，灰度传入undefined模拟流程，应用申请权限后，传入error
        this.handleLoginWithHuaweiIDButton(undefined, response);
      });
  agreementDialog: CustomDialogController = new CustomDialogController({
    builder: AgreementDialog({
      privacyText: this.privacyText,
      cancel: () => {
        this.enableStatus = true;
        this.agreementDialog.close();
        this.customerDiaLogOpen = false;
        // 设置协议状态为NOT_ACCEPTED
        this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
      },
      confirm: () => {
        this.enableStatus = false;
        this.agreementDialog.close();
        this.customerDiaLogOpen = false;
        this.isSelected = true;
        // 设置协议状态为ACCEPTED
        this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
        if (this.error?.code === LoginErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
          this.handleLoginWithHuaweiIDButton(undefined, this.response);
        } else {
          this.handleLoginWithHuaweiIDButton(this.error, this.response);
        }
      },
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
  });
  @Consume('mainPathStack') mainPathStack: NavPathStack;

  aboutToAppear(): void {
    this.getQuickLoginAnonymousPhone();
  }

  // 处理点击一键登录后的方法
  handleLoginWithHuaweiIDButton(error: BusinessError | undefined,
    response: loginComponentManager.HuaweiIDCredential) {
    this.enableStatus = false;
    // if部分内容配置好可用的调试证书和client_id后再放开
    if (error) {
      Logger.error(this.domainId, this.logTag,
        `Failed to click LoginWithHuaweiIDButton. Code is ${error.code}, message is ${error.message}`);
      this.error = error;
      if (error.code === LoginErrorCode.ERROR_CODE_NETWORK_ERROR) {
        AlertDialog.show(
          {
            message: 'No Internet connection. Check your network settings. ',
            offset: { dx: 0, dy: -12 },
            alignment: DialogAlignment.Bottom,
            autoCancel: false,
            confirm: {
              value: 'OK',
              action: () => {
              },
            },
          },
        );
      } else if (error.code === LoginErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
        // 未同意协议，弹出协议弹框，推荐使用该回调方式
        this.agreementDialog.open();
        this.customerDiaLogOpen = true;
      } else if (error.code === LoginErrorCode.ERROR_CODE_LOGIN_OUT) {
        // 华为账号未登录提示
        this.showToast($r('app.string.not_login_in'));
      } else if (error.code === LoginErrorCode.ERROR_CODE_NOT_SUPPORTED) {
        // 账号不支持该scopes或permissions提示
        this.showToast($r('app.string.scope_not_supported'));
      } else if (error.code === LoginErrorCode.ERROR_CODE_NOT_REQUIRED_SCOPE_OR_PERMISSION) {
        // 应用没有申请scope权限
        this.showToast($r('app.string.app_not_required_scopes_or_permissions'));
      } else {
        // 其他提示系统或服务异常
        this.showToast($r('app.string.service_error'));
      }
      this.enableStatus = true;
      return;
    }
    try {
      if (this.isSelected) {
        // 配置好可用的调试证书和client_id后需要处理response
        Logger.info(this.domainId, this.logTag, 'Succeed in clicking LoginWithHuaweiIDButton.');
        if (this.response.unionID === undefined) {
          this.response = response;
        }
        // 模拟登录
        AppStorage.setOrCreate('currentUser', this.unionID);
        AppStorage.setOrCreate('openID', this.openID);
        this.mainPathStack.pop(AccountUtil.getCurrentUser());
      } else {
        this.agreementDialog.open();
        this.customerDiaLogOpen = true;
      }
    } catch (e) {
      Logger.info(this.domainId, this.logTag,
        `Failed to LoginWithHuaweiIDButton, errCode: ${e.code}, errMessage: ${e.message}`);
      AlertDialog.show(
        {
          message: $r('app.string.service_error'),
          offset: { dx: 0, dy: -12 },
          alignment: DialogAlignment.Bottom,
          autoCancel: false,
          confirm: {
            value: 'OK',
            action: () => {
            },
          },
        },
      );
    } finally {
      this.enableStatus = true;
    }
  }

  // Toast提示
  showToast(resource: Resource) {
    try {
      promptAction.showToast({
        message: resource,
        duration: 2000,
      });
    } catch (error) {
      let message = (error as BusinessError).message;
      let code = (error as BusinessError).code;
      Logger.error(this.domainId, this.logTag, `showToast args error code is ${code}, message is ${message}`);
    }
    ;
  }

  @Builder
  BuildSpan(content: ResourceStr, fontColor: ResourceStr, fontFamily: Resource, fontWight: number, textIndex: number,
    focusable?: boolean, focusOnTouch?: boolean) {
    Span(content)
      .fontSize($r('sys.float.ohos_id_text_size_body3'))
      .fontColor(fontColor)
      .fontFamily(fontFamily)
      .fontWeight(fontWight)
      .focusable(focusable)
      .focusOnTouch(focusOnTouch)
      .onClick(() => {
        if (this.enableStatus) {
          switch (textIndex) {
            case 1:
              this.mainPathStack.pushPathByName(NavPathName.TERMS_OF_SERVICE_PAGE, null);
              break;
            case 3:
              this.mainPathStack.pushPathByName(NavPathName.PRIVACY_POLICY_PAGE, null);
              break;
            default:
              break;
          }
        }
      });
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column() {
            Row() {
              Image($r('app.media.icon'))
                .width(80)
                .height(80)
                .draggable(false)
                .copyOption(CopyOptions.None)
                .borderRadius(20)
                .onComplete(() => {
                  Logger.info(this.domainId, this.logTag, 'Succeed in loading appIcon.');
                })
                .onError(() => {
                  Logger.error(this.domainId, this.logTag, 'Failed to load appIcon.');
                });
            }.margin({
              top: 44,
              left: 124,
              right: 124,
            });

            Column() {
              Text(this.anonymousPhone)
                .fontSize(36)
                .fontColor($r('sys.color.ohos_id_color_text_primary'))
                .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                .fontWeight(FontWeight.Bold)
                .lineHeight(48)
                .textAlign(TextAlign.Center)
                .maxLines(1)
                .constraintSize({ maxWidth: '100%', minHeight: 48 });

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
                });
            }.margin({
              top: 64,
            });

            Column() {
              LoginWithHuaweiIDButton({
                params: {
                  style: loginComponentManager.Style.BUTTON_CUSTOM,
                  loginType: loginComponentManager.LoginType.QUICK_LOGIN,
                  supportDarkMode: true,
                  customButtonParams: {
                    fontColor: loginComponentManager.FontColor.WHITE,
                    backgroundColor: '#007DFF',
                  },
                },
                controller: this.controller,
              });
            }
            .height(40)
            .width('100%')
            .constraintSize({ maxWidth: 448 })
            .margin({
              top: 56,
            });
          };

          Row() {
            Row() {
              Checkbox({ name: 'privacyCheckbox', group: 'privacyCheckboxGroup' })
                .width(20)
                .height(20)
                .focusable(true)
                .focusOnTouch(true)
                .selectedColor('#007DFF')
                .select(this.isSelected)
                .enabled(this.enableStatus)
                .margin({ top: 0 })
                .onChange((value: boolean) => {
                  Logger.info(this.domainId, this.logTag, `agreementChecked: ${value}`);
                  if (value) {
                    this.isSelected = true;
                    // 设置协议状态为ACCEPTED
                    this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
                  } else {
                    this.isSelected = false;
                    // 设置协议状态为NOT_ACCEPTED
                    this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
                  }
                });
            }

            Row() {
              Text() {
                if (this.privacyText && this.privacyText.length >= 5) {
                  this.BuildSpan(this.privacyText[0].text, $r('sys.color.ohos_id_color_text_secondary'),
                    $r('sys.string.ohos_id_text_font_family_regular'), FontWeight.Regular, 0);

                  this.BuildSpan(this.privacyText[1].text, '#007DFF',
                    $r('sys.string.ohos_id_text_font_family_medium'), FontWeight.Medium, 1, true, true);

                  this.BuildSpan(this.privacyText[2].text, $r('sys.color.ohos_id_color_text_secondary'),
                    $r('sys.string.ohos_id_text_font_family_regular'), FontWeight.Regular, 2);

                  this.BuildSpan(this.privacyText[3].text, '#007DFF',
                    $r('sys.string.ohos_id_text_font_family_medium'), FontWeight.Medium, 3, true, true);

                  this.BuildSpan(this.privacyText[4].text, $r('sys.color.ohos_id_color_text_secondary'),
                    $r('sys.string.ohos_id_text_font_family_regular'), FontWeight.Regular, 4);
                }
              }
            }
            .constraintSize({ minHeight: 24 });
          }
          .alignItems(VerticalAlign.Top)
          .width(Constants.FULL_SCREEN)
          .justifyContent(FlexAlign.Center)
          .margin({
            bottom: 44,
          });
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .constraintSize({ minHeight: '100%' })
        .margin({
          left: 16,
          right: 16,
        });
      }.backgroundColor('#F1F3F5');
    }
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .onShown(() => {
      if (this.customerDiaLogOpen) {
        this.agreementDialog.open();
      }
    })
    .backgroundColor('#F1F3F5');
  }

  getQuickLoginAnonymousPhone() {
    // 创建授权请求，并设置参数
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // 获取匿名手机号需传quickLoginAnonymousPhone这个scope，传参之前需要先申请“华为账号一键登录”权限
    authRequest.scopes = ['quickLoginAnonymousPhone'];
    // 用于防跨站点请求伪造
    authRequest.state = util.generateRandomUUID();
    // 一键登录场景该参数必须设置为false
    authRequest.forceAuthorization = false;
    const controller = new authentication.AuthenticationController();
    try {
      controller.executeRequest(authRequest).then((response: authentication.AuthorizationWithHuaweiIDResponse) => {
        // 获取到UnionID、OpenID、匿名手机号
        this.unionID = response.data?.unionID ?? '';
        this.openID = response.data?.openID ?? '';
        const anonymousPhone = response.data?.extraInfo?.quickLoginAnonymousPhone as string;
        if (anonymousPhone) {
          Logger.info(0x0000, 'testTag', 'Succeeded in authentication.');
          this.anonymousPhone = anonymousPhone;
          return;
        }
        Logger.info(0x0000, 'testTag', 'Succeeded in authentication. AnonymousPhone is empty.');
      }).catch((error: BusinessError) => {
        // 以下内容配置好可用的调试证书和client_id后删除，当前为模拟数据
        this.unionID = util.generateRandomUUID();
        this.openID = util.generateRandomUUID();
        this.anonymousPhone = '183******12';
      });
    } catch (error) {
      Logger.info('quick login failed ' + JSON.stringify(error));
    }
  }
}