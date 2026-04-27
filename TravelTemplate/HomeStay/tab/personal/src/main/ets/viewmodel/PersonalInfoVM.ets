import { promptAction } from '@kit.ArkUI';
import { https } from 'network';
import { PersonalInfo } from 'type';
import { isValidPhoneNo } from 'util';

@ObservedV2
export class PersonalInfoVM {
  @Trace userInfo: PersonalInfo = new PersonalInfo();
  @Trace pathStack: NavPathStack = new NavPathStack();
  private static _instance: PersonalInfoVM;

  async updatePersonInfo() {
    let editInfoPromise = https.editUserInfo(this.userInfo);

    return editInfoPromise;
  }

  async saveUserInfo(uiContext: UIContext) {
    if (!isValidPhoneNo(this.userInfo.phone) && this.userInfo.nickName.length === 0) {
      uiContext.getPromptAction().showToast({ message: '请输入正确的手机号码或昵称', duration: 2000 });
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
