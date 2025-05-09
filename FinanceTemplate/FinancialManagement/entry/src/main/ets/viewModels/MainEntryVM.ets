import { TabListItem } from '../types';
import { HomePageBuilder } from 'home'
import { MinePageBuilder } from 'mine'
import { HUAWEIAccountModel, RouterModule, WindowUtil, } from 'commonlib';

import { PersistenceV2 } from '@kit.ArkUI';
import { MockStorageMap } from 'network/src/main/ets/mocks/Constants';
import { IProductRequest } from 'network';

const TAG: string = 'MainEntryVM';

@ObservedV2
export class MainEntryVM {
  private static _instance: MainEntryVM;

  public static get instance() {
    if (!MainEntryVM._instance) {
      MainEntryVM._instance = new MainEntryVM();
    }
    return MainEntryVM._instance;
  }

  // 路由栈实例
  @Trace navStack: NavPathStack = RouterModule.getStack();
  // 底部tab页签列表
  public tabList: TabListItem[] = [
    {
      label: '理财',
      icon: $r('app.media.ic_home'),
      iconChecked: $r('app.media.ic_home_checked'),
      component: wrapBuilder(HomePageBuilder),
    },
    {
      label: '我的',
      icon: $r('app.media.ic_mine'),
      iconChecked: $r('app.media.ic_mine_checked'),
      component: wrapBuilder(MinePageBuilder),
    },
  ];
  // 当前页签
  @Trace curIndex: number = 0;
  // 避让区
  @Trace accountInfo: HUAWEIAccountModel = PersistenceV2.connect(
    HUAWEIAccountModel,
    'accountInfo',
    () => new HUAWEIAccountModel(),
  )!;

  // 初始化
  public async init() {
    WindowUtil.initWindowUtil();
  }
}
