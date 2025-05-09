import { https, IUserInfo, UpdateUserInfoRequest } from 'network';
import { MockStorageMap } from 'network/src/main/ets/mocks/Constants';
import { promptAction } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';

const TAG = '[EditNamePageVM]';

@ObservedV2
export class EditNamePageVM {
  private static _instance: EditNamePageVM;
  @Trace public userInfo: IUserInfo | undefined
  @Trace public nickname: string = ''

  public static get instance() {
    if (!EditNamePageVM._instance) {
      EditNamePageVM._instance = new EditNamePageVM();
    }
    return EditNamePageVM._instance;
  }

  init() {
    const userInfo = AppStorage.get<IUserInfo>(MockStorageMap.USER_INFO)
    if (userInfo) {
      this.userInfo = userInfo
      this.nickname = userInfo.nickname
    }
  }

  clear() {
    this.userInfo = undefined
    this.nickname = ''
  }

  modify() {
    if (!this.userInfo) {
      return
    }
    if (!this.nickname) {
      promptAction.showToast({
        message: '昵称不能为空',
        duration: 2000,
        alignment: Alignment.Center
      });
      return
    }
    if (this.nickname.length > 8) {
      promptAction.showToast({
        message: '昵称不能超过8位',
        duration: 2000,
        alignment: Alignment.Center
      });
      return
    }
    const updateUserInfoRequest: UpdateUserInfoRequest =
      {
        id: this.userInfo.id,
        name: this.userInfo.name,
        nickname: this.nickname,
        sex: this.userInfo.sex,
        cellphone: this.userInfo.cellphone,
        birthday: this.userInfo.birthday,
        avatar: this.userInfo.avatar,
      }
    this.updateUserInfo(updateUserInfoRequest)
  }

  public async updateUserInfo(data: UpdateUserInfoRequest) {
    await https.updateUserInfo(data);
    promptAction.showToast({
      message: '修改成功',
      duration: 2000,
      alignment: Alignment.Center
    });
    let uerInfo: emitter.EventData = {
      data: {
        isLogin: true,
      },
    };
    emitter.emit('isLogin', uerInfo);
  }
}
