import { AccountUtil } from 'account';

@ObservedV2
export class MainEntryVM {
  private static _instance: MainEntryVM;

  public static get instance() {
    if (!MainEntryVM._instance) {
      MainEntryVM._instance = new MainEntryVM();
    }
    return MainEntryVM._instance;
  }

  public init() {
    // 登录
    AccountUtil.initLogin().then(() => {
      AccountUtil.getUserInfo();
    });
  }
}