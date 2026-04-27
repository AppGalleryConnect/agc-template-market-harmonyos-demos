import { AccountUtil, BreakpointModel, UserInfo } from 'commonlib';
import { FormCardJump, TabListItem } from '../types/Types';
import { HomePageBuilder } from 'home';
import { ClassificationPageBuilder } from 'classification';
import { MinePageBuilder } from 'mine';
import { AppStorageV2 } from '@kit.ArkUI';
import { HealthyPageBuilder } from 'calories';
import { NavItemModel } from 'floating_navbar';

@ObservedV2
export class MainEntryVM {
  @Trace userInfo: UserInfo = AccountUtil.getUserInfo();
  @Trace formCardJump: FormCardJump = AppStorageV2.connect(FormCardJump, () => new FormCardJump())!;
  @Trace curIndex: number = 0;
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  public tabList: TabListItem[] = [
    {
      label: '首页',
      icon: $r('app.media.icon_home_off'),
      iconChecked: $r('app.media.icon_home_on'),
      component: wrapBuilder(HomePageBuilder),
    },
    {
      label: '分类',
      icon: $r('app.media.icon_type_off'),
      iconChecked: $r('app.media.icon_type_on'),
      component: wrapBuilder(ClassificationPageBuilder),
    },
    {
      label: '健康',
      icon: $r('app.media.icon_health_off'),
      iconChecked: $r('app.media.icon_health_on'),
      component: wrapBuilder(HealthyPageBuilder),
    },
    {
      label: '我的',
      icon: $r('app.media.icon_mine_off'),
      iconChecked: $r('app.media.icon_mine_on'),
      component: wrapBuilder(MinePageBuilder),
    },
  ];

  public navItems: NavItemModel[] = [
    { title: this.tabList[0].label, icon: this.tabList[0].icon, selectedIcon: this.tabList[0].iconChecked },
    { title: this.tabList[1].label, icon: this.tabList[1].icon, selectedIcon: this.tabList[1].iconChecked },
    { title: this.tabList[2].label, icon: this.tabList[2].icon, selectedIcon: this.tabList[2].iconChecked },
    { title: this.tabList[3].label, icon: this.tabList[3].icon, selectedIcon: this.tabList[3].iconChecked }
  ];

  private static _instance: MainEntryVM;

  public static get instance() {
    if (!MainEntryVM._instance) {
      MainEntryVM._instance = new MainEntryVM();
    }
    return MainEntryVM._instance;
  }

  @Computed
  get isLandscape() {
    let size = this.breakPointModel.currentBreakpoint;
    if (size === 'sm' || size === 'md') {
      return false;
    }
    return true;
  }

  @Computed
  get breakPoint() {
    return this.breakPointModel.currentBreakpoint;
  }
}
