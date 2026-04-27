import { AppStorageV2, PersistenceV2, PromptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import * as wxopensdk from '@tencent/wechat_open_sdk';
import {
  UserInfo,
  TCLogger,
  GlobalContext,
  AccountDialogModel,
  MOCK_ACCOUNT_LIST,
  dialogMockAccountBuilder,
  TempBarHeight,
  OHDialog
} from 'common';
import { phoneRouterControl } from 'oh_router';
import {
  LoginChannelType,
  LoginController,
  LoginParams,
  AggregatedLogin,
  LoginType,
  Channel,
  ApiController
} from 'aggregated_login';
import { CMChatFactory } from 'instant_messaging';

@Builder
export function LoginPageBuilder() {
  LoginPage()
}

const TAG = 'LoginPage';

@ComponentV2
export struct LoginPage {
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  promptAction: PromptAction = GlobalContext.getUIContext().getPromptAction();
  controller: LoginController = new LoginController()
  @Local navPathStack: NavPathStack = new NavPathStack()
  // todo 需要传入应用申请到的AppID
  wxApi = wxopensdk.WXAPIFactory.createWXAPI('xxx')
  huaweiLogin = async (loginParams: LoginParams): Promise<void> => {
    this.selectMockAccountDialog();
  }
  wxLogin = async (): Promise<void> => {
    this.getUIContext().getPromptAction().showToast({ message: '微信登录成功' })
  }
  verifyCodeLogin = async (loginParams: LoginParams): Promise<void> => {
    try {
      const data = await this.promptAction.showDialog({
        title: '温馨提示',
        message: '模拟验证码登录成功？',
        buttons: [
          { text: '取消', color: '#000000' },
          { text: '确认', color: '#000000' },
        ]
      })
      if (data.index === 1) {
        // todo 模拟登录数据
        this.userInfo.telephone = loginParams.phoneNumbers ?? '183******12';
        this.controller.clearLoginInfo();
        this.selectMockAccountDialog();
      }
    } catch (err) {
      TCLogger.error('弹窗操作异常:', (err as BusinessError).message);
    }
  }
  obtainVerifyCode = async () => {
    this.getUIContext().getPromptAction().showToast({ message: '获取验证码为模拟场景，真实获取验证码以业务实现为准' })
  }
  handleLoginFail = (loginChannelType: LoginChannelType, error: BusinessError | wxopensdk.BaseResp) => {
    if (loginChannelType === LoginChannelType.HUAWEI) {
      const businessError = error as BusinessError
      const errorMsg = ERROR_MSG_MAP[businessError.code] ?? '未知错误。';
      this.promptAction.showDialog({
        title: '温馨提示',
        message: errorMsg + '是否先模拟登录成功？',
        buttons: [
          { text: '取消', color: '#000000' },
          { text: '确认', color: '#000000' },
        ]
      }, (err: BusinessError, data) => { // 按钮动作回调
        // 根据按钮索引处理动作
        if (data.index === 1) {
          // todo 模拟登录数据
          this.userInfo.telephone = '183******12'
          this.controller.clearLoginInfo();
          this.selectMockAccountDialog();
        }
      })
      return;
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 登录使用
        AggregatedLogin({
          wxApi: this.wxApi,
          routerModule: this.navPathStack,
          icon: $r('app.media.startIcon'),
          themeColor: '#0A59F7',
          isSheet: false,
          autoSheet: false,
          isPersistence: false,
          loginTypes: [new Channel(LoginType.WECHAT, '微信', {
            appId: 'xxx',
            scope: 'snsapi_userinfo,snsapi_friend,snsapi_message,snsapi_contact',
            transaction: 'test123',
            state: 'none',
          }, $r('app.media.wx_count'))],
          privacyContent: [{
            privacyLabel: '《用户协议》',
            privacyUrl: ProtocolData.termOfServiceProtocol,
            privacyTag: '用户协议'
          }, {
            privacyLabel: '《xxxx隐私政策》',
            privacyUrl: ProtocolData.privacyProtocol,
            privacyTag: '隐私政策'
          }, {
            privacyLabel: '《华为账号用户认证协议》',
            privacyUrl: ProtocolData.huaweiUserProtocol,
            privacyTag: '华为账号用户认证协议'
          }],
          apiController: new ApiController(this.huaweiLogin, this.wxLogin, this.verifyCodeLogin),
          handleLoginFail: this.handleLoginFail,
          obtainVerifyCode: this.obtainVerifyCode,
          loginController: this.controller,
        });
      }
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => this.navPathStack = ctx.pathStack)
    .onShown(() => {
      this.tempBarHeight.topValue = 0;
      this.tempBarHeight.bottomValue = this.tempBarHeight.bottomTempValue;
    })
    .onBackPressed(() => {
      let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      context.terminateSelf((err: BusinessError) => {
        if (err !== undefined) {
          TCLogger.error(TAG, 'terminate self failed. error:' + JSON.stringify(err));
        } else {
          TCLogger.info(TAG, 'terminate self success');
        }
      });
      return true
    })
  }

  selectMockAccountDialog() {
    if (this.userInfo.id.length === 0) {
      let singleModel = MOCK_ACCOUNT_LIST[0];
      this.userInfo.id = singleModel.userId;
      this.userInfo.nickName = singleModel.nickName;
      this.userInfo.avatarUrl = singleModel.avatarUrl;
      this.userInfo.userSig = singleModel.userSig;
      this.userInfo.introDesc = singleModel.selfSignature;
    }

    let dialogVM = new AccountDialogModel();
    dialogVM.currentUser.userId = this.userInfo.id;
    dialogVM.currentUser.nickName = this.userInfo.nickName;
    dialogVM.currentUser.avatarUrl = this.userInfo.avatarUrl;
    dialogVM.currentUser.userSig = this.userInfo.userSig;
    dialogVM.currentUser.selfSignature = this.userInfo.introDesc;
    dialogVM.onValueConfirmClick = (model: Object) => {
      let userModel: AccountDialogModel | undefined;
      try {
        userModel = model as AccountDialogModel;
      } catch (err) {
      }
      if (userModel !== undefined) {
        this.loginSdk(userModel);
      }
    }
    dialogVM.childBuilder = dialogMockAccountBuilder;
    OHDialog.showPopup(dialogVM);
  }

  loginSdk(userModel: AccountDialogModel) {
    CMChatFactory.instance.login(userModel.currentUser.userId, userModel.currentUser.userSig ?? '')
      .then(() => {
        this.userInfo.isLogin = true;
        this.userInfo.id = userModel.currentUser.userId;
        this.userInfo.nickName = userModel.currentUser.nickName;
        this.userInfo.avatarUrl = userModel.currentUser.avatarUrl;
        this.userInfo.userSig = userModel.currentUser.userSig;
        setTimeout(() => {
          phoneRouterControl.popPage({ popData: 'loginSuccess' });
        }, 500)
      }).catch((err: BusinessError) => {
      TCLogger.error(TAG, `sdk login err = ` + JSON.stringify(err));
      if (userModel.currentUser.userSig.length === 0) {
        GlobalContext.getUIContext().getPromptAction().showToast({
          message: '登录失败，请配置mock账号数据'
        })
      } else {
        GlobalContext.getUIContext().getPromptAction().showToast({
          message: '登录失败，请稍后再试'
        })
      }
    })
  }
}

export class ProtocolData {
  static termOfServiceProtocol: string =
    '<html lang="zh-CN" id="container"><head>\n    <meta charset="UTF-8">\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\n    <title>用户协议</title>\n    <style type="text/tailwindcss">\n        @layer utilities {\n            .content-auto {\n                content-visibility: auto;\n            }\n            .scrollbar-hide {\n                -ms-overflow-style: none;\n                scrollbar-width: none;\n            }\n            .scrollbar-hide::-webkit-scrollbar {\n                display: none;\n            }\n            .text-balance {\n                text-wrap: balance;\n            }\n        }\n    </style>\n</head>\n<body class="font-inter bg-gray-50 text-gray-800 min-h-screen flex flex-col">\n    <header class="bg-white shadow-sm sticky top-0 z-10 transition-all duration-300">\n        <div class="container mx-auto px-4 py-4 flex justify-between items-center">\n            <div class="flex items-center space-x-2">\n                <i class="fa fa-file-text-o text-primary text-2xl"></i>\n                <h1 class="text-xl font-bold text-gray-800">用户协议</h1>\n            </div>\n        </div>\n    </header>\n\n    <main class="flex-grow container mx-auto px-4 py-8">\n        <div class="max-w-4xl mx-auto bg-white rounded-xl shadow-md overflow-hidden transition-all duration-300 hover:shadow-lg">\n            <div class="p-6 md:p-8">\n                <div class="mb-8">\n                    <h2 class="text-[clamp(1.5rem,3vw,2.5rem)] font-bold text-gray-900 mb-4 text-balance">服务条款</h2>\n                    <p class="text-gray-600">请仔细阅读以下条款，使用我们的服务即表示您同意这些条款。</p>\n                </div>\n\n                <div class="space-y-8">\n                    <section id="section1" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">1</span>\n                            服务概述\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            我们通过网站及移动应用（以下统称"服务"）为用户提供信息、工具和服务。这些服务可能包括但不限于内容浏览、社交互动、交易服务和个性化推荐。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            我们保留随时修改或停止服务的权利，而无需事先通知您。我们不会对您或任何第三方因服务的修改、暂停或终止而遭受的任何损失承担责任。\n                        </p>\n                    </section>\n\n                    <section id="section2" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">2</span>\n                            用户账号\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            使用我们的服务可能需要您创建一个账号。您同意提供准确、完整和最新的个人信息，并维护和及时更新这些信息。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            您对您账号下发生的所有活动负责。如果您发现任何未经授权使用您账号的情况，您应立即通知我们。您不得将您的账号转让给任何第三方。\n                        </p>\n                    </section>\n\n                    <section id="section3" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">3</span>\n                            隐私政策\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            我们重视您的隐私，并根据我们的隐私政策收集、使用和保护您的个人信息。使用我们的服务即表示您同意我们按照该隐私政策处理您的信息。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            我们可能会更新我们的隐私政策，建议您定期查看。继续使用我们的服务即表示您同意这些更新。\n                        </p>\n                    </section>\n\n                    <section id="section4" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">4</span>\n                            内容使用\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            我们服务中提供的内容（包括但不限于文本、图形、图像、视频、音频）受版权、商标和其他知识产权法律的保护。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            您可以为个人非商业用途查看和使用这些内容，但未经我们明确书面许可，不得复制、修改、分发、传输或创建衍生作品。\n                        </p>\n                    </section>\n\n                    <section id="section5" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">5</span>\n                            用户行为\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            您同意不利用我们的服务从事非法活动，或促进、鼓励任何非法活动。您不得干扰或破坏服务的正常运行，或试图访问未授权的系统或数据。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            您不得在服务中发布或传播垃圾邮件、病毒、恶意软件或任何其他有害内容。您不得收集或存储其他用户的个人信息。\n                        </p>\n                    </section>\n\n                    <section id="section6" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">6</span>\n                            免责声明\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            我们的服务按"原样"提供，不附带任何形式的明示或暗示保证，包括但不限于适销性、特定用途适用性和不侵权的保证。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            在适用法律允许的最大范围内，我们不对因使用或无法使用服务而导致的任何直接、间接、偶然、特殊、惩罚性或后果性损害承担责任。\n                        </p>\n                    </section>\n\n                    <section id="section7" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">7</span>\n                            法律适用与争议解决\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            本协议受[具体司法管辖区]法律管辖。因本协议引起的或与本协议有关的任何争议，应通过双方友好协商解决；协商不成的，任何一方均有权将争议提交[具体仲裁机构或法院]解决。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            如果本协议的任何条款被认定为无效或不可执行，该条款应被删除或修改，而其余条款应继续有效。\n                        </p>\n                    </section>\n\n                    <section id="section8" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">8</span>\n                            协议更新\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            我们可能会不时更新本服务条款。当我们进行重大更改时，我们将通过在我们的网站上发布新的服务条款通知您，并且在某些情况下，我们可能会通过电子邮件或其他通信方式通知您。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            您继续使用我们的服务即表示您接受这些更新。我们鼓励您定期查看本服务条款。\n                        </p>\n                    </section>\n                </div>\n            </div>\n        </div>\n    </main>\n\n\n    </body></html>'
  static privacyProtocol: string =
    '<html lang="zh-CN" id="container"><head>\n    <meta charset="UTF-8">\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\n    <title>隐私协议</title>\n    <style type="text/tailwindcss">\n        @layer utilities {\n            .content-auto {\n                content-visibility: auto;\n            }\n            .scrollbar-hide {\n                -ms-overflow-style: none;\n                scrollbar-width: none;\n            }\n            .scrollbar-hide::-webkit-scrollbar {\n                display: none;\n            }\n            .text-balance {\n                text-wrap: balance;\n            }\n        }\n    </style>\n</head>\n<body class="font-inter bg-gray-50 text-gray-800 min-h-screen flex flex-col">\n    <header class="bg-white shadow-sm sticky top-0 z-10 transition-all duration-300">\n        <div class="container mx-auto px-4 py-4 flex justify-between items-center">\n            <div class="flex items-center space-x-2">\n                <i class="fa fa-file-text-o text-primary text-2xl"></i>\n                <h1 class="text-xl font-bold text-gray-800">隐私协议</h1>\n            </div>\n        </div>\n    </header>\n\n    <main class="flex-grow container mx-auto px-4 py-8">\n        <div class="max-w-4xl mx-auto bg-white rounded-xl shadow-md overflow-hidden transition-all duration-300 hover:shadow-lg">\n            <div class="p-6 md:p-8">\n                <div class="mb-8">\n                    <h2 class="text-[clamp(1.5rem,3vw,2.5rem)] font-bold text-gray-900 mb-4 text-balance">服务条款</h2>\n                    <p class="text-gray-600">请仔细阅读以下条款，使用我们的服务即表示您同意这些条款。</p>\n                </div>\n\n                <div class="space-y-8">\n                    <section id="section1" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">1</span>\n                            服务概述\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            我们通过网站及移动应用（以下统称"服务"）为用户提供信息、工具和服务。这些服务可能包括但不限于内容浏览、社交互动、交易服务和个性化推荐。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            我们保留随时修改或停止服务的权利，而无需事先通知您。我们不会对您或任何第三方因服务的修改、暂停或终止而遭受的任何损失承担责任。\n                        </p>\n                    </section>\n\n                    <section id="section2" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">2</span>\n                            用户账号\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            使用我们的服务可能需要您创建一个账号。您同意提供准确、完整和最新的个人信息，并维护和及时更新这些信息。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            您对您账号下发生的所有活动负责。如果您发现任何未经授权使用您账号的情况，您应立即通知我们。您不得将您的账号转让给任何第三方。\n                        </p>\n                    </section>\n\n                    <section id="section3" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">3</span>\n                            隐私政策\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            我们重视您的隐私，并根据我们的隐私政策收集、使用和保护您的个人信息。使用我们的服务即表示您同意我们按照该隐私政策处理您的信息。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            我们可能会更新我们的隐私政策，建议您定期查看。继续使用我们的服务即表示您同意这些更新。\n                        </p>\n                    </section>\n\n                    <section id="section4" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">4</span>\n                            内容使用\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            我们服务中提供的内容（包括但不限于文本、图形、图像、视频、音频）受版权、商标和其他知识产权法律的保护。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            您可以为个人非商业用途查看和使用这些内容，但未经我们明确书面许可，不得复制、修改、分发、传输或创建衍生作品。\n                        </p>\n                    </section>\n\n                    <section id="section5" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">5</span>\n                            用户行为\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            您同意不利用我们的服务从事非法活动，或促进、鼓励任何非法活动。您不得干扰或破坏服务的正常运行，或试图访问未授权的系统或数据。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            您不得在服务中发布或传播垃圾邮件、病毒、恶意软件或任何其他有害内容。您不得收集或存储其他用户的个人信息。\n                        </p>\n                    </section>\n\n                    <section id="section6" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">6</span>\n                            免责声明\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            我们的服务按"原样"提供，不附带任何形式的明示或暗示保证，包括但不限于适销性、特定用途适用性和不侵权的保证。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            在适用法律允许的最大范围内，我们不对因使用或无法使用服务而导致的任何直接、间接、偶然、特殊、惩罚性或后果性损害承担责任。\n                        </p>\n                    </section>\n\n                    <section id="section7" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">7</span>\n                            法律适用与争议解决\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            本协议受[具体司法管辖区]法律管辖。因本协议引起的或与本协议有关的任何争议，应通过双方友好协商解决；协商不成的，任何一方均有权将争议提交[具体仲裁机构或法院]解决。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            如果本协议的任何条款被认定为无效或不可执行，该条款应被删除或修改，而其余条款应继续有效。\n                        </p>\n                    </section>\n\n                    <section id="section8" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">8</span>\n                            协议更新\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            我们可能会不时更新本服务条款。当我们进行重大更改时，我们将通过在我们的网站上发布新的服务条款通知您，并且在某些情况下，我们可能会通过电子邮件或其他通信方式通知您。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            您继续使用我们的服务即表示您接受这些更新。我们鼓励您定期查看本服务条款。\n                        </p>\n                    </section>\n                </div>\n            </div>\n        </div>\n    </main>\n\n\n    </body></html>'
  static huaweiUserProtocol: string =
    '<html lang="zh-CN" id="container"><head>\n    <meta charset="UTF-8">\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\n    <title>华为账号用户认证协议</title>\n    <style type="text/tailwindcss">\n        @layer utilities {\n            .content-auto {\n                content-visibility: auto;\n            }\n            .scrollbar-hide {\n                -ms-overflow-style: none;\n                scrollbar-width: none;\n            }\n            .scrollbar-hide::-webkit-scrollbar {\n                display: none;\n            }\n            .text-balance {\n                text-wrap: balance;\n            }\n        }\n    </style>\n</head>\n<body class="font-inter bg-gray-50 text-gray-800 min-h-screen flex flex-col">\n    <header class="bg-white shadow-sm sticky top-0 z-10 transition-all duration-300">\n        <div class="container mx-auto px-4 py-4 flex justify-between items-center">\n            <div class="flex items-center space-x-2">\n                <i class="fa fa-file-text-o text-primary text-2xl"></i>\n                <h1 class="text-xl font-bold text-gray-800">华为账号用户认证协议</h1>\n            </div>\n        </div>\n    </header>\n\n    <main class="flex-grow container mx-auto px-4 py-8">\n        <div class="max-w-4xl mx-auto bg-white rounded-xl shadow-md overflow-hidden transition-all duration-300 hover:shadow-lg">\n            <div class="p-6 md:p-8">\n                <div class="mb-8">\n                    <h2 class="text-[clamp(1.5rem,3vw,2.5rem)] font-bold text-gray-900 mb-4 text-balance">服务条款</h2>\n                    <p class="text-gray-600">请仔细阅读以下条款，使用我们的服务即表示您同意这些条款。</p>\n                </div>\n\n                <div class="space-y-8">\n                    <section id="section1" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">1</span>\n                            服务概述\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            我们通过网站及移动应用（以下统称"服务"）为用户提供信息、工具和服务。这些服务可能包括但不限于内容浏览、社交互动、交易服务和个性化推荐。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            我们保留随时修改或停止服务的权利，而无需事先通知您。我们不会对您或任何第三方因服务的修改、暂停或终止而遭受的任何损失承担责任。\n                        </p>\n                    </section>\n\n                    <section id="section2" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">2</span>\n                            用户账号\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            使用我们的服务可能需要您创建一个账号。您同意提供准确、完整和最新的个人信息，并维护和及时更新这些信息。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            您对您账号下发生的所有活动负责。如果您发现任何未经授权使用您账号的情况，您应立即通知我们。您不得将您的账号转让给任何第三方。\n                        </p>\n                    </section>\n\n                    <section id="section3" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">3</span>\n                            隐私政策\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            我们重视您的隐私，并根据我们的隐私政策收集、使用和保护您的个人信息。使用我们的服务即表示您同意我们按照该隐私政策处理您的信息。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            我们可能会更新我们的隐私政策，建议您定期查看。继续使用我们的服务即表示您同意这些更新。\n                        </p>\n                    </section>\n\n                    <section id="section4" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">4</span>\n                            内容使用\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            我们服务中提供的内容（包括但不限于文本、图形、图像、视频、音频）受版权、商标和其他知识产权法律的保护。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            您可以为个人非商业用途查看和使用这些内容，但未经我们明确书面许可，不得复制、修改、分发、传输或创建衍生作品。\n                        </p>\n                    </section>\n\n                    <section id="section5" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">5</span>\n                            用户行为\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            您同意不利用我们的服务从事非法活动，或促进、鼓励任何非法活动。您不得干扰或破坏服务的正常运行，或试图访问未授权的系统或数据。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            您不得在服务中发布或传播垃圾邮件、病毒、恶意软件或任何其他有害内容。您不得收集或存储其他用户的个人信息。\n                        </p>\n                    </section>\n\n                    <section id="section6" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">6</span>\n                            免责声明\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            我们的服务按"原样"提供，不附带任何形式的明示或暗示保证，包括但不限于适销性、特定用途适用性和不侵权的保证。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            在适用法律允许的最大范围内，我们不对因使用或无法使用服务而导致的任何直接、间接、偶然、特殊、惩罚性或后果性损害承担责任。\n                        </p>\n                    </section>\n\n                    <section id="section7" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">7</span>\n                            法律适用与争议解决\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            本协议受[具体司法管辖区]法律管辖。因本协议引起的或与本协议有关的任何争议，应通过双方友好协商解决；协商不成的，任何一方均有权将争议提交[具体仲裁机构或法院]解决。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            如果本协议的任何条款被认定为无效或不可执行，该条款应被删除或修改，而其余条款应继续有效。\n                        </p>\n                    </section>\n\n                    <section id="section8" class="scroll-mt-20">\n                        <h3 class="text-xl font-bold text-gray-800 mb-4 flex items-center">\n                            <span class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center mr-3">8</span>\n                            协议更新\n                        </h3>\n                        <p class="text-gray-600 leading-relaxed mb-4">\n                            我们可能会不时更新本服务条款。当我们进行重大更改时，我们将通过在我们的网站上发布新的服务条款通知您，并且在某些情况下，我们可能会通过电子邮件或其他通信方式通知您。\n                        </p>\n                        <p class="text-gray-600 leading-relaxed">\n                            您继续使用我们的服务即表示您接受这些更新。我们鼓励您定期查看本服务条款。\n                        </p>\n                    </section>\n                </div>\n            </div>\n        </div>\n    </main>\n\n\n    </body></html>'
}

export const ERROR_MSG_MAP: Record<number, string> = {
  1001502001: '用户未登录华为账号，请前往设置-登录华为账号。',
  1001500001: '应用指纹证书校验失败，请检查client_id、应用指纹证书配置。',
  1001502014: '应用未申请scopes或permissions权限。',
};