import { PersonalInfoModel, PersonalInfoObserverIntf } from '../model/PersonalInfoModel';

@ObservedV2
export class PersonalCenterViewModel extends PersonalInfoObserverIntf {
  personalInfoModel = PersonalInfoModel.getInstance();
  @Trace avatar: ResourceStr;
  @Trace nickName: string;
  @Trace phone: string;

  constructor() {
    super();
    let personalInfo = this.personalInfoModel.getPersonalInfo();
    this.avatar = personalInfo.avatar;
    this.nickName = personalInfo.nickName;
    this.phone = personalInfo.phone;

    this.personalInfoModel.registerObserver(this);
  }

  setNickName(nickName: string) {
    this.personalInfoModel.setNickName(nickName);
  }

  setAvatar(avatar: ResourceStr) {
    this.personalInfoModel.setAvatar(avatar);
  }

  OnNickNameChange(nickName: string): void {
    this.nickName = nickName;
  }

  OnAvatarChange(avatar: ResourceStr): void {
    this.avatar = avatar;
  }
}