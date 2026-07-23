import { window } from '@kit.ArkUI';
import { loginComponentManager } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import * as wxopensdk from '@tencent/wechat_open_sdk';
import { BaseViewModel, CommonConfirmDialog, CommonConstants,
  GlobalContext,
  Logger, PopViewUtils, RouterMap } from 'lib_common';
import { AccountApi } from '../services/AccountApi';
import { HuaweiAuthUtils } from '../utils/HuaweiAuthUtils';
import { ErrorCode } from '../constants/ErrorCode';
import { OnWXResp, wxApi, wxEventHandler } from '../utils/WXApiUtils';
import { Constants } from '../constants/Constants';
import { LoginRouterParams, LoginSheetParams } from '../constants/Types';
import { getAccountErrorMsg } from '../utils/ErrorCodeHelper';

const TAG = '[LoginVM]';

@ObservedV2
export class LoginVM extends BaseViewModel {
  @Trace anonymousPhone: string = '177******96';
  @Trace isAgreePrivacy: boolean = false;
  @Trace userProtocolInfo: string = '';
  @Trace privacyInfo: string = '';
  @Trace huaweiUserProtocolInfo: string = '';
  @Trace isSheet: boolean = false;
  @Trace sheetParams: LoginSheetParams = new LoginSheetParams();
  @Trace stack: NavPathStack = new NavPathStack();
  @Trace accountInput: string = '';
  @Trace passwordInput: string = '';
  private accountInstance: AccountApi = new AccountApi();
  static instance: LoginVM | null;
  controller: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton((error: BusinessError, response: loginComponentManager.HuaweiIDCredential) => {
        this.handleClickLoginWithHuaweiIDButton(error, response);
      })

  public static getInstance(reCreate: boolean = false) {
    if (!LoginVM.instance || reCreate) {
      LoginVM.instance = new LoginVM();
    }
    return LoginVM.instance;
  }

  public static clearInstance() {
    LoginVM.instance = null;
  }

  constructor() {
    super();
    this.queryAnonymousPhone();
    this.queryProtocol();
  }

  resetInput() {
    this.accountInput = '';
    this.passwordInput = '';
    this.agreePrivacyChange(false);
  }

  private handleClickLoginWithHuaweiIDButton(error: BusinessError, response: loginComponentManager.HuaweiIDCredential) {
    if (response) {
      Logger.info(TAG, 'onClickLoginWithHuaweiIDButton success, response: ' + JSON.stringify(response));
    }
    if (error) {
      this.handleHuaweiLoginFail(error);
      return;
    }
    this.huaweiLogin();
  }

  private handleHuaweiLoginFail(error: BusinessError) {
    Logger.error(TAG, 'onClickLoginWithHuaweiIDButton fail, error: ' + JSON.stringify(error));

    if (error.code === ErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '请先勾选同意协议' });
      return;
    }
    let errorMsg: string = getAccountErrorMsg(error.code);
    CommonConfirmDialog.show({
      primaryTitle: '温馨提示',
      content: errorMsg + '是否先模拟登录成功？',
      confirm: () => {
        this.huaweiLogin();
      },
    })
  }

  private OnWXRespCallback: OnWXResp = (resp) => {
    if (resp?.errCode === 0) {
      this.wechatLogin();
    } else {
      CommonConfirmDialog.show({
        primaryTitle: '温馨提示',
        content: '拉起微信登录失败，是否先模拟登录成功？',
        confirm: () => {
          this.wechatLogin();
        },
      })
    }
  }

  registerOnWXRespCallback() {
    wxEventHandler.registerOnWXRespCallback(this.OnWXRespCallback);
  }

  unregisterOnWXRespCallback() {
    wxEventHandler.unregisterOnWXRespCallback(this.OnWXRespCallback);
  }

  setPrivacyMode(context?: Context) {
    if (!context) {
      return;
    }
    try {
      window.getLastWindow(context).then((window) => {
        window.setWindowPrivacyMode(true);
      }).catch((error: Error) => {
        Logger.error(TAG, 'setPrivacyMode error: ' + JSON.stringify(error));
      });
    } catch (error) {
      Logger.error(TAG, 'setPrivacyMode error: ' + JSON.stringify(error));
    }
  }

  cancelPrivacyMode(context?: Context) {
    if (!context) {
      return;
    }
    try {
      window.getLastWindow(context).then((window) => {
        window.setWindowPrivacyMode(false);
      }).catch((error: Error) => {
        Logger.error(TAG, 'cancelPrivacyMode error: ' + JSON.stringify(error));
      });
    } catch (error) {
      Logger.error(TAG, 'cancelPrivacyMode error: ' + JSON.stringify(error));
    }
  }


  queryAnonymousPhone() {
    HuaweiAuthUtils.quickLoginAnonymousPhone().then((resp: string) => {
      if (resp) {
        this.anonymousPhone = resp;
      }
    })
  }

  queryProtocol() {
    this.userProtocolInfo = this.accountInstance.getUserAgreeInfo();
    this.privacyInfo = this.accountInstance.getPrivacyInfo();
    this.huaweiUserProtocolInfo = this.accountInstance.getHuaweiUserAgreeInfo();
  }

  handleClose() {
    if (this.isSheet) {
      PopViewUtils.closeSheet();
    } else {
      this.stack.pop(true);
    }
    LoginVM.clearInstance();
  }

  huaweiLogin() {
    this.accountInstance.huaweiLogin(this.anonymousPhone);
    this.handleClose();
  }

  wechatLogin() {
    this.accountInstance.wechatLogin()
    this.handleClose();
  }

  accountPasswordLogin() {
    if (!this.isAgreePrivacy) {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '请先勾选同意协议' });
      return;
    }
    if (!this.accountInput) {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '请输入账号' });
      return;
    }
    if (!this.passwordInput) {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '请输入密码' });
      return;
    }
    this.accountInstance.accountPasswordLogin()
    this.handleClose();
  }

  jumpOtherLogin() {
    this.stack.replacePathByName(RouterMap.OTHER_LOGIN_PAGE, null, false);
  }

  jumpHuaweiLogin() {
    this.stack.replacePathByName(RouterMap.HUAWEI_LOGIN_PAGE, {
      keepVM: true,
    } as LoginRouterParams, false);
  }

  async jumpWX() {
    const req = new wxopensdk.SendAuthReq;
    /**
     * 填写实际的请求信息
     */
    req.isOption1 = false;
    req.nonAutomatic = true;
    req.scope = 'snsapi_userinfo';
    req.state = 'none';
    req.transaction = 'test123';

    const isJumpSuccess = await wxApi.sendReq(GlobalContext.getContext(), req);
    Logger.info(TAG, 'jump wechat result: ' + isJumpSuccess);
    if (!isJumpSuccess) {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '未安装微信' });
    }
  }

  agreePrivacyChange(value: boolean) {
    this.isAgreePrivacy = value;
    if (this.isAgreePrivacy) {
      this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
    } else {
      this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
    }
  }

  otherWayMarginTop() {
    if (this.isSheet) {
      return CommonConstants.PADDING_XXL;
    }
    return Constants.PADDING_40;
  }

  pageBgColor() {
    if (this.isSheet) {
      return Color.Transparent;
    }
    return $r('sys.color.background_secondary');
  }

  getPagePaddingBottom() {
    if (this.isSheet && this.sheetParams.sheetType === SheetType.CENTER) {
      return 0;
    }
    // 兼容api17以下
    if (deviceInfo.sdkApiVersion < 17) {
      return this.windowModel.windowBottomPadding + CommonConstants.PADDING_L;
    }
    return this.windowModel.windowBottomPadding;
  }
}