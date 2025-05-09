import { AccountUtil, HUAWEIAccountModel, RouterModule, UserInfoModel } from 'commonlib';
import { https, UserLoginResp, GetUserInfoResp } from 'network';
import { UserInfo } from 'commonlib/src/main/ets/types/Types';

const TAG: string = 'MainEntryVM';

@ObservedV2
export class MainEntryVM {
  @Trace navStack: NavPathStack = RouterModule.getStack();
  @Trace accountInfo: HUAWEIAccountModel = AccountUtil.getAccountInfo();
  // 当前页签
  @Trace curIndex: number = 0;
  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();

  private static _instance: MainEntryVM;

  public static get instance() {
    if (!MainEntryVM._instance) {
      MainEntryVM._instance = new MainEntryVM();
    }
    return MainEntryVM._instance;
  }


  // 初始化
  public async init() {
    if (this.accountInfo) {
      this.getLoginUserInfo();
    }
  }

  public async getLoginUserInfo() {
    const loginToken = this.accountInfo.loginToken;
    if (!loginToken) {
      const res = await https.userLogin();
      if (res.code === 0) {
        this.accountInfo.loginToken = res.data.loginToken;
        this.updateUserInfo(res.data);
      }
    } else {
      const res = await https.getUserInfo();
      if (res.code === 0) {
        this.updateUserInfo(res.data);
      }
    }
  }

  public updateUserInfo(data: UserLoginResp | GetUserInfoResp) {
    const info: UserInfo = {
      avatar: data.avatar,
      name: data.name,
      nickname: data.nickname,
      sex: data.sex,
      cellphone: data.cellphone,
      birthday: data.birthday,
      id: data.id,
    };
    AccountUtil.updateUserInfo(info);
  }
}
