export interface UserInfo {
  id?: string;
  isPhoneAssociated?: boolean;
  avatar?: string;
  nickname?: string;
  cellphone?: string;
  isMock?: boolean;
}

@ObservedV2
export class UserInfoModel implements UserInfo {
  @Trace id: string = '';
  @Trace isPhoneAssociated: boolean = false;
  @Trace isMock: boolean = false;
  @Trace avatar: string = '';
  @Trace nickname: string = '';
  @Trace cellphone: string = '';
}

@ObservedV2
export class AccountModel {
  @Trace idToken: string = '';
  @Trace openID: string = '';
  @Trace unionID: string = '';
  @Trace authCode: string = '';
  @Trace loginToken: string = '';
}