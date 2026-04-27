import { authentication, loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { BarVM } from '@agctemplate/widgets'
import { BusinessError } from '@kit.BasicServicesKit';
import { LoginErrorCode, LoginType } from '../common/Constant';
import { AgreementDialog } from './AgreementDialog';
import Logger from '../common/Logger';
import { AggregatedLoginVM } from '../viewmodel/AggregatedLoginVM';
import { common } from '@kit.AbilityKit';
import { Channel } from '../model/Index';


@ComponentV2
export struct LoginService {
  vm: AggregatedLoginVM = AggregatedLoginVM.instance;
  /**
   * 应用icon
   */
  @Param icon: ResourceStr = '';
  /**
   * 隐私政策路由方法
   */
  @Param privacyPolicyEvent: () => void = () => {
  };
  /**
   * 用户协议路由方法
   */
  @Param termOfServiceEvent: () => void = () => {
  };
  /**
   * 登录成功回调
   */
  @Param loginFinishedCb: (flag: boolean, unionId?: string) => void = () => {
  };
  /**
   * 支持的登录渠道
   */
  @Require @Param loginTypes: Channel[] = [];
  /**
   * 一键登录按钮背景色
   */
  @Param loginBtnBgColor: ResourceStr = '';
  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  logTag: string = 'QuickLoginButtonComponent';
  domainId: number = 0x0000;
  loginData: Record<string, Object> = {
    'isLogin': false,
    'show': '',
    'hint': '',
  };
  @Local unionID: string = '';
  @Local openID: string = '';
  @Local channelInfo: Channel[] = [];
  // 是否勾选协议
  @Local isSelected: boolean = false;
  @Local isShow: boolean = false;
  // 弹窗是否已开启
  private customerDiaLogOpen: boolean = false;
  error?: BusinessError;
  response: loginComponentManager.HuaweiIDCredential = {} as loginComponentManager.HuaweiIDCredential;
  // 控制登录中不可点击协议和复选框的状态变量
  @Local enableStatus: boolean = true;
  @Local anonymousPhone: string = '';
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
      privacyPolicyEvent: this.privacyPolicyEvent,
      termOfServiceEvent: this.termOfServiceEvent,
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
  });

  aboutToAppear(): void {
    this.getQuickLoginAnonymousPhone();
    this.channelInfo = this.vm.createEvent(this.loginTypes);
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
        this.getUIContext().showAlertDialog(
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
        if (this.response.idToken !== undefined) {
          this.response = response;
          // 模拟登录成功后回调
          this.loginFinishedCb(true, this.unionID)
        }
        // 模拟登录成功后回调
        this.loginFinishedCb(false)
      } else {
        this.agreementDialog.open();
        this.customerDiaLogOpen = true;
      }
    } catch (e) {
      Logger.info(this.domainId, this.logTag,
        `Failed to LoginWithHuaweiIDButton, errCode: ${e.code}, errMessage: ${e.message}`);
      this.getUIContext().showAlertDialog(
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

  showToast(resource: Resource) {
    try {
      this.getUIContext().getPromptAction().showToast({
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
  loginTypeSheet() {
    Column() {
      Text('选择登录方式').fontSize(18).fontWeight(500);
      Row({ space: 16 }) {
        ForEach(this.channelInfo, (item: Channel) => {
          Image(item.icon).size({ width: 36, height: 36 }).borderRadius(18).onClick(() => {
            if (item.type === LoginType.WECHAT) {
              this.vm.wxLogin(item.extraInfo, this.getUIContext().getHostContext() as common.UIAbilityContext);
            }
          });
        }, (item: Channel) => item.name);
      };

      Row() {
        Text() {
          if (this.privacyText && this.privacyText.length >= 5) {
            this.BuildSpan(this.privacyText[0].text, $r('sys.color.ohos_id_color_text_secondary'),
              $r('sys.string.ohos_id_text_font_family_regular'), FontWeight.Regular, 0);

            this.BuildSpan(this.privacyText[1].text, $r('sys.color.font_primary'),
              $r('sys.string.ohos_id_text_font_family_medium'), FontWeight.Medium, 1, true, true);

            this.BuildSpan(this.privacyText[2].text, $r('sys.color.ohos_id_color_text_secondary'),
              $r('sys.string.ohos_id_text_font_family_regular'), FontWeight.Regular, 2);

            this.BuildSpan(this.privacyText[3].text, $r('sys.color.font_primary'),
              $r('sys.string.ohos_id_text_font_family_medium'), FontWeight.Medium, 3, true, true);

            this.BuildSpan(this.privacyText[4].text, $r('sys.color.ohos_id_color_text_secondary'),
              $r('sys.string.ohos_id_text_font_family_regular'), FontWeight.Regular, 4);
          }
        }
      }
      .constraintSize({ minHeight: 24 });
    }.height('100%').padding(16).justifyContent(FlexAlign.SpaceBetween)
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
              this.isShow = false;
              this.privacyPolicyEvent();
              break;
            case 3:
              this.isShow = false;
              this.termOfServiceEvent();
              break;
            default:
              break;
          }
        }
      });
  }

  build() {
    Column() {
      Column() {
        Row() {
          Image(this.icon)
            .width(72)
            .height(72)
            .draggable(false)
            .copyOption(CopyOptions.None)
            .onComplete(() => {
              Logger.info(this.domainId, this.logTag, 'Succeed in loading appIcon.');
            })
            .onError(() => {
              Logger.error(this.domainId, this.logTag, 'Failed to load appIcon.');
            });
        }.margin({
          top: 118,
        });

        Column() {
          Text(this.anonymousPhone)
            .fontSize($r('sys.float.Title_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
            .fontWeight(FontWeight.Bold)
            .lineHeight(40)
            .textAlign(TextAlign.Center)
            .maxLines(1);

          Text('华为账号绑定号码')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
            .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Center)
            .maxLines(1)
            .constraintSize({ maxWidth: '100%' })
            .margin({
              top: 4,
            });
        }.margin({
          top: 40,
        });

        Column() {
          LoginWithHuaweiIDButton({
            params: {
              style: loginComponentManager.Style.BUTTON_CUSTOM,
              loginType: loginComponentManager.LoginType.QUICK_LOGIN,
              supportDarkMode: true,
              customButtonParams: {
                fontColor: loginComponentManager.FontColor.WHITE,
                backgroundColor: this.loginBtnBgColor,
              },
            },
            controller: this.controller,
          });
        }
        .height(40)
        .width('100%')
        .constraintSize({ maxWidth: 448 })
        .margin({
          top: 48,
        });

        Column() {
          Button({
            type: ButtonType.Capsule,
            stateEffect: true,
          }) {
            Text('其他方式登录')
              .fontColor($r('sys.color.font_primary'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
              .fontWeight(FontWeight.Medium)
              .fontSize($r('sys.float.ohos_id_text_size_button1'))
              .focusable(true)
              .focusOnTouch(true)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .padding({ left: 8, right: 8 });
          }
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .focusable(true)
          .focusOnTouch(true)
          .width('100%')
          .constraintSize({ minHeight: 40, maxWidth: 448 })
          .onClick(() => {
            this.isShow = true;
          })
          .bindSheet($$this.isShow, this.loginTypeSheet(),
            { showClose: false, height: '20%' });
        }.width('100%').margin({ top: 12 });
      };

      Row({ space: 4 }) {
        Row() {
          Checkbox({ name: 'privacyCheckbox', group: 'privacyCheckboxGroup' })
            .width(20)
            .height(20)
            .focusable(true)
            .focusOnTouch(true)
            .selectedColor('#EC6E45')
            .select(this.isSelected)
            .enabled(this.enableStatus)
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
        };

        Row() {
          Text() {
            if (this.privacyText && this.privacyText.length >= 5) {
              this.BuildSpan(this.privacyText[0].text, $r('sys.color.ohos_id_color_text_secondary'),
                $r('sys.string.ohos_id_text_font_family_regular'), FontWeight.Regular, 0);

              this.BuildSpan(this.privacyText[1].text, $r('sys.color.font_primary'),
                $r('sys.string.ohos_id_text_font_family_medium'), FontWeight.Medium, 1, true, true);

              this.BuildSpan(this.privacyText[2].text, $r('sys.color.ohos_id_color_text_secondary'),
                $r('sys.string.ohos_id_text_font_family_regular'), FontWeight.Regular, 2);

              this.BuildSpan(this.privacyText[3].text, $r('sys.color.font_primary'),
                $r('sys.string.ohos_id_text_font_family_medium'), FontWeight.Medium, 3, true, true);

              this.BuildSpan(this.privacyText[4].text, $r('sys.color.ohos_id_color_text_secondary'),
                $r('sys.string.ohos_id_text_font_family_regular'), FontWeight.Regular, 4);

            }
          };
        }.layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 12 })

    }
    .constraintSize({ minHeight: '100%' })
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: 16,
      right: 16,
      top: BarVM.instance.staBarH,
      bottom: BarVM.instance.staBarH
    });
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