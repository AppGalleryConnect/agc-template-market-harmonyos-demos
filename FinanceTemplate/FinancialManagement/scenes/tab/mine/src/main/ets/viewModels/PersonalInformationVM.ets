import { https, IUserInfo, UpdateUserInfoRequest } from 'network';
import { RouterModule } from 'commonlib';
import { emitter } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

const TAG = '[PersonalInformationVM]';

@ObservedV2
export class PersonalInformationVM {
  private static _instance: PersonalInformationVM;
  @Trace public userInfo: IUserInfo | undefined
  @Trace public avatar: string = ''
  @Trace public nickname: string = ''
  @Trace public cellphone: string = ''

  public static get instance() {
    if (!PersonalInformationVM._instance) {
      PersonalInformationVM._instance = new PersonalInformationVM();
    }
    return PersonalInformationVM._instance;
  }

  init() {
    this.getUserInfo()
  }

  public async getUserInfo() {
    const res = await https.getUserInfo();
    if (res.code === 0) {
      this.userInfo = res.data;
      this.avatar = this.userInfo.avatar
      this.nickname = this.userInfo.nickname
      this.cellphone = this.userInfo.cellphone
    }
  }

  public async logout() {
    await https.userLogout();
    AppStorage.set<boolean>('isLogin', false)
    let data: emitter.EventData = {
      data: {
        isLogin: false,
      }
    };
    emitter.emit('isLogin', data);
    RouterModule.pop()
  }

  modify() {
    if (!this.userInfo) {
      return
    }
    if (!this.userInfo.cellphone) {
      promptAction.showToast({
        message: '手机号不能为空',
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
        cellphone: this.userInfo.cellphone,
        birthday: this.userInfo.birthday,
        avatar: this.avatar,
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
