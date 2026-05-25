import { hilog } from '@kit.PerformanceAnalysisKit';
import { loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { connection } from '@kit.NetworkKit';
import { common } from '@kit.AbilityKit';
import { buffer } from '@kit.ArkTS';
import {  showToast, AccountUtil, CommonConstants, CommonModel } from '@ohos_agcit/driver_license_exam_commonlib';
import { dealAllError,ErrorCode } from '../../common/LoginConstants';


@Builder
export function QuickLoginPageBuilder() {
  QuickLoginPage();
}

const PRIVACY_URL = 'privacy_url';

@ComponentV2
export struct QuickLoginPage {
  logTag: string = 'QuickLoginPage';
  domainId: number = 0x0000;
  // File used to configure the link to the HUAWEI ID User Authentication Agreement.
  private readonly srcPath = 'data.json';
  // params?: Record<string, Object>;
  privacyText: loginComponentManager.PrivacyText[] = [
    {
      text: $r('app.string.read_and_agree'),
      type: loginComponentManager.TextType.PLAIN_TEXT,
    },
    {
      text: $r('app.string.app_user_agreement'),
      type: loginComponentManager.TextType.RICH_TEXT,
      // Change the link to that of your own privacy policy.
      // ...
      tag: '',
    }, {
    text: $r('app.string.app_privacy_policy'),
    type: loginComponentManager.TextType.RICH_TEXT,
    // Change the link to that of your own privacy policy.
    // ...
    tag: 'privacy_policy',
  }, {
    text: $r('app.string.and'),
    type: loginComponentManager.TextType.PLAIN_TEXT,
  }, {
    text: $r('app.string.huaweiId_user_authentication_protocol'),
    type: loginComponentManager.TextType.RICH_TEXT,
    tag: this.getProtocolUrl(PRIVACY_URL),
  }, {
    text: $r('app.string.end'),
    type: loginComponentManager.TextType.PLAIN_TEXT,
  }];
  controller: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
      // Users need to accept relevant agreements before they can sign in wth HUAWEI IDs.
      // Set the agreement status to NOT_ACCEPTED first. Once the user accepts the agreements,
      // change the agreement status to ACCEPTED to complete HUAWEI ID sign-in.
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton((error: BusinessError, response: loginComponentManager.HuaweiIDCredential) => {
        // Process the logic of a tap on the one-tap sign-in button.

        // 如果错误，进入mock登录，真实场景需要删除if分支
        if (error) {
          if (this.isSelected) {
            AccountUtil.getAccountInfo().openID = '1';
            AccountUtil.getAccountInfo().unionID = '1';
            AccountUtil.getAccountInfo().idToken = '1';
            AccountUtil.getAccountInfo().authorizationCode = '1';
            AccountUtil.getUserInfo().nickname = $r('app.string.huawei_user');
            AccountUtil.getUserInfo().phone = this.quickLoginAnonymousPhone;
            this.vm.navStack.pop();
          } else {
            // If the agreements are not accepted, a pop-up message is displayed.
            this.showPopUp = true;
          }

        } else{
          this.handleLoginWithHuaweiIDButton(error, response);
          if (error) {
            dealAllError(error);
          }
        }
      });
  @Local quickLoginAnonymousPhone: string = '';
  // Specify whether to accept the agreements.
  @Local isSelected: boolean = false;
  // Specify whether to display a message asking the user to accept the agreements.
  @Local showPopUp: boolean = false;
  // Variable that determines whether the agreement and checkbox are unavailable for tapping during the sign-in process.
  @Local enableStatus: boolean = true;

  vm: CommonModel = CommonModel.instance;


  // Method that processes a tap on the one-tap sign-in button.
  handleLoginWithHuaweiIDButton(error: BusinessError | undefined, response: loginComponentManager.HuaweiIDCredential) {
    this.enableStatus = false;
    if (error) {
      hilog.error(this.domainId, this.logTag,
        `Failed to login with LoginWithHuaweiIDButton. errCode is ${error.code}, errMessage is ${error.message}`);
      if (error.code === ErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
        // If the agreements are not accepted, a pop-up message is displayed.
        this.showPopUp = true;
      } else {
        showToast(error, this.getUIContext());
      }
      this.enableStatus = true;
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
          AccountUtil.getAccountInfo().openID = openID;
          AccountUtil.getAccountInfo().unionID = unionID;
          AccountUtil.getAccountInfo().idToken = idToken;
          AccountUtil.getAccountInfo().authorizationCode = authCode;
          AccountUtil.getUserInfo().nickname = $r('app.string.huawei_user')
          AccountUtil.getUserInfo().phone = this.quickLoginAnonymousPhone;
          // todo 待实现
          this.vm.navStack.pop();
        }
      } else {
        // If the agreements are not accepted, a pop-up message is displayed.
        this.showPopUp = true;
      }
    } catch (error) {
      hilog.error(this.domainId, this.logTag,
        `Failed to login with LoginWithHuaweiIDButton. errCode is ${error.code}, errMessage is ${error.message}`);
      showToast(error as BusinessError, this.getUIContext());
    } finally {
      this.enableStatus = true;
    }
  }

  // Redirect to the HUAWEI ID User Authentication Agreement page.
  jumpToPrivacyWebView(privacyText: loginComponentManager.PrivacyText) {
    if (!this.enableStatus) {
      return;
    }
    if (privacyText.tag === 'privacy_policy') {
      // 直接跳转到隐私协议页面
      this.vm.navStack.pushPathByName('PrivacyAgreement', undefined);
      return;
    }
    const hasNet: boolean = connection.hasDefaultNetSync();
    if (!hasNet) {
      const hint: string = (this.getUIContext().getHostContext() as Context).resourceManager.getStringSync($r('app.string.hwid_no_internet_connect').id);
      showToast(hint, this.getUIContext());
      return;
    }
    if (privacyText.tag && privacyText.tag !== '') {
      // Obtain the multi-language environment information of the system.
      const systemLanguage: string = (this.getUIContext().getHostContext() as common.UIExtensionContext).config.language ?? '';
      hilog.info(this.domainId, this.logTag, `systemLanguage is ${systemLanguage}`);
      const params: Record<string, Object> = { 'protocolUrl': privacyText.tag + systemLanguage };
      // Concatenate link parameters.
      this.vm.navStack.pushPathByName('PrivacyAgreement', params);
    }
  }

  // Obtain the privacy policy address from rawfile.
  getProtocolUrl(privacyUrl: string): string {
    try {
      // Read files from /AppScope/resources/rawfile.
      const context = this.getUIContext().getHostContext() as Context;
      const value: Uint8Array = context.resourceManager.getRawFileContentSync(this.srcPath);
      // Return the link to the HUAWEI ID User Authentication Agreement.
      return JSON.parse(buffer.from(value.buffer).toString())[privacyUrl] as string;
    } catch (error) {
      hilog.error(this.domainId, this.logTag,
        `getProtocolUrl Error. errCode is ${error.code}, errMessage is ${error.message}`);
      return '';
    }
  }

  build() {
    NavDestination() {
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

          // Mobile number and its description.
          Column() {
            Text(this.quickLoginAnonymousPhone)
              .fontSize(36)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
              .fontWeight(FontWeight.Bold)
              .lineHeight(48)
              .height(48)
              .textAlign(TextAlign.Center)
              .maxLines(1)
              .maxFontScale(1)
              .constraintSize({ maxWidth: CommonConstants.FULL_PERCENT, minHeight: 48 });

            Text($r('app.string.bind_huaweiId_number'))
              .fontSize(12)
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
              .fontWeight(FontWeight.Regular)
              .lineHeight(16)
              .height(16)
              .textAlign(TextAlign.Center)
              .maxLines(1)
              .maxFontScale(1)
              .constraintSize({ maxWidth: CommonConstants.FULL_PERCENT })
              .margin({ top: 8 });
          }
          .margin({ top: 50 });
        }
        .width(CommonConstants.FULL_PERCENT);

        Column() {
          // One-tap sign-in.
          Column() {
            LoginWithHuaweiIDButton({
              params: {
                style: loginComponentManager.Style.BUTTON_CUSTOM,
                extraStyle: {
                  buttonStyle: new loginComponentManager.ButtonStyle().loadingStyle({
                    show: true,
                  }).backgroundColor('rgba(100, 187, 92, 1)'),
                },
                loginType: loginComponentManager.LoginType.QUICK_LOGIN,
                customButtonParams:{
                  backgroundColor: 'rgba(100, 187, 92, 1)'
                }
              },
              controller: this.controller,
            }).id('login_with_huaweiId_button')
          }
          .height(40)
          .width(CommonConstants.FULL_PERCENT)
          .constraintSize({ maxWidth: 448 })
          .margin({ top: 50 });

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
                .selectedColor($r('sys.color.comp_background_emphasize'))
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
            .bindPopup(this.showPopUp, {
              message: (this.getUIContext().getHostContext() as Context).resourceManager.getStringSync($r('app.string.read_and_agree_protocol').id),
              onStateChange: (event) => {
                this.showPopUp = event.isVisible;
              },
              mask: false,
            });

            Row() {
              Text() {
                if (this.privacyText && this.privacyText.length > 0) {
                  ForEach(this.privacyText, (item: loginComponentManager.PrivacyText) => {
                    if (item?.type === loginComponentManager.TextType.PLAIN_TEXT && item?.text) {
                      Span(item?.text)
                        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                        .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                        .fontWeight(FontWeight.Regular)
                        .fontSize($r('sys.float.ohos_id_text_size_body3'));
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
                          hilog.info(this.domainId, this.logTag, 'Click protocol url');
                          if (this.enableStatus) {
                            try {
                              // this.appPathStack?.pushPathByName('PrivacyAgreement', undefined);
                              this.jumpToPrivacyWebView(item);
                            } catch (error) {
                              const code: number = error.code;
                              const message: string = error.message;
                              hilog.error(this.domainId, this.logTag,
                                `Failed to jump privacy webview. errCode is ${code}, errMessage is ${message}`);
                            }
                          }
                        });
                    }
                  }, (item: loginComponentManager.PrivacyText, index: number) => `${item.text}_${index}}`);
                }
              }
              .maxFontScale(1)
            }
            .constraintSize({ minHeight: 24 });
          }
          .width(CommonConstants.FULL_PERCENT)
          .margin({ bottom: 16 });
        }
        .width(CommonConstants.FULL_PERCENT)
        .height('60%')
        .justifyContent(FlexAlign.SpaceBetween);
      }
      .padding({
        left: 16,
        right: 16,
        top: 36,
        bottom: 28,
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.background_secondary'))
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    }
    .onReady((cxt: NavDestinationContext) => {
      let params = cxt.pathInfo.param as Record<string, Object>;
      if (params && params !== null) {
        this.quickLoginAnonymousPhone = params.anonymousPhone as string;
      }
    })
    .onBackPressed(() => {
      this.vm.navStack.pop();
      return true;
    })
    .hideTitleBar(true);
  }
}
