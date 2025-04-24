import { PersonalInfoModel, PersonalInfoObserverIntf } from '../model/PersonalInfoModel';

@ObservedV2
export class PersonalProfileViewModel extends PersonalInfoObserverIntf {
  personalInfoModel = PersonalInfoModel.getInstance();
  @Trace avatar: ResourceStr;
  @Trace nickName: string;

  constructor() {
    super();
    let personalInfo = this.personalInfoModel.getPersonalInfo();
    this.avatar = personalInfo.avatar;
    this.nickName = personalInfo.nickName;
    this.personalInfoModel.registerObserver(this);
  }

  OnNickNameChange(nickName: string): void {
    this.nickName = nickName;
  }

  OnAvatarChange(avatar: ResourceStr): void {
    this.avatar = avatar;
  }
}