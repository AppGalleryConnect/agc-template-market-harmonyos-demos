import * as wxopensdk from '@tencent/wechat_open_sdk';
import { common, Want } from '@kit.AbilityKit';
import { PersistenceV2, promptAction } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { authentication, loginComponentManager } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { LoginChannelType, LoginErrorCode, LoginType } from '../common/Constant';
import { Channel, ExtraInfo, LoginParams, NavParam, PrivacyContent } from '../model/Index';
import { ApiController, LoginEventDispatcher } from '../utils/Utils';
import { LoginSheetUtils } from '../utils/LoginSheetUtils';
import { OnWXResp, wxEventHandler } from '../utils/WXApiUtils';


@ObservedV2
export class AggregatedLoginVM {
  private static _instance: AggregatedLoginVM | null;
  @Trace innerRouterModule: NavPathStack = new NavPathStack()
  @Trace isSelected: boolean = false;
  // 控制登录中不可点击协议和复选框的状态变量
  @Trace enableStatus: boolean = true;
  @Trace unionID: string = '';
  @Trace openID: string = '';
  @Trace authorizationCode: string | undefined = '';
  @Trace anonymousPhone: string = '';
  @Trace persistenceData: PersistenceData =
    PersistenceV2.connect(PersistenceData, 'PhoneData', () => new PersistenceData())!
  @Trace phoneNum: string = ''
  @Trace verifyCode: string = '';
  @Trace verifyCodeTime: number = 0;
  @Trace isLoading: boolean = false;
  @Trace timer: number = 0;
  isSheet: boolean = false;
  autoSheet: boolean = false;
  isPersistence: boolean = false;
  loginTypes: Channel[] = [];
  wxApi: wxopensdk.WXApi = wxopensdk.WXAPIFactory.createWXAPI('xxx')
  @Trace apiController: ApiController = new ApiController(
    () => new Promise(() => {
    }), () => new Promise(() => {
  }), () => new Promise(() => {
  }));
  logTag: string = 'QuickLoginButtonComponent';
  domainId: number = 0x0000;
  obtainVerifyCode: () => Promise<void> = () => new Promise(() => {
  });

  controller: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
    // 需要用户同意协议才能完成华为账号登录，请先设置协议状态为NOT_ACCEPTED，当用户同意协议后设置协议状态为ACCEPTED，才可以完成华为账号登录
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton((error: BusinessError | undefined,
        response: loginComponentManager.HuaweiIDCredential) => {
        this.handleLoginWithHuaweiIDButton(error, response);
      });

  // 定义固定文本部分
  fixedTexts: loginComponentManager.PrivacyText[] = [
    {
      text: '已同意并阅读 ',
      type: loginComponentManager.TextType.PLAIN_TEXT,
    },
    {
      text: ' 和 ',
      type: loginComponentManager.TextType.PLAIN_TEXT,
    }
  ];

  public static getInstance(reCreate: boolean = false) {
    if (!AggregatedLoginVM._instance || reCreate) {
      AggregatedLoginVM._instance = new AggregatedLoginVM();
    }
    return AggregatedLoginVM._instance;
  }

  public static clearInstance() {
    AggregatedLoginVM._instance = null;
  }

  public resetInstance() {
    this.isSelected = false
    this.enableStatus = true
    this.phoneNum = ''
    this.verifyCode  = ''
    this.verifyCodeTime = 0
    clearInterval(this.timer)
  }

  setValue(wxApi: wxopensdk.WXApi, isSheet: boolean, autoSheet: boolean,
    loginTypes: Channel[], isPersistence: boolean, apiController: ApiController,
    obtainVerifyCode: () => Promise<void>) {
    this.wxApi = wxApi
    this.isSheet = isSheet;
    this.autoSheet = autoSheet;
    this.loginTypes = loginTypes;
    this.isPersistence = isPersistence;
    this.apiController = apiController;
    this.obtainVerifyCode = obtainVerifyCode;
  }

