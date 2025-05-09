import { AccountUtil } from 'account';
import { https } from 'network';
import { PersonalInfo } from 'type';
import { promptAction } from '@kit.ArkUI';
import { isValidPhoneNo } from 'util';

@ObservedV2
export class PersonalInfoVM {
  @Trace openId: string | undefined = AccountUtil.getOpenId();
  @Trace userInfo: PersonalInfo = new PersonalInfo();
  private static _instance: PersonalInfoVM;

  async updatePersonInfo() {
    const data = new PersonalInfo(this.userInfo.id, this.openId, this.userInfo.nickName, this.userInfo.gender,
      this.getFormatDate(this.userInfo.birthday), this.userInfo.phone, this.userInfo.avatar, '');

    let editInfoPromise = https.editUserInfo(data);

    return editInfoPromise;
  }

  async saveUserInfo() {
    if (!isValidPhoneNo(this.userInfo.phone) || this.userInfo.nickName.length === 0) {
      promptAction.showToast({ message: '请输入正确的手机号码或昵称', duration: 2000 });
      return undefined;
    }

    let res = this.updatePersonInfo();
    return res;
  }

  public static get instance() {
    if (!PersonalInfoVM._instance) {
      PersonalInfoVM._instance = new PersonalInfoVM();
    }
    return PersonalInfoVM._instance;
  }

  getFormatDate(birthday: string) {
    let birthdayInfo = birthday.split('-');
    let month = Number(birthdayInfo[1]) < 10 ? birthdayInfo[1].toString().padStart(2, '0') : birthdayInfo[1];
    let day = Number(birthdayInfo[2]) < 10 ? birthdayInfo[2].toString().padStart(2, '0') : birthdayInfo[2];
    return `${birthdayInfo[0]}-${month}-${day}`;
  }
}
