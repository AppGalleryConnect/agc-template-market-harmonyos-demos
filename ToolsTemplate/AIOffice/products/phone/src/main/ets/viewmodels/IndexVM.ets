import { display, uiObserver, window } from '@kit.ArkUI';
import * as wxopensdk from '@tencent/wechat_open_sdk';
import { AccountApi,
  ApiController,
  Channel, LoginChannelType,
  LoginInfoOptions,
  LoginParams, LoginSheetUtils, LoginType } from 'aggregated_login';
import { BaseViewModel, BreakpointUtils,
  CommonConfirmDialog,
  ERROR_MSG_MAP,
  Logger, PreferenceUtils, RouterMap, RouterUtils } from 'lib_common';
import { agreePrivacyKey, REQUIRE_LOGIN_PAGE_LIST } from '../common/Constants';
import { BusinessError } from '@kit.BasicServicesKit';
import { ProtocolData } from 'aggregated_login/src/main/ets/common/ProtocolData';

const TAG = 'IndexVM';

@ObservedV2
export class IndexVM extends BaseViewModel {
  // todo: 自行调整是否支持开屏广告
  @Trace isShowAd: boolean = false;
  breakpoint: BreakpointUtils | null = null;
  @Trace anonymousPhone: string = '177******96';
  private accountInstance: AccountApi = new AccountApi();
  // todo 需要传入应用申请到的AppID
  wxApi = wxopensdk.WXAPIFactory.createWXAPI('xxx')
  huaweiLogin = async (loginParams: LoginParams): Promise<void> => {
    this.accountInstance.huaweiLogin(loginParams.phoneNumbers ?? '');
    LoginSheetUtils.close()
  }
  wxLogin = async (): Promise<void> => {
    this.accountInstance.wechatLogin();
    LoginSheetUtils.close()
  }
  verifyCode = async (): Promise<void> => {
    // this.accountInstance.accountPasswordLogin();
  }
  handleLoginFail = (loginChannelType: LoginChannelType, error: BusinessError | wxopensdk.BaseResp) => {
    if (loginChannelType === LoginChannelType.HUAWEI) {
      const businessError = error as BusinessError
      const errorMsg = ERROR_MSG_MAP[businessError.code] ?? '未知错误。';
      CommonConfirmDialog.show({
        primaryTitle: '温馨提示',
        content: errorMsg + '是否先模拟登录成功？',
        confirm: () => {
          this.accountInstance.huaweiLogin(this.anonymousPhone);
          LoginSheetUtils.close()
        }
      })
      return;
    }
  }
  obtainVerifyCode: () => Promise<void> = () => new Promise(() => {
  });

  redirect() {
    if (this.isAgreePrivacy()) {
      const targetPage = this.isShowAd ? RouterMap.SPLASH_PAGE : RouterMap.INDEX_PAGE;
      RouterUtils.replacePathByName(targetPage);
    } else {
      RouterUtils.replacePathByName(RouterMap.SAFE_PAGE);
    }
  }

  isAgreePrivacy() {
    return PreferenceUtils.getInstance().get(agreePrivacyKey) as boolean;
  }

  setInterception() {
    RouterUtils.getStack().setInterception({
      willShow: (from: NavDestinationContext | NavBar, to: NavDestinationContext | NavBar,
        operation: NavigationOperation, animated: boolean) => {
        if (typeof to === 'string') {
          Logger.info(TAG, 'target page is navigation home page.');
          return;
        }
        let target: NavDestinationContext = to as NavDestinationContext;

        // 拦截依赖登录的页面
        if (!this.userInfoModel.isLogin && REQUIRE_LOGIN_PAGE_LIST.includes(target?.pathInfo?.name as RouterMap)) {
          target.pathStack.pop();
          LoginSheetUtils.open({
            icon: $r('app.media.startIcon'),
            themeColor: $r('sys.color.icon_emphasize'),
            isSheet: true,
            autoSheet: true,
            isPersistence: false,
            loginTypes: [new Channel(LoginType.WECHAT, '微信', {
              appId: 'xxx'
            }, $r('app.media.ic_wechat'))],
            privacyContent: [{
              privacyLabel: '《用户协议》',
              privacyUrl: ProtocolData.userProtocol,
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
            apiController: new ApiController(this.huaweiLogin, this.wxLogin, this.verifyCode),
            handleLoginFail: this.handleLoginFail,
            obtainVerifyCode: this.obtainVerifyCode
          } as LoginInfoOptions);
        }
      },
    })
  }

  registerBreakpointListener(context: UIContext) {
    this.breakpoint = new BreakpointUtils(context.getMediaQuery());
    this.breakpoint?.register();
  }

  unregisterBreakpointListener() {
    this.breakpoint?.unRegister();
  }

  // 监听NavDestination组件的状态变化
  navDestinationListener() {
    try {
      uiObserver.on('navDestinationUpdate', (info: uiObserver.NavDestinationInfo) => {
        this.navRouteModel.navDestinationUpdateListeners.forEach((callback) => {
          callback(info)
        })
      })
    } catch (error) {
      Logger.error(TAG, 'navDestinationListener error: ' + JSON.stringify(error));
    }
  }

  // 监听WindowStage生命周期变化
  windowStageEventListener() {
    let windowStage = AppStorage.get('windowStage') as window.WindowStage;
    windowStage.on('windowStageEvent', (type: window.WindowStageEventType) => {
      this.windowStageModel.windowStageEventListeners.forEach((callback) => {
        callback(type)
      })
    });
  }

  // 监听设备屏幕方向改变
  displayOrientationListener() {
    try {
      this.displayModel.isFoldable = display.isFoldable();
      display.on('change', (type: number) => {
        try {
          let displayClass = display.getDisplayByIdSync(type);
          // 横屏
          let landscapeType = [display.Orientation.LANDSCAPE, display.Orientation.LANDSCAPE_INVERTED]
          this.displayModel.isLandscape = landscapeType.includes(displayClass.orientation);
        } catch (error) {
          Logger.error(TAG, 'getDisplayByIdSync error: ' + JSON.stringify(error));
        }
      })
    } catch (error) {
      Logger.error(TAG, 'displayOrientationListener error: ' + JSON.stringify(error));
    }
  }
}
