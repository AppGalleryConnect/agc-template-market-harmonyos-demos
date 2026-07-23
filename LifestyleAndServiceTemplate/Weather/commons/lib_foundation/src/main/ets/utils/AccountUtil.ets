import { PersistenceV2 } from '@kit.ArkUI';
import { UserInfo, UserInfoModel } from '../types/UserInfo';

@ObservedV2
export class AccountUtil {
  private static _userInfo: UserInfoModel = new UserInfoModel();

  public static setUserInfo() {
    AccountUtil._userInfo = PersistenceV2.connect(
      UserInfoModel,
      'userInfo',
      () => new UserInfoModel(),
    )!;
  }

  public static getUserInfo(): UserInfoModel {
    return AccountUtil._userInfo;
  }

  public static getCurrentUser(): string | undefined {
    return AccountUtil._userInfo.code;
  }

  public static setCurrentUser(code: string) {
    AccountUtil._userInfo.code = code;
  }

  public static updateUserInfo(data: UserInfo) {
    AccountUtil._userInfo.id = data.id;
    AccountUtil._userInfo.avatar = data.avatar;
    AccountUtil._userInfo.nickname = data.nickname;
    AccountUtil._userInfo.cellphone = data.cellphone;
    AccountUtil._userInfo.isLogin = data.isLogin;
  }

  public static updateAvatar(avatar: string) {
    AccountUtil._userInfo.avatar = avatar;
  }

  public static updateName(name: string) {
    AccountUtil._userInfo.nickname = name;
  }

  public static updateCellphone(cellphone: string) {
    AccountUtil._userInfo.cellphone = cellphone;
  }

  public static resetInfo() {
    AccountUtil._userInfo.id = 0;
    AccountUtil._userInfo.avatar = '';
    AccountUtil._userInfo.nickname = '';
    AccountUtil._userInfo.cellphone = '';
    AccountUtil._userInfo.code = '';
    AccountUtil._userInfo.isLogin = false;
  }
}
