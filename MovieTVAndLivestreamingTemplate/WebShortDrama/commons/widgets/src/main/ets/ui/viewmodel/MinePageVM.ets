import { AppStorageV2, promptAction, PersistenceV2, window } from '@kit.ArkUI';
import { AccountUtil, UserInfoModel } from '../../util/AccountUtil';


@ObservedV2
export class MinePageVM {
  windowStage: window.WindowStage = AppStorage.get('windowStage')!
  // 用户信息
  @Trace userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!;
  @Trace localInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'localInfo', () => new UserInfoModel())!;
  private static _instance: MinePageVM;

  public static get instance() {
    if (!MinePageVM._instance) {
      MinePageVM._instance = AppStorageV2.connect(MinePageVM, '_instance', () => new MinePageVM())!;
    }
    return MinePageVM._instance;
  }


  /** 头像更新 **/
  public async updateAvatar(url: string) {
    await this._uploadAvatar(url);
    AccountUtil.updateUserInfo({ avatar: url });
    this.userInfo.avatar = url
    this.localInfo.avatar = url
  }

  /**
   * 头像上传
   * 详细内容查阅API:request.agent.create
   */
  private async _uploadAvatar(url: string) {
    // 元服务头像上传
  }

  /** 保存修改后的名称 **/
  public saveEdit(newName: string): boolean {
    if (this._isLegal(newName)) {
      AccountUtil.updateUserInfo({ nickname: newName });
      return true
    }
    return false
  }

  /** 判断是否合法 **/
  private _isLegal(name: string) {
    if (!name) {
      this.windowStage.getMainWindowSync().getUIContext().getPromptAction().showToast({
        message: '昵称不能为空,长度限制为8位',
      });
      return false;
    }
    if (!(/^[a-zA-Z0-9\u4e00-\u9fa5]+$/).test(name)) {
      this.windowStage.getMainWindowSync().getUIContext().getPromptAction().showToast({
        message: '昵称只能包含字母、数字、中文',
      });
      return false;
    }
    return true;
  }
}
