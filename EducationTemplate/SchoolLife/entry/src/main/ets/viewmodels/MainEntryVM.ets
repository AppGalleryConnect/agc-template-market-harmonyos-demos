import { AccountUtil, RouterModule } from 'commonlib';

@ObservedV2
export class MainEntryVM {
  private static _instance: MainEntryVM;

  @Trace navStack: NavPathStack = RouterModule.getStack();

  @Trace curIndex: number = 0;

  public static get instance() {
    if (!MainEntryVM._instance) {
      MainEntryVM._instance = new MainEntryVM();
    }
    return MainEntryVM._instance;
  }

  // 初始化
  public async init() {
    AccountUtil.silentLogin();
  }
}
