import { AccountUtil, DialogMap, Logger, PermissionUtil, RouterModule, UserInfoModel } from 'commonlib';
import { Permissions } from '@kit.AbilityKit';

const TAG: string = 'MainEntryVM';

@ObservedV2
export class MainEntryVM {
  private static _instance: MainEntryVM;

  @Trace navStack: NavPathStack = RouterModule.getStack();

  @Trace curIndex: number = 0;

  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();

  @Trace changeFontSize: number = 0;

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


  // 绑定手机号
  public requestPhoneNumber() {
    RouterModule.openDialog(DialogMap.BIND_PHONE_DIALOG,);
  }
}