  async wxLogin(extraInfo: ExtraInfo) {
    let req = new wxopensdk.SendAuthReq;
    req.isOption1 = false;
    req.nonAutomatic = true;
    req.scope = extraInfo.scope;
    req.state = extraInfo.state;
    req.transaction = extraInfo.transaction;

    let finished = await this.wxApi.sendReq(getContext(this) as common.UIAbilityContext, req);
    if (!finished) {
      promptAction.showToast({ message: '未安装微信' });
    }
  }


  wechatLogin(extraInfo: ExtraInfo) {
    if (this.isSelected) {
      this.wxLogin(extraInfo);
    } else {
      promptAction.showToast({
        message: $r('app.string.select_the_agreement'),
        duration: 1500,
        bottom: 80,
      })
    }
  }

  /**
   * 微信回调事件处理
   * @param want
   */
  public handleWeChatCallIfNeed(want: Want) {
    this.wxApi.handleWant(want, wxEventHandler);
  }

  registerOnWXRespCallback() {
    wxEventHandler.registerOnWXRespCallback(this.OnWXRespCallback);
  }

  unregisterOnWXRespCallback() {
    wxEventHandler.unregisterOnWXRespCallback(this.OnWXRespCallback);
  }

  phoneLogin(pathStack: NavPathStack, paraPram: NavParam) {
    pathStack.pushPathByName('OtherLoginPage', paraPram);
  }


  /**
   * 点击登录按钮
   **/
  validateLogin(): boolean {
    if (this.verifyCode === '' || (this.isPersistence ? this.persistenceData.phoneNumber : this.phoneNum) === '') {
      promptAction.showToast({ message: '手机号或验证码不能为空！' })
      return false
    }
    if (!/^\d{6}$/.test(this.verifyCode)) {
      promptAction.showToast({ message: '验证码不正确！' })
      return false
    }
    if (!/^1[3-9]\d{9}$/.test(this.isPersistence ? this.persistenceData.phoneNumber : this.phoneNum)) {
      promptAction.showToast({ message: '手机号码不正确！' })
      return false
    }
    return true
  }

  /**
   * 点击登录按钮
   **/
  clickLogInButton(): void {
    if (!this.isSelected) {
      promptAction.showToast({
        message: $r('app.string.select_the_agreement'),
        duration: 1500,
        bottom: 80,
      });
      return;
    }
    if (!this.validateLogin()) {
      return
    }
    let loginParams: LoginParams = {
      phoneNumbers: this.isPersistence ? this.persistenceData.phoneNumber : this.phoneNum,
      verifyCode: this.verifyCode
    }
    this.isLoading = true
    this.apiController.verifyCode(loginParams).then(() => {
      this.isLoading = false
      // 关闭其他方式登陆
      this.innerRouterModule.pop('loginSuccess')
      if (this.isSheet && this.autoSheet) {
        LoginSheetUtils.close()
      }
    })
  }

  /**
   * 获取验证码计数
   **/
  getVerifyCode(): void {
    if ((this.isPersistence ? this.persistenceData.phoneNumber : this.phoneNum) === '' ||
      !/^1[3-9]\d{9}$/.test(this.isPersistence ? this.persistenceData.phoneNumber : this.phoneNum)) {
      promptAction.showToast({ message: '请输入正确的手机号' })
    } else {
      this.obtainVerifyCode().then(() => {
        this.verifyCodeTime = 60;
        this.timer = setInterval(() => {
          this.verifyCodeTime--;
          if (!this.verifyCodeTime) {
            clearInterval(this.timer)
          }
        }, 1000)
      })
    }
  }

  agreePrivacyChange(value: boolean) {
    this.isSelected = value;
    if (this.isSelected) {
      // 设置协议状态为ACCEPTED
      this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
    } else {
      // 设置协议状态为NOT_ACCEPTED
      this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
    }
  }

