import { https } from 'network';
import { AccountUtil, AppStorageMap, FormatUtil, Logger, RouterMap, RouterModule, UserInfoModel, } from 'commonlib';
import { IUserAccount } from 'network/src/main/ets/types/responseTypes/GetUserAccountResp';
import { MockStorageMap } from 'network/src/main/ets/mocks/Constants';

const TAG = '[OtherVM]';

@ObservedV2
export class OtherVM {
  private static _instance: OtherVM;
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
  @Trace public isOn: boolean = false

  public static get instance() {
    if (!OtherVM._instance) {
      OtherVM._instance = new OtherVM();
    }
    return OtherVM._instance;
  }

  init() {
    const userAccountMockData = AppStorage.get<IUserAccount>(MockStorageMap.USER_ACCOUNT);
    if (userAccountMockData) {
      this.account = userAccountMockData
      this.isOn = true
    }
  }

  public async getUserAccount(userId: number) {
    const res = await https.getUserAccount(userId);
    if (res.code === 0) {
      this.account = res.data;
    }
  }

  public cancelRelated() {
    this.isOn = false
    const account: IUserAccount = {
      id: 0,
      userId: 0,
      bankName: '',
      bankCardNo: '',
      bankAmount: 0,
      positionAmount: 0,
      accumulatedEarnings: 0,
    }
    AppStorage.setOrCreate<IUserAccount>(MockStorageMap.USER_ACCOUNT, account);
  }
}
