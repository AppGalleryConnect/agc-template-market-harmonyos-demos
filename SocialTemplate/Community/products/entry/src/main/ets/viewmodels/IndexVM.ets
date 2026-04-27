import { display } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  BaseViewModel, BreakpointUtils, MessageJumpManager,
  OHDialog,
  OHDialogModel, RouterMap, TCLogger
} from 'common';
import { CMChatFactory } from 'instant_messaging';
import { phoneRouterControl } from 'oh_router';
import { LoginPageBuilder } from 'person';
import { ChatJumpManager } from 'message';

const TAG = 'IndexVM';

@ObservedV2
export class IndexVM extends BaseViewModel {
  breakpoint: BreakpointUtils | null = null;

  constructor() {
    super();
    this.addSdkListener();
  }

  // 监听设备屏幕方向改变
  displayOrientationListener() {
    try {
      this.displayModel.isFoldable = display.isFoldable();
      display.on('change', (type: number) => {
        let displayClass = display.getDisplayByIdSync(type);
        // 横屏
        let landscapeType = [display.Orientation.LANDSCAPE, display.Orientation.LANDSCAPE_INVERTED]
        this.displayModel.isLandscape = landscapeType.includes(displayClass.orientation);
      })
    } catch (err) {
    }
  }

  registerBreakpointListener(context: UIContext) {
    this.breakpoint = new BreakpointUtils(context.getMediaQuery());
    this.breakpoint?.register();
  }

  unregisterBreakpointListener() {
    this.breakpoint?.unRegister();
  }

  async initSdk(context: common.Context | undefined) {
    let applicationContext = context as common.ApplicationContext;
    // todo:sdkAppID参数是腾讯云控制台即时通信模块创建的项目的appId，具体见readme
    let initResult = CMChatFactory.instance.initSDK(applicationContext, 0);
    if (initResult && CMChatFactory.instance.getLoginStatus() === 3) {
      if (this.userInfo.isLogin) {
        await CMChatFactory.instance.login(this.userInfo.id, this.userInfo.userSig ?? '')
          .then(() => {
            TCLogger.info(TAG, `sdk login success`);
          }).catch((err: BusinessError) => {
            TCLogger.error(TAG, `sdk login err = ` + JSON.stringify(err));
            this.kickedDialog();
          })
      }
    }
  }

  addSdkListener() {
    CMChatFactory.instance.addSDKListener({
      onKickedOffline: () => {
        this.kickedDialog();
      }
    });
  }

  private kickedDialog() {
    let dialogVM = new OHDialogModel();
    dialogVM.title = `你的账号在其他设备登录，其重新登录`;
    dialogVM.onValueConfirmClick = async (_model: Object) => {
      this.userInfo.isLogin = false;
      phoneRouterControl.jumpPage({
        pageName: RouterMap.LOGIN_PAGE,
        builder: wrapBuilder(LoginPageBuilder),
        onPop: (_popInfo: PopInfo) => {
          let mainBuilder = phoneRouterControl.getPageBuilder(RouterMap.MAIN_PAGE);
          phoneRouterControl.replacePage({
            pageName: RouterMap.MAIN_PAGE,
            builder: mainBuilder
          });
        }
      })
    };
    OHDialog.showPopup(dialogVM);
  }

  setRouterPage() {
    MessageJumpManager.gotoC2CChatPage = ChatJumpManager.gotoC2CChatPage;
    MessageJumpManager.gotoGroupChatPage = ChatJumpManager.gotoGroupChatPage;
    MessageJumpManager.gotoContactInfo = ChatJumpManager.gotoContactInfo;
    MessageJumpManager.gotoViewLocation = ChatJumpManager.gotoViewLocation;
    MessageJumpManager.gotoVideoPage = ChatJumpManager.gotoVideoPage;
    MessageJumpManager.gotoFullImagePage = ChatJumpManager.gotoFullImagePage;
    MessageJumpManager.gotoPrivateChatSettingPage = ChatJumpManager.gotoPrivateChatSettingPage;
  }
}
