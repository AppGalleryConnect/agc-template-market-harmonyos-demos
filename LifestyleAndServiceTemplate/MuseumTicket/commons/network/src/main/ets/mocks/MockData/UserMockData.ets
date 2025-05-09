import { UserLoginResp, GetUserInfoResp } from '../../types/ResponseTypes';
import { getFormattedResp } from '../Utils';


export class UserDatasetMock {
  public static _userLoginInfo: UserLoginResp = {
    loginToken: 'xxx',
    id: 15126,
    name: '',
    nickname: '',
    sex: '1',
    cellphone: '',
    birthday: '',
    avatar: '',
  };
  private static _userInfo: GetUserInfoResp = {
    id: 15126,
    name: '',
    nickname: '',
    sex: '1',
    cellphone: '',
    birthday: '',
    avatar: '',
  };

  public static getUserInfo() {
    return getFormattedResp(UserDatasetMock._userInfo);
  }

  public static userLoginResp() {
    return getFormattedResp(UserDatasetMock._userLoginInfo);
  }


  public static bindPhone() {
    UserDatasetMock._userInfo.cellphone = '12011111119';
    UserDatasetMock._userInfo.nickname = '张伟';
    UserDatasetMock._userInfo.name = '张伟';
  }

  public static cancelPhone() {
    UserDatasetMock._userInfo.cellphone = '';
    UserDatasetMock._userInfo.nickname = '';
    UserDatasetMock._userInfo.name = '';
  }
}