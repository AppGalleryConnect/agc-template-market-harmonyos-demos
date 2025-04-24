import { AccountUtil, UserInfoModel } from '../utils/AccountUtil';
// 路由工具
import { RouterModule } from '../utils/RouterModule';

import { Permissions } from '@kit.AbilityKit';

const TAG: string = 'MainEntryVM';

@ObservedV2
export class MainEntryVM {
  private static _instance: MainEntryVM;
  @Trace navStack: NavPathStack = RouterModule.getStack();
  @Trace curIndex: number = 0;
  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();

  public static get instance() {
    if (!MainEntryVM._instance) {
      MainEntryVM._instance = new MainEntryVM();
    }
    return MainEntryVM._instance;
  }

  // 初始化
  public async init() {
    await AccountUtil.silentLogin();
  }
}
