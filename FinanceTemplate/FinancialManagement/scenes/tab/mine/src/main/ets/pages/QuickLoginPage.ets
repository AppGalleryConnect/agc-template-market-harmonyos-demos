import { hilog } from '@kit.PerformanceAnalysisKit';
import { authentication, loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { MinePageVM } from '../viewModels/MinePageVM';
import { FormatUtil, RouterMap, RouterModule } from 'commonlib';
import { util } from '@kit.ArkTS';

@Builder
export function QuickLoginPageBuilder() {
  QuickLoginPage();
}

@ComponentV2
export struct QuickLoginPage {
  vm: MinePageVM = MinePageVM.instance
  logTag: string = 'QuickLoginPage';
  domainId: number = 0x0000;
  @Local anonymousPhone: string = ''
  privacyText: loginComponentManager.PrivacyText[] = [{
    text: '已阅读并同意',
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: '《用户服务协议》 ',
    tag: '用户服务协议',
    type: loginComponentManager.TextType.RICH_TEXT
  }, {
    text: '《隐私协议》',
    tag: '隐私协议',
    type: loginComponentManager.TextType.RICH_TEXT
  }, {
    text: '和',
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: '《华为账号用户认证协议》',
    tag: '华为账号用户认证协议',
    type: loginComponentManager.TextType.RICH_TEXT
  }];
  controller: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
      // Users need to accept relevant agreements before they can sign in wth HUAWEI IDs.
      // Set the agreement status to NOT_ACCEPTED first. Once the user accepts the agreements,
      // change the agreement status to ACCEPTED to complete HUAWEI ID sign-in.
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton((error: BusinessError, response: loginComponentManager.HuaweiIDCredential) => {
        // Process the logic of a tap on the one-tap sign-in button.
        this.handleLoginWithHuaweiIDButton(error, response);
        if (error) {

        }
      });
  @Local quickLoginAnonymousPhone: string = '';
  // Specify whether to accept the agreements.
  @Local isSelected: boolean = false;
  // Specify whether to display a message asking the user to accept the agreements.
  @Local showPopUp: boolean = false;
  // Variable that determines whether the agreement and checkbox are unavailable for tapping during the sign-in process.
  @Local enableStatus: boolean = true;

  aboutToAppear(): void {
    this.getQuickLoginAnonymousPhone()
  }

  // Method that processes a tap on the one-tap sign-in button.
  handleLoginWithHuaweiIDButton(error: BusinessError | undefined, response: loginComponentManager.HuaweiIDCredential) {
    this.enableStatus = false;
    if (error) {
      hilog.error(this.domainId, this.logTag,
        `Failed to login with LoginWithHuaweiIDButton. errCode is ${error.code}, errMessage is ${error.message}`);
      this.enableStatus = true;
      if (this.isSelected) {
        this.vm.login()
        AppStorage.setOrCreate<boolean>('isLogin', true);
        RouterModule.pop()
        let uerInfo: emitter.EventData = {
          data: {
            isLogin: true,
          },
        };
        emitter.emit('isLogin', uerInfo);
      } else {
        this.showPopUp = true
      }
      return;
    }
    try {
      if (this.isSelected) {
        if (response) {
          hilog.info(this.domainId, this.logTag, 'Succeeded in clicking LoginWithHuaweiIDButton.');
          const authCode = response.authorizationCode;
          const openID = response.openID;
          const unionID = response.unionID;
          const idToken = response.idToken;
          this.vm.login()
          AppStorage.setOrCreate<boolean>('isLogin', true);
          let uerInfo: emitter.EventData = {
            data: {
              isLogin: true,
              userName: '华为用户',
              phone: this.quickLoginAnonymousPhone
            },
          };
          emitter.emit('isLogin', uerInfo);

          RouterModule.pop()
        }
      } else {
        this.showPopUp = true;
      }
    } catch (error) {
      if (this.isSelected) {
        this.vm.login()
        AppStorage.setOrCreate<boolean>('isLogin', true);
        RouterModule.pop()
        let uerInfo: emitter.EventData = {
          data: {
            isLogin: true,
          },
        };
        emitter.emit('isLogin', uerInfo);
      } else {
        this.showPopUp = true
      }
      hilog.error(this.domainId, this.logTag,
        `Failed to login with LoginWithHuaweiIDButton. errCode is ${error.code}, errMessage is ${error.message}`);
      if (this.isSelected) {
        this.vm.login()
        AppStorage.setOrCreate<boolean>('isLogin', true);
        RouterModule.pop()
        let uerInfo: emitter.EventData = {
          data: {
            isLogin: true,
          },
        };
        emitter.emit('isLogin', uerInfo);
      } else {
        this.showPopUp = true
      }
    } finally {
      this.enableStatus = true;
    }
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Column() {
              Row() {
                Image($r('app.media.app_icon'))
                  .width(100)
                  .aspectRatio(1)
                  .draggable(false)
                  .copyOption(CopyOptions.None)
                  .borderRadius(20)
                  .onComplete(() => {
                    hilog.info(this.domainId, this.logTag, 'Succeeded in loading appIcon.');
                  })
                  .padding({
                    top: 10,
                  })
                  .onError(() => {
                    hilog.error(this.domainId, this.logTag, 'Failed to load appIcon.');
                  });
              }
              .padding({
                top: 50,
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
            }
            .width('100%')

            Column() {
              Column() {
                LoginWithHuaweiIDButton({
                  params: {
                    style: loginComponentManager.Style.BUTTON_RED,
                    extraStyle: {
                      buttonStyle: new loginComponentManager.ButtonStyle().loadingStyle({
                        show: true,
                      }),
                    },
                    loginType: loginComponentManager.LoginType.QUICK_LOGIN,
                  },
                  controller: this.controller,
                }).id('login_with_huaweiId_button');
              }
              .height(40)
              .width('100%')
              .constraintSize({ maxWidth: 448 })
              .margin({ top: 50 });
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween);
          }
          .padding({
            left: 16,
            right: 16,
          })
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .scrollBar(BarState.Off)
      }
      .height('calc(100% - 56vp)')

      Flex({
        justifyContent: FlexAlign.Center,
        alignItems: ItemAlign.Start,
      }) {
        Row() {
          Checkbox({ name: 'privacyCheckbox', group: 'privacyCheckboxGroup' })
            .width(24)
            .height(24)
            .focusable(true)
            .focusOnTouch(true)
            .selectedColor('#CE0E2D')
            .select(this.isSelected)
            .enabled(this.enableStatus)
            .margin({ top: 0 })
            .onChange((value: boolean) => {
              hilog.info(this.domainId, this.logTag, `agreementChecked: ${value}`);
              if (value) {
                this.isSelected = true;
                this.showPopUp = false;
                // Set the agreement status to ACCEPTED.
                this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
              } else {
                this.isSelected = false;
                // Set the agreement status to NOT_ACCEPTED.
                this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
              }
            });
        }
        .padding({ right: 12 })

        Row() {
          Text() {
            if (this.privacyText && this.privacyText.length > 0) {
              ForEach(this.privacyText, (item: loginComponentManager.PrivacyText) => {
                if (item?.type === loginComponentManager.TextType.PLAIN_TEXT && item?.text) {
                  Span(item?.text)
                    .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                    .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                    .fontWeight(FontWeight.Regular)
                    .fontSize($r('sys.float.ohos_id_text_size_body3'))
                    .onClick(() => {
                      if (item.tag) {
                        FormatUtil.jumpToNext(RouterMap.PRIVACY, item.tag)
                      }
                    })
                } else if (item?.type === loginComponentManager.TextType.RICH_TEXT && item?.text) {
                  Span(item?.text)
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                    .fontWeight(FontWeight.Medium)
                    .fontSize($r('sys.float.ohos_id_text_size_body3'))
                    .focusable(true)
                    .focusOnTouch(true)
                    .enabled(this.enableStatus)
                    .id('quickLoginProtocolUrlSpan')
                    .onClick(() => {
                      if (item.tag) {
                        FormatUtil.jumpToNext(RouterMap.PRIVACY, item.tag)
                      }
                    });
                }
              }, (item: loginComponentManager.PrivacyText, index: number) => `${item.text}_${index}}`);
            }
          };
        }
        .constraintSize({ minHeight: 24 });
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .title('登录')
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((cxt: NavDestinationContext) => {
      let params = cxt.pathInfo.param as Record<string, Object>;
      if (params && params !== null) {
        this.quickLoginAnonymousPhone = params.anonymousPhone as string;
      }
    })
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
        // 获取到匿名手机号
        const anonymousPhone = response.data?.extraInfo?.quickLoginAnonymousPhone as string;
        if (anonymousPhone) {
          hilog.info(0x0000, 'testTag', 'Succeeded in authentication.');
          this.anonymousPhone = anonymousPhone
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in authentication. AnonymousPhone is empty.');
      }).catch((error: BusinessError) => {
        // 以下内容配置好可用的调试证书和client_id后删除，当前为写死虚拟号码
        this.anonymousPhone = '100****0000'
        hilog.error(0x0000, 'testTag',
          `Failed to get quickLoginAnonymousPhone, errorCode is ${error.code}, errorMessage is ${error.message}`);
      })
    } catch (error) {
      hilog.error(0x0000, 'testTag',
        `Failed to get quickLoginAnonymousPhone, errorCode is ${error.code}, errorMessage is ${error.message}`);
    }
  }
}
