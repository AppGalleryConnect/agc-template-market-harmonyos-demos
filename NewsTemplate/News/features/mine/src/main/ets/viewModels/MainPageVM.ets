import { AccountUtil, DialogMap, Logger, PermissionUtil, RouterModule, UserInfoModel } from 'commonlib';
import { Permissions } from '@kit.AbilityKit';

const TAG: string = 'MainPageVM';

@ObservedV2
export class MainPageVM {
  private static _instance: MainPageVM;

  @Trace navStack: NavPathStack = RouterModule.getStack();

  @Trace curIndex: number = 0;

  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();
  @Trace message: string = 'Hello World';
  @Trace name: string = '177****4565'
  @Trace score: string = '20'
  @Trace changeFontSize: number = 0;
  @Trace fontSizeText: string = '标准';
  @Trace comment: string = '真是一个好消息～哈哈哈～';

  public static get instance() {
    if (!MainPageVM._instance) {
      MainPageVM._instance = new MainPageVM();
    }
    return MainPageVM._instance;
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


@ObservedV2
export class UserInfoStorage {
  idToken: string = ''
  authCode: string = ''
  @Trace avatar: string = ''
  @Trace phoneNumber: string = ''
  @Trace userName: string = ''
}