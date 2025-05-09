import { AccountUtil, DialogMap, Logger, PermissionUtil, RouterModule, UserInfoModel } from 'commonlib';
import { Permissions } from '@kit.AbilityKit';

const TAG: string = 'HomePageVM';

@ObservedV2
export class HomePageVM {
  private static _instance: HomePageVM;

  @Trace navStack: NavPathStack = RouterModule.getStack();

  @Trace curIndex: number = 0;

  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();
  @Trace message: string = 'Hello World';
  @Trace name: string = '177****4565'
  @Trace score: string = '20'
  @Trace changeFontSize: number = 0;
  @Trace comment: string = '';

  public static get instance() {
    if (!HomePageVM._instance) {
      HomePageVM._instance = new HomePageVM();
    }
    return HomePageVM._instance;
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
