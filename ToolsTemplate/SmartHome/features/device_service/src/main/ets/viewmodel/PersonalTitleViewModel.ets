import { PersonalInfoModel, PersonalInfoObserverIntf } from '../model/PersonalInfoModel';

@ObservedV2
export class PersonalTitleViewModel extends PersonalInfoObserverIntf {
  personalInfoModel = PersonalInfoModel.getInstance();
  @Trace nickName: string;

  constructor() {
    super();
    let personalInfo = this.personalInfoModel.getPersonalInfo();
    this.nickName = personalInfo.nickName;
    this.personalInfoModel.registerObserver(this);
  }

  OnNickNameChange(nickName: string): void {
    this.nickName = nickName;
  }
}