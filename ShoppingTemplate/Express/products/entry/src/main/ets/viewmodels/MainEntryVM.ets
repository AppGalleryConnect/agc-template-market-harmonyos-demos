import { RouterModule } from 'lib_foundation';
import { WindowUtil } from 'module_base';

const TAG: string = 'MainEntryVM';

@ObservedV2
export class MainEntryVM {
  // 路由栈实例
  @Trace navStack: NavPathStack = RouterModule.stack;
  // 当前页签
  @Trace curIndex: number = 0;
  private static _instance: MainEntryVM;

  public static get instance() {
    if (!MainEntryVM._instance) {
      MainEntryVM._instance = new MainEntryVM();
    }
    return MainEntryVM._instance;
  }

  init() {
    WindowUtil.initWindowUtil();
  }
}
