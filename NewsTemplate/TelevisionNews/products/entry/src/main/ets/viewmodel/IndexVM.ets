import { AppStorageV2, display, UIContext, window } from '@kit.ArkUI';
import { authentication } from '@kit.AccountKit';
import { UtilLog } from '@hw-agconnect/util-log';
import {
  AppPrivacyUtils,
  BaseViewModel,
  BreakpointNameEnum,
  BreakpointUtils,
  HuaweiIDResp,
  RouterMap,
  RouterUtils,
  WindowModel,
} from 'lib_common';
import { PreloadUtils } from '../utils/PreloadUtils';
import { PhoneConstants } from '../constants/Contants';
import { FormCardRouter } from '../type/Types';
import { FormUtils } from '../utils/FormUtils';

const TAG = '[IndexVM]';

@ObservedV2
export class IndexVM extends BaseViewModel {
  @Trace privacyImpl: AppPrivacyUtils = AppPrivacyUtils.instance;
  formCardModel: FormCardRouter = AppStorageV2.connect(FormCardRouter, () => new FormCardRouter())!;
  @Trace openId: string = '';
  @Trace unionId: string = '';
  breakpoint: BreakpointUtils | null = null;
  context: UIContext
  @Trace isEnabled: boolean = true;

  constructor(context: UIContext) {
    super()
    this.context = context
  }

  // 是否纵向Tab
  @Computed
  get isTabVertical() {
    return [
      BreakpointNameEnum.LG,
      BreakpointNameEnum.XL,
    ].includes(this.breakPointModel.currentBreakpoint);
  }

  @Computed
  get barPosition() {
    if (this.isTabVertical) {
      return BarPosition.Start;
    }
    return BarPosition.End;
  }

  @Computed
  get tabWidth(): Length {
    if (this.isTabVertical) {
      return PhoneConstants.LEFT_TAB_BAR_WIDTH;
    }
    return '100%';
  }

  @Computed
  get tabBarHeight() {
    return this.tabHeight
  }

  @Computed
  get tabHeight(): Length {
    if (this.isTabVertical) {
      return '100%';
    }
    return PhoneConstants.BOTTOM_TAB_BAR_HEIGHT;
  }

  // 监听协议签署结果
  @Monitor('privacyImpl.agreeFlag')
  agreeFlagChange() {
    if (this.privacyImpl.agreeFlag) {
      // 签署协议后，执行静默登录
      this.funcCore();
      PreloadUtils.initPreload();
      RouterUtils.replacePathByName(RouterMap.Index_Page);
    }
  }

  checkJumpNewsDetail() {
    if (this.formCardModel.id && this.formCardModel.avId) {
      this.backToHomePage();
      let routerParams: Record<string, string> = {
        'avId': this.formCardModel.avId,
      };
      RouterUtils.pushPathByName(RouterMap.VIDEO_PROGRAM_DETAILS, routerParams)
      FormUtils.updateWidgets(this.context.getHostContext()!)
      this.formCardModel.id = 0;
    }
  }

  backToHomePage() {
    const currentPage = RouterUtils.getStack().getAllPathName().pop();
    if (currentPage !== RouterMap.Index_Page) {
      RouterUtils.popToName(RouterMap.Index_Page, undefined, false);
    }
  }

  funcCore() {
    this.loginWithHuaweiID().then(res => {
      this.openId = res.openId;
      this.unionId = res.unionId;
      this.userInfoModel.authCode = res.authCode;
    });
  }

  private loginWithHuaweiID(): Promise<HuaweiIDResp> {
    return new Promise((resolve, reject) => {
      let loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
      loginRequest.forceLogin = false;
      let controller = new authentication.AuthenticationController();
      controller.executeRequest(loginRequest).then((data) => {
        let loginWithHuaweiIDResponse = data as authentication.LoginWithHuaweiIDResponse;
        let authCode = loginWithHuaweiIDResponse.data?.authorizationCode;
        let openId = loginWithHuaweiIDResponse.data?.openID;
        let unionId = loginWithHuaweiIDResponse.data?.unionID;
        resolve({ openId, unionId, authCode } as HuaweiIDResp);

      }).catch((error: BusinessError) => {
        UtilLog.error(TAG, 'error: %{public}s', JSON.stringify(error));
        if (error.code === authentication.AuthenticationErrorCode.ACCOUNT_NOT_LOGGED_IN) {
        }
        // todo 模板适配无法登录华为账号场景下可以正常访问，正常开发需要根据实际场景选择  reject(error);
        resolve({ openId: '1', unionId: '1', authCode: '1' } as HuaweiIDResp);
      });
    });
  }

  redirect() {
    this.privacyImpl.subscribe();
    if (!this.privacyImpl.agreeFlag) {
      // 未同意隐私协议，不进入首页
      return;
    }
    this.funcCore();
    RouterUtils.replacePathByName(RouterMap.Index_Page);
  }

  registerBreakpointListener(context: UIContext) {
    this.breakpoint = new BreakpointUtils(context.getMediaQuery());
    this.breakpoint?.register();
  }

  unSubscribeOff() {
    this.privacyImpl.unSubscribe();
  }

  // 监听WindowStage生命周期变化
  windowStageEventListener() {
    let windowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
    windowModel.windowStage?.on('windowStageEvent', (type: window.WindowStageEventType) => {
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
          const displayClass = display.getDisplayByIdSync(type);
          // 横屏
          const landscapeType = [display.Orientation.LANDSCAPE, display.Orientation.LANDSCAPE_INVERTED];
          this.displayModel.isLandscape = landscapeType.includes(displayClass.orientation);
          UtilLog.debug(TAG, 'this.displayModel.isLandscape: ' + this.displayModel.isLandscape);
        } catch (e) {
          UtilLog.error(TAG, 'Fail to getDisplayByIdSync, error: ' + JSON.stringify(e));
        }
      })
    } catch (e) {
      UtilLog.error(TAG, 'displayOrientationListener fail, error: ' + JSON.stringify(e));
    }
  }
}
