import { AppStorageV2 } from '@kit.ArkUI';
import { BaseViewModel, BreakpointNameEnum, ContextUtil, RouterModule } from 'lib_foundation';
import { PageRouterModel, TabListItem } from '../types';


@ObservedV2
export class MainEntryVM extends BaseViewModel {
  // 路由栈实例
  @Trace navStack: NavPathStack = RouterModule.stack;
  @Trace pageRouter: PageRouterModel = AppStorageV2.connect(PageRouterModel, () => new PageRouterModel())!;
  // 当前页签
  @Trace curIndex: number = 0;
  @Trace firstBackTime: number = 0;
  tabList: TabListItem[] = [
    {
      label: '首页',
      icon: $r('app.media.ic_home'),
      iconChecked: $r('app.media.ic_home_selected'),
    },
    {
      label: '查快递',
      icon: $r('app.media.ic_express'),
      iconChecked: $r('app.media.ic_express_selected'),
    },
    {
      label: '福利',
      icon: $r('app.media.ic_gift'),
      iconChecked: $r('app.media.ic_gift_selected'),
    },
    {
      label: '我的',
      icon: $r('app.media.ic_mine'),
      iconChecked: $r('app.media.ic_mine_selected'),
    }
  ]

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
      return 96;
    }
    return '100%';
  }

  @Computed
  get tabHeight(): Length {
    if (this.isTabVertical) {
      return 400;
    }
    return 48;
  }

  onBackPressed() {
    let nowTime = Date.now();
    if (nowTime - this.firstBackTime < 1500) {
      return false;
    } else {
      this.firstBackTime = nowTime;
      ContextUtil.showToast({ message: '再按一次退出应用' });
      return true;
    }
  }
}
