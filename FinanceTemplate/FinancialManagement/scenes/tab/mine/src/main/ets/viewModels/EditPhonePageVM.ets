import { https, IUserInfo, UpdateUserInfoRequest } from 'network';
import { MockStorageMap } from 'network/src/main/ets/mocks/Constants';
import { promptAction } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';

const TAG = '[EditPhonePageVM]';

@ObservedV2
export class EditPhonePageVM {
  private static _instance: EditPhonePageVM;
  @Trace public userInfo: IUserInfo | undefined
  @Trace public cellphone: string = ''

  public static get instance() {
    if (!EditPhonePageVM._instance) {
      EditPhonePageVM._instance = new EditPhonePageVM();
    }
    return EditPhonePageVM._instance;
  }

  init() {
    const userInfo = AppStorage.get<IUserInfo>(MockStorageMap.USER_INFO)
    if (userInfo) {
      this.userInfo = userInfo
      this.cellphone = userInfo.cellphone
    }
  }

  clear() {
    this.userInfo = undefined
    this.cellphone = ''
  }

  modify() {
    if (!this.userInfo) {
      return
    }
    if (!this.cellphone) {
      promptAction.showToast({
        message: '手机号不能为空',
        duration: 2000,
        alignment: Alignment.Center
      });
      return
    }

    if (this.cellphone.length !== 11) {
      promptAction.showToast({
        message: '手机号不是11位',
        duration: 2000,
        alignment: Alignment.Center
      });
      return
    }

    const updateUserInfoRequest: UpdateUserInfoRequest =
      {
        id: this.userInfo.id,
        name: this.userInfo.name,
        nickname: this.userInfo.nickname,
        sex: this.userInfo.sex,
        cellphone: this.cellphone,
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
