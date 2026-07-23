import {
  BaseViewModel, CommonConstants, GlobalContext,
} from 'lib_common';
import { AccountApi } from 'lib_account';
import { PhoneConstants, TABS_INFO } from '../common/Constants';

@ObservedV2
export class IndexPageViewModel extends BaseViewModel {
  @Trace translateY: string | number = '';
  @Trace firstBackTime: number = 0;

  @Monitor('tabModel.showTabBar')
  onChangeShowTabBar(monitor: IMonitor) {
    if (this.tabModel.isTabVertical) {
      return;
    }
    let isShowCustomTabBar = monitor.value()?.now as boolean;
    if (isShowCustomTabBar) {
      this.translateY = '';
    } else {
      this.translateY = '100%';
    }
  }

  @Monitor('tabModel.isTabVertical')
  onShowChangeTabBar(monitor: IMonitor) {
    let isShowCustomTabBar = monitor.value()?.now as boolean
    if (isShowCustomTabBar) {
      this.translateY = '';
      this.tabModel.showTabBar = true;
    }
  }

  refreshUserInfo() {
    new AccountApi().queryUserInfo();
  }

  onBackPressed() {
    let nowTime = Date.now();
    if (nowTime - this.firstBackTime < 1500) {
      return false;
    } else {
      this.firstBackTime = nowTime;
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '再按一次退出' });
      return true;
    }
  }

  @Computed
  get barPosition() {
    if (this.tabModel.isTabVertical) {
      return BarPosition.Start;
    }
    return BarPosition.End;
  }

  @Computed
  get tabWidth(): Length {
    if (this.tabModel.isTabVertical) {
      return PhoneConstants.LEFT_TAB_BAR_WIDTH;
    }
    return CommonConstants.FULL_PERCENT;
  }

  @Computed
  get tabHeight(): Length {
    if (this.tabModel.isTabVertical) {
      return PhoneConstants.LEFT_TAB_BAR_ITEM_HEIGHT * TABS_INFO.length;
    }
    return PhoneConstants.BOTTOM_TAB_BAR_HEIGHT;
  }

  @Computed
  get paddingBottom() {
    if (this.tabModel.isTabVertical) {
      return 0;
    }
    return this.windowModel.windowBottomPadding;
  }

  @Computed
  get tabBarHeight() {
    if (this.tabModel.isTabVertical || this.tabModel.showTabBar) {
      return this.tabHeight;
    }
    return 0
  }
}