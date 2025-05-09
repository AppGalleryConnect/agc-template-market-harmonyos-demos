import { AccountUtil, UserInfoModel } from './AccountUtil';
import { PermissionUtil } from './PermissionUtil';
import { RouterModule } from './RouterModule';
import { Permissions } from '@kit.AbilityKit';
import { DialogMap } from '../constants/CommonEnums';
import { Logger } from './Logger';


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
    AccountUtil.silentLogin();
  }

  // 获取位置授权
  public requestLocationPermission() {
    const permissions: Permissions[] = ['ohos.permission.APPROXIMATELY_LOCATION'];
    PermissionUtil.requestPermissions(permissions, () => {
      Logger.debug(TAG, 'request location permission finished');
    });
  }

  // 绑定手机号
  public requestPhoneNumber() {
    RouterModule.openDialog(DialogMap.BIND_PHONE_DIALOG,);
  }
}
