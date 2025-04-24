import { AccountUtil, MemberInfoModel, RouterMap, RouterModule, UserInfo, UserInfoModel } from 'commonlib';
import { Gender, EditDialogType } from '../constants';
import { promptAction } from '@kit.ArkUI';
import { UpdateUserInfoRequest, BaseResponse, https } from 'network';


@ObservedV2
export class ProfileEditPageVM {
  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();
  @Trace gender: Gender = Gender.MALE;
  @Trace newUserInfo: UserInfoModel = new UserInfoModel();
  @Trace editType: EditDialogType = EditDialogType.NICKNAME;
  private static _instance: ProfileEditPageVM;

  public static get instance() {
    if (!ProfileEditPageVM._instance) {
      ProfileEditPageVM._instance = new ProfileEditPageVM();
    }
    return ProfileEditPageVM._instance;
  }

  public getEditStr() {
    if (this.editType === EditDialogType.NICKNAME) {
      return this.newUserInfo.nickname ?? '';
    } else if (this.editType === EditDialogType.NAME) {
      return this.newUserInfo.name ?? '';
    } else {
      return this.newUserInfo.cellphone ?? '';
    }
  }

  public cloneUserInfo() {
    this.newUserInfo.avatar = this.userInfo.avatar;
    this.newUserInfo.name = this.userInfo.name;
    this.newUserInfo.nickname = this.userInfo.nickname;
    this.newUserInfo.sex = this.userInfo.sex;
    this.newUserInfo.cellphone = this.userInfo.cellphone;
    this.newUserInfo.birthday = this.userInfo.birthday;
    this.newUserInfo.avatar = this.userInfo.avatar;
    this.newUserInfo.memberInfo = new MemberInfoModel(this.userInfo.memberInfo);
  }

  public isNewUserInfoValid(): boolean {
    if (!this.newUserInfo.name) {
      promptAction.showToast({ message: '请填写用户姓名！' });
      return false;
    }
    if (!this.newUserInfo.cellphone) {
      promptAction.showToast({ message: '请填写手机号！' });
      return false;
    }
    const reg = /^[1][3,4,5,6,7,8,9][0-9]{9}$/;
    if (!reg.test(this.newUserInfo.cellphone)) {
      promptAction.showToast({ message: '手机号格式不正确！' });
      return false;
    }
    return true;
  }

  public async updateUserInfo() {
    if (!this.isNewUserInfoValid()) {
      return;
    }
    const profileInfo: UpdateUserInfoRequest = {
      id: this.userInfo.id,
      name: this.newUserInfo.name ?? '',
      nickname: this.newUserInfo.nickname ?? '',
      sex: this.gender,
      cellphone: this.newUserInfo.cellphone ?? '',
      birthday: this.newUserInfo.birthday ?? '',
      avatar: this.newUserInfo.avatar ?? '',
    };
    const res: BaseResponse = await https.updateHotelUserInfo(profileInfo);
    if (res.code === 0) {
      promptAction.showToast({ message: '修改成功!' });
      this.newUserInfo.sex = this.gender;
      AccountUtil.updateUserInfo(this.newUserInfo);
      const timer = setTimeout(() => {
        RouterModule.pop();
        clearTimeout(timer);
      }, 1000);
    }
  }
}
