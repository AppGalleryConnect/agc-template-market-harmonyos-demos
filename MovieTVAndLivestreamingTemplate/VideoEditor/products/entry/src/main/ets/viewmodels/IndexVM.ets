import { display, PersistenceV2 } from '@kit.ArkUI';
import { BaseViewModel, BreakpointUtils, RouterMap, UserInfo, TValueType } from 'common';
import { emitter } from '@kit.BasicServicesKit';
import { ActionWithAppBean } from '../utils/ActionWithAppBean';
import { phoneRouterControl } from 'oh_router';
import { LoginPageBuilder } from 'person/src/main/ets/views/LoginPage';
import { VipCenterPageBuilder } from 'person/src/main/ets/views/VipCenterPage';


@ObservedV2
export class IndexVM extends BaseViewModel {
  breakpoint: BreakpointUtils | null = null;

  displayOrientationListener() {
    // 监听设备屏幕方向改变
    this.displayModel.isFoldable = display.isFoldable();
    try {
      display.on('change', (type: number) => {
        let displayClass = display.getDisplayByIdSync(type);
        // 横屏
        let landscapeType = [display.Orientation.LANDSCAPE, display.Orientation.LANDSCAPE_INVERTED]
        this.displayModel.isLandscape = landscapeType.includes(displayClass.orientation);
      })
    }catch (error) {
    }
    // 监听折叠屏是否是展开状态
    this.displayModel.isExpanded = display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED;
    try {
      display.on('foldStatusChange', (data: display.FoldStatus) => {
        let isExpandedStatus = display.isFoldable() && data === display.FoldStatus.FOLD_STATUS_EXPANDED;
        this.displayModel.isExpanded = isExpandedStatus;
      });
    } catch (error) {
    }
  }

  registerBreakpointListener(context: UIContext) {
    this.breakpoint = new BreakpointUtils(context.getMediaQuery());
    this.breakpoint?.register();
  }

  unregisterBreakpointListener() {
    this.breakpoint?.unRegister();
  }

  doActionWithApp(key: string, data: TValueType = null) {
    let action = new ActionWithAppBean()
    action.action = key
    action.data = data;
    try {
      emitter.emit({ eventId: ActionWithAppBean.ACTION_WITH_APP }, {
        data: {
          data: action
        }
      })
    }catch (error) {
    }
  }

  cbActionWithApp: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
    if (!eventData || !eventData.data || !eventData.data.data) {
      return;
    }
    let appAction = eventData.data.data as ActionWithAppBean
    if (appAction.action === 'getLoginStatus') {
      let userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
      this.doActionWithApp('getLoginStatusRes', userInfo.isLogin)
    } else if (appAction.action === 'getVipStatus') {
      let userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
      this.doActionWithApp('getVipStatusRes', userInfo.isVIP)
    } else if (appAction.action === 'jump2LoginPage') {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.LOGIN_PAGE,
        builder: wrapBuilder(LoginPageBuilder)
      })
    } else if (appAction.action === 'jump2VipPage') {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.VIPCENTER_PAGE,
        builder: wrapBuilder(VipCenterPageBuilder),
      })
    }

  }
}
