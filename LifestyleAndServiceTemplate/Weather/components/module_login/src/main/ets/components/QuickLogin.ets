/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { AccountUtil } from '../utils/AccountUtil';
import { UserInfo } from '../model/UserInfo';
import { ErrorCode } from '../model/ErrorCode';
import { AgreementDialog } from './AgreementDialog';

@ComponentV2
export struct QuickLogin {
  logTag: string = 'QuickLoginButtonComponent';
  domainId: number = 0x0000;
  // 是否勾选协议
  @Local isSelected: boolean = false;
  // 参考华为账号开发指南获取匿名手机号
  @Local quickLoginAnonymousPhone: string = '';
  @Param @Require icon: ResourceStr
  @Param @Require loginBtnBgColor: string | ResourceStr
  @Param @Require appName: string = ''
  @Param horizontalMargin: number = 16;
  // 华为账号用户认证协议链接，此处仅为示例，实际开发过程中，出于可维护性、安全性等方面考虑，域名不建议硬编码在本地
  private static USER_AUTHENTICATION_PROTOCOL: string = ''
  // 是否为mock数据
  @Local isMock: boolean = true;
  // 展示用户服务协议、隐私协议和华为账号用户认证协议
  privacyText: loginComponentManager.PrivacyText[] = [{
    text: '已阅读并同意',
    type: loginComponentManager.TextType.PLAIN_TEXT,
  }, {
    text: '《用户服务协议》 ',
    tag: '用户服务协议',
    type: loginComponentManager.TextType.RICH_TEXT,
  }, {
    text: '《' + this.appName + '隐私协议》',
    tag: '隐私协议',
    type: loginComponentManager.TextType.RICH_TEXT,
  }, {
    text: '和',
    type: loginComponentManager.TextType.PLAIN_TEXT,
  }, {
    text: '《华为账号用户认证协议》',
    tag: '华为账号用户认证协议',
    type: loginComponentManager.TextType.RICH_TEXT,
  }];
  /*
* 华为一键登录点击事件
* */
  @Event onLoginWithHuaweiID: () => void = () => {
  }
  /*
   * 隐私协议点击事件
   * */
  @Event onPrivacyPolicy: () => void = () => {
  }
  /*
   * 服务协议点击事件
   * */
  @Event onServicePolicy: () => void = () => {
  }
  /*
   * 华为用户账号认证点击事件
   * */
  @Event onHYAccountRouter: () => void = () => {
  }
  private static USER_AUTHENTICATION_TAG = '华为账号用户认证协议';
  private static USER_SERVICE_TAG = '用户服务协议';
  private static USER_PRIVACY_TAG = '隐私协议';
  // 构造LoginWithHuaweiIDButton组件的控制器
  controller: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
    /**
     * 当应用使用自定义的登录页时，如果用户未同意协议，需要设置协议状态为NOT_ACCEPTED，当用户同意协议后再设置
     * 协议状态为ACCEPTED，才可以使用华为账号一键登录功能
     */
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton((error: BusinessError, response: loginComponentManager.HuaweiIDCredential) => {
        this.handleLoginWithHuaweiIDButton(error, response);
      })
      .onClickEvent((error: BusinessError, clickEvent: loginComponentManager.ClickEvent) => {
        if (error) {
          this.dealAllError(error);
          return;
        }
        hilog.info(0x0000, 'testTag', `onClickEvent clickEvent: ${clickEvent}`);
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
        if (this.isMock) {
          this.onLoginWithHuaweiID()
          let prop = PersistenceV2.connect(UserInfo, () => new UserInfo())!
          prop.isLogin = true
          prop.isLogin = true
          prop.id = 0
          prop.name = '测试账号'
          prop.cellphone = '177******96'
          prop.address = 'xxx省xxx市'
          PersistenceV2.save(UserInfo)
          return
        }
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
      },
      clickHyperlinkText: (tag) => {
        this.agreementDialog.close();
        if (tag === QuickLogin.USER_AUTHENTICATION_TAG) {
          this.onHYAccountRouter();
        } else if (tag === QuickLogin.USER_SERVICE_TAG) {
          this.onServicePolicy()
        } else if (tag === QuickLogin.USER_PRIVACY_TAG) {
          this.onPrivacyPolicy()
        }
      },
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
  });

  // 错误处理
  dealAllError(error: BusinessError): void {
    hilog.error(0x0000, 'testTag', `Failed to login, errorCode=${error.code}, errorMsg=${error.message}`);
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
    // 本地mock登录
    if (this.isMock) {
      if (this.isSelected) {
        this.onLoginWithHuaweiID()
        let prop = PersistenceV2.connect(UserInfo, () => new UserInfo())!
        prop.isLogin = true
        prop.id = 0
        prop.name = '测试账号'
        prop.cellphone = '177******96'
        prop.address = 'xxx省xxx市'
        PersistenceV2.save(UserInfo)
      } else {
        this.agreementDialog.open();
      }
      return
    }
    if (error) {
      hilog.error(this.domainId, this.logTag,
        `Failed to login with LoginWithHuaweiIDButton. errCode is ${error.code}, errMessage is ${error.message}`);
      if (error.code === ErrorCode.ERROR_CODE_NETWORK_ERROR) {
        this.showToast('网络异常，请检查网络设置。');
      } else if (error.code === ErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
        // 未同意协议，弹出协议弹框，推荐使用该回调方式
        this.agreementDialog.open();
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
        this.showToast('服务或网络异常，请稍后重试');
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
          const authorizationCode: string = response.authorizationCode;
          this.onLoginWithHuaweiID()
        }
      } else {
        this.agreementDialog.open();
      }
    } catch (err) {
      hilog.error(this.domainId, this.logTag,
        `Failed to login with LoginWithHuaweiIDButton, errCode: ${err.code}, errMessage: ${err.message}`);
      this.getUIContext().showAlertDialog({
        message: '服务或网络异常，请稍后重试',
        offset: { dx: 0, dy: -12 },
        alignment: DialogAlignment.Bottom,
        autoCancel: false,
        confirm: {
          value: '知道了',
          action: () => {
          },
        },
      },
      );
    }
  }

  aboutToAppear(): void {
    if (AccountUtil.getQuickLoginAnonymousPhone()) {
      this.quickLoginAnonymousPhone = AccountUtil.getQuickLoginAnonymousPhone()
      this.isMock = false
    } else {
      this.quickLoginAnonymousPhone = '177******96'
      this.isMock = true
    }
  }

  build() {
    Scroll() {
      Column() {
        Column() {
          Column()
            .layoutWeight(1)
            .constraintSize({
              minHeight: 24,
              maxHeight: 154,
            })
          Column() {
            Image(this.icon)
              .width(48)
              .height(48)
              .draggable(false)
              .copyOption(CopyOptions.None)
              .onComplete(() => {
                hilog.info(0x0000, 'testTag', 'appIcon loading success');
              })
              .onError(() => {
                hilog.error(0x0000, 'testTag', 'appIcon loading fail');
              })
            Column()
              .layoutWeight(1)
              .constraintSize({
                minHeight: 24,
                maxHeight: 64,
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
            }

            Column()
              .layoutWeight(1)
              .constraintSize({
                minHeight: 24,
                maxHeight: 56,
              })
            Column() {
              LoginWithHuaweiIDButton({
                params: {
                  // LoginWithHuaweiIDButton支持的样式
                  style: loginComponentManager.Style.BUTTON_CUSTOM,
                  customButtonParams: {
                    backgroundColor: this.loginBtnBgColor,
                  },
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
            .width('100%')
          }.width('100%')
          Column()
            .layoutWeight(1)
            .constraintSize({
              minHeight: 24,
            })
          Row() {
            Row() {
              Checkbox({ name: 'privacyCheckbox', group: 'privacyCheckboxGroup' })
                .width(24)
                .height(24)
                .focusable(true)
                .focusOnTouch(true)
                .margin({ top: 0 })
                .onChange((value: boolean) => {
                  if (value) {
                    this.isSelected = true;
                    this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
                  } else {
                    this.isSelected = false;
                    this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
                  }
                  hilog.info(0x0000, 'testTag', `agreementChecked: ${value}`);
                })
            }

            Row() {
              Text() {
                ForEach(this.privacyText, (item: loginComponentManager.PrivacyText) => {
                  if (item?.type === loginComponentManager.TextType.PLAIN_TEXT && item?.text) {
                    Span(item?.text)
                      .fontColor($r('sys.color.font_secondary'))
                      .fontWeight(FontWeight.Regular)
                      .fontSize($r('sys.float.Body_S'))
                  } else if (item?.type === loginComponentManager.TextType.RICH_TEXT && item?.text) {
                    Span(item?.text)
                      .fontColor($r('sys.color.font_primary'))
                      .fontWeight(FontWeight.Medium)
                      .fontSize($r('sys.float.Body_S'))
                      .focusable(true)
                      .focusOnTouch(true)
                      .onClick(() => {
                        // 应用需要根据item.tag实现协议页面的跳转逻辑
                        hilog.info(0x0000, 'testTag', `click privacy text tag: ${item.tag}`);
                        if (item.tag === QuickLogin.USER_SERVICE_TAG) {
                          this.onServicePolicy()
                        }
                        if (item.tag === QuickLogin.USER_PRIVACY_TAG) {
                          this.onPrivacyPolicy()
                        }
                        if (item.tag === QuickLogin.USER_AUTHENTICATION_TAG) {
                          this.onHYAccountRouter()
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
            bottom: 16,
          })
        }
        .constraintSize({ minHeight: '100%' })
        .margin({
          left: this.horizontalMargin,
          right: this.horizontalMargin,
        })
      }
      .width('100%')
      .constraintSize({ minHeight: '100%' })
    }
    .edgeEffect(EdgeEffect.Spring)
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
  }
}
