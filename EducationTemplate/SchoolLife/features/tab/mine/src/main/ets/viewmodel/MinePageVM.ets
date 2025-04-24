import { AccountUtil, UserInfoModel } from 'commonlib';
import { promptAction } from '@kit.ArkUI';
import { UserApi } from 'network';

@ObservedV2
export class MinePageVM {
  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();

  @Trace hasBindAccount: boolean = false;

  @Monitor('userInfo.phone')
  public bindPhoneStatusChange(monitor: IMonitor) {
    this.hasBindAccount = monitor.value()?.now !== '';
  }

  private static _instance: MinePageVM;

  public static get instance() {
    if (!MinePageVM._instance) {
      MinePageVM._instance = new MinePageVM();
    }
    return MinePageVM._instance;
  }

  // 绑定华为账号
  public async connectHuaweiAccount() {
    const code = await AccountUtil.connectHuaweiAccount(getContext(this));
    if (code) {
      try {
        const bindRes = await UserApi.bindPhone(code);
        if (bindRes.code === 0) {
          const userInfoRes = await UserApi.getUserInfo();
          if (userInfoRes.code === 0) {
            AccountUtil.setUserInfo(userInfoRes.data as UserInfoModel);
            promptAction.showToast({ message: '手机号绑定成功！' });
          }
        }
      } catch (err) {
        promptAction.showToast({ message: '手机号绑定失败，请稍后重试' });
      }
    } else {
      promptAction.showToast({ message: '手机号绑定失败，请稍后重试' });
    }
  }

  public disconnectHuaweiAccount() {
    AccountUtil.cancelAuthorization();
  }

  public updateNickName(name: string) {
    UserApi.updateUserNickname(name).then(() => {
      this.userInfo.nickname = name;
    });
  }
}
