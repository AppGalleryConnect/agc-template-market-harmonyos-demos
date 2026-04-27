import { PersistenceV2 } from '@kit.ArkUI';
import { UserInfoModel } from 'aggregated_login';
import { UserResponse, UserServiceApi } from 'module_base';

/**
 * 账号类
 */
export class AccountApi {
  private userInfoModel: UserInfoModel = new UserInfoModel();

  constructor() {
    this.userInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  }

  /**
   * 判断是否登录
   * @returns
   */
  public checkLogin(): boolean {
    return this.userInfoModel.isLogin;
  }

  /**
   * 华为账号登录
   */
  public async huaweiLogin(nickPhone: string) {
    const user = await UserServiceApi.signIn('hw', nickPhone);
    if (user) {
      this.userInfoModel.loginChannel = 'hw';
      this.handleUserInfo(user);
    }
  }

  /**
   * userinfo赋值
   * @param user
   */
  private handleUserInfo(user: UserResponse) {
    this.userInfoModel.isLogin = true;
    this.userInfoModel.userId = user.userId;
    this.userInfoModel.userNickName = user.userNickName;
    this.userInfoModel.userIcon = user.userIcon;
  }

  /**
   * 查询已登录的用户信息
   * @returns
   */
  public getUserInfo() {
    return this.userInfoModel;
  }

  /**
   * 退出登录
   */
  public async signOut(): Promise<void> {
    return new Promise((resolve) => {
      setTimeout(() => {
        this.userInfoModel.isLogin = false;
        this.userInfoModel.loginChannel = '';
        this.userInfoModel.userId = '';
        this.userInfoModel.userNickName = '';
        this.userInfoModel.userIcon = '';
        this.userInfoModel.userPhone = '';
        resolve();
      }, 500);
    });
  }
}
