import { PersistenceV2 } from '@kit.ArkUI';
import { UserInfoModel } from 'lib_common';
import { AuthorResponse, MineServiceApi } from 'lib_api';
import { ProtocolData } from './ProtocolData';

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
   * 重新赋值userInfoModel
   */
  public queryUserInfo() {
    if (this.checkLogin()) {
      const user = MineServiceApi.queryAuthorInfo('', this.userInfoModel.loginChannel)
      if (user) {
        this.handleUserInfo(user);
      }
    }
  }

  /**
   * 华为账号登录
   */
  public huaweiLogin(nickPhone: string) {
    const user = MineServiceApi.signIn('hw', nickPhone);
    if (user) {
      this.userInfoModel.loginChannel = 'hw';
      this.handleUserInfo(user);
    }
  }

  /**
   * 账密登录
   */
  public accountPasswordLogin() {
    const user = MineServiceApi.signIn()
    if (user) {
      this.userInfoModel.loginChannel = 'pw';
      this.handleUserInfo(user);
    }
  }

  /**
   * 微信登录
   */
  public wechatLogin() {
    const channel = 'wechat';
    const user = MineServiceApi.signIn(channel)
    if (user) {
      this.userInfoModel.loginChannel = channel;
      this.handleUserInfo(user);
    }
  }

  /**
   * userinfo赋值
   * @param user
   */
  private handleUserInfo(user: AuthorResponse) {
    this.userInfoModel.isLogin = true;
    this.userInfoModel.authorId = user.authorId;
    this.userInfoModel.authorNickName = user.authorNickName;
    this.userInfoModel.authorIcon = user.authorIcon;
    this.userInfoModel.authorDesc = user.authorDesc;
    this.userInfoModel.authorPhone = user.authorPhone || '';
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
        this.userInfoModel.authorId = '';
        this.userInfoModel.authorNickName = '';
        this.userInfoModel.authorIcon = '';
        this.userInfoModel.authorPhone = '';
        this.userInfoModel.authorDesc = '';
        resolve();
      }, 500);
    });
  }

  /**
   * 查询用户协议内容
   * @returns
   */
  public getUserAgreeInfo() {
    return ProtocolData.userProtocol;
  }

  /**
   * 查询隐私协议内容
   * @returns
   */
  public getPrivacyInfo() {
    return ProtocolData.privacyProtocol;
  }

  /**
   * 查询华为用户协议内容
   * @returns
   */
  public getHuaweiUserAgreeInfo() {
    return ProtocolData.huaweiUserProtocol;
  }

  /**
   * 查询第三方信息共享清单
   * @returns
   */
  public getThirdPartyInfo() {
    return ProtocolData.thirdPartyInfo;
  }

  /**
   * 查询个人信息收集清单
   * @returns
   */
  public getPersonalInfoCollection() {
    return ProtocolData.personalInfoCollection;
  }
}
