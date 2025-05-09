import { https } from 'network';
import { AccountUtil, AppStorageMap, FormatUtil, Logger, RouterMap, RouterModule, UserInfoModel, } from 'commonlib';
import { IUserAccount } from 'network/src/main/ets/types/responseTypes/GetUserAccountResp';

const TAG = '[OtherVM]';

@ObservedV2
export class AccountVM {
  private static _instance: AccountVM;
  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();
  @Trace public account: IUserAccount = {
    id: 0,
    userId: 0,
    bankName: '',
    bankCardNo: '',
    bankAmount: 0,
    positionAmount: 0,
    accumulatedEarnings: 0,
  }

  public static get instance() {
    if (!AccountVM._instance) {
      AccountVM._instance = new AccountVM();
    }
    return AccountVM._instance;
  }

  init() {
    this.getUserAccount(this.userInfo.id)
  }


  public async getUserAccount(userId: number) {
    const res = await https.getUserAccount(userId);
    if (res.code === 0) {
      this.account = res.data;
    }
  }
}