  getQuickLoginAnonymousPhone() {
    // 创建授权请求，并设置参数
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // 获取匿名手机号需传quickLoginAnonymousPhone这个scope，传参之前需要先申请“华为账号一键登录”权限
    authRequest.scopes = ['quickLoginAnonymousPhone'];
    // 获取code需传如下permission
    authRequest.permissions = ['serviceauthcode'];
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
        this.authorizationCode = response.data!.authorizationCode;
        const anonymousPhone = response.data?.extraInfo?.quickLoginAnonymousPhone as string;
        if (anonymousPhone) {
          hilog.info(0x0002, 'testTag', 'Succeeded in authentication.');
          this.anonymousPhone = anonymousPhone;
          return;
        }
        hilog.info(0x0002, 'testTag', 'Succeeded in authentication. AnonymousPhone is empty.');
      }).catch((error: BusinessError) => {
        // todo 以下内容配置好可用的调试证书和client_id后删除，当前为模拟数据
        this.unionID = util.generateRandomUUID();
        this.openID = util.generateRandomUUID();
        this.anonymousPhone = '183******12';
      });
    } catch (error) {
      hilog.info(0x0002, 'testTag', 'quick login failed ' + JSON.stringify(error));
    }
  }

  generatePrivacyText(dynamicContents: PrivacyContent[]): loginComponentManager.PrivacyText[] {
    const privacyText: loginComponentManager.PrivacyText[] = [];

    // 添加固定文本“已同意并阅读 ”
    privacyText.push(this.fixedTexts[0]);

    // 添加动态协议内容
    dynamicContents.forEach((content, index) => {
      // 添加协议名称为RICH_TEXT类型，包含链接
      privacyText.push({
        text: content.privacyLabel,
        type: loginComponentManager.TextType.RICH_TEXT,
        tag: content.privacyTag,
      });

      // 添加“ 和 ”
      if (dynamicContents.length > 1) {
        if (index === dynamicContents.length - 2) {
          privacyText.push(this.fixedTexts[1]);
        }
      }

    });

    return privacyText;
  }

  resetParam() {
    clearInterval(this.timer)
    this.verifyCodeTime = 0
    this.phoneNum = ''
    this.verifyCode = ''
  }

  // 回调函数，用于处理微信的响应
  private OnWXRespCallback: OnWXResp = (resp) => {
    if (resp?.errCode === 0) {
      this.apiController.wxLogin().then(() => {
        if (this.isSheet && this.autoSheet) {
          LoginSheetUtils.close()
        }
      })
    } else {
      LoginEventDispatcher.dispatchToLoginFail(LoginChannelType.WECHAT, resp)
    }
  }

  // 处理点击一键登录后的方法。
  private handleLoginWithHuaweiIDButton(error: BusinessError | undefined,
    response: loginComponentManager.HuaweiIDCredential) {
    // if部分内容需配置好可用的调试证书和client_id
    if (error) {
      hilog.error(this.domainId, this.logTag,
        `Failed to click LoginWithHuaweiIDButton. errCode is ${error.code}, errMessage is ${error.message}`);
      if (error.code === LoginErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
        promptAction.showToast({
          message: $r('app.string.select_the_agreement'),
          duration: 1500,
          bottom: 80,
        });
        return;
      } else {
        LoginEventDispatcher.dispatchToLoginFail(LoginChannelType.HUAWEI, error)
      }
      this.enableStatus = true;
      return;
    }
    try {
      if (this.isSelected) {
        if (response) {
          hilog.info(this.domainId, this.logTag, 'Succeeded in clicking LoginWithHuaweiIDButton.');
          let loginParams: LoginParams = {
            unionID: this.unionID,
            authorizationCode: this.authorizationCode
          }
          this.apiController.huaweiLogin(loginParams).then(() => {
            if (this.isSheet && this.autoSheet) {
              LoginSheetUtils.close()
            }
          })
        }
      } else {
        promptAction.showToast({
          message: $r('app.string.select_the_agreement'),
          duration: 1500,
          bottom: 80,
        });
      }
    } catch (err) {
      hilog.error(this.domainId, this.logTag,
        `Failed to LoginWithHuaweiIDButton, errCode: ${err.code}, errMessage: ${err.message}`);
    }
  }
}

@ObservedV2
class PersistenceData {
  @Trace phoneNumber: string = ''
}