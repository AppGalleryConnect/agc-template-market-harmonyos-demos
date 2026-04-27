import { BaseApi, RequestMethod } from 'common';
import { UserModel } from '../model/UserModel';

export class UserApi extends BaseApi {
  constructor() {
    super({
      isMock: true
    });
  }

  public loginHospitalUser(authorizationCode?: string) {
    return this.sendRequest<UserModel>('/user/login', RequestMethod.GET, {
      loginToken: authorizationCode
    } as UserModel, true);
  }

  public uploadUserInfo(userInfo: UserModel) {
    return this.sendRequest<object>('/user/upload', RequestMethod.POST, userInfo);
  }
}