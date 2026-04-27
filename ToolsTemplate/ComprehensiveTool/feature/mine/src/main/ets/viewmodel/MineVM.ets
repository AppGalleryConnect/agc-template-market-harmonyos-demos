import { PersistenceV2 } from '@kit.ArkUI';
import { ModifyPersonalInfoRequest, UserInfoModel, UserResponse, UserServiceApi } from 'module_base';

@ObservedV2
export class MineVM {
  @Trace content: string = '';
  @Trace pathStack: NavPathStack = new NavPathStack();
  @Trace userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  private static _instance: MineVM;

  public static get instance() {
    if (!MineVM._instance) {
      MineVM._instance = new MineVM();
    }
    return MineVM._instance;
  }

  async login(uid: string) {
    const user = await UserServiceApi.signIn('hw', uid);
    if (user) {
      this.userInfoModel.loginChannel = 'hw';
      this.handleUserInfo(user);
    }
  }

  handleUserInfo(user: UserResponse) {
    this.userInfoModel.isLogin = true;
    this.userInfoModel.userId = user.userId;
    this.userInfoModel.userIcon = user.userIcon;
    this.userInfoModel.userNickName = user.userNickName;
    this.userInfoModel.userPhone = user.userPhone;
  }

  updateUserInfo(request: ModifyPersonalInfoRequest) {
    UserServiceApi.modifyPersonalInfo(request);
  }

  signOut() {
    this.userInfoModel.isLogin = false;
    // 返回我的页面
    this.pathStack.pop();
  }
}