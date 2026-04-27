import { util } from '@kit.ArkTS';
import { PersistenceV2 } from '@kit.ArkUI';
import { UserInfoModel } from '../models/UserInfoModel';

@ObservedV2
export class GlobalStateMgr {
  @Trace
  public rootPageActiveTabId: string = '';
  @Trace
  public isNavPathStackEmpty: boolean = true;
  @Trace
  public cartVersion: string = util.generateRandomUUID(false);
  @Trace
  public cartTotal: number = 0;
  @Trace
  public isLogin: boolean = false;
  @Trace
  public userInfo: UserInfoModel = new UserInfoModel();
}

class IData {
  public get global() {
    return PersistenceV2.connect(
      GlobalStateMgr,
      'GlobalStateMgr',
      () => new GlobalStateMgr(),
    )!;
  }
}

const iData = new IData();

export { iData };
