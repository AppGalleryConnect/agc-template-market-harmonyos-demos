import { BaseViewModel } from 'module_base';

const TAG = '[PersonalInformationVM]';

@ObservedV2
export class PersonalInformationVM extends BaseViewModel {
  private static _instance: PersonalInformationVM;
  @Trace avatar: string = ''

  modify() {
    if (!this.userInfoModel) {
      return
    }
    this.userInfoModel.avatar = this.avatar
  }

  public static get instance() {
    if (!PersonalInformationVM._instance) {
      PersonalInformationVM._instance = new PersonalInformationVM();
    }
    return PersonalInformationVM._instance;
  }
}
