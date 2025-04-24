import { MockStorageMap } from '../Constants';
import { GetHotelUserInfoResp, HotelUserLoginResp } from '../../types/responseTypes';
import { UpdateUserInfoRequest } from '../../types/AxiosRequestParam';
import { getFormattedResp } from '../Utils';

const userInfoMock: HotelUserLoginResp = {
  loginToken: 'xxx',
  id: 15126,
  name: '',
  nickname: '',
  sex: '1',
  cellphone: '',
  birthday: '',
  avatar: '',
  memberMsg: {
    memberCardNo: 'C00015126',
    memberClassTName: '大众会员',
    memberClassTLevel: '1',
    pointBalance: '1980',
  },
};


export class UserManagementMock {
  public static hotelUserLogin() {
    return getFormattedResp(userInfoMock);
  }

  public static getHotelUserInfo() {
    let userInfoMock = AppStorage.get<GetHotelUserInfoResp>(MockStorageMap.USER_INFO);
    if (!userInfoMock) {
      AppStorage.setOrCreate<GetHotelUserInfoResp>(MockStorageMap.USER_INFO, userInfoMock);
      userInfoMock = JSON.parse(JSON.stringify(userInfoMock)) as GetHotelUserInfoResp
    }
     return getFormattedResp(userInfoMock);
  }

  public static updateHotelUserInfo(data: UpdateUserInfoRequest) {
    const userInfoMock = AppStorage.get<GetHotelUserInfoResp>(MockStorageMap.USER_INFO);
    if (userInfoMock) {
      userInfoMock.name = data.name;
      userInfoMock.nickname = data.nickname;
      userInfoMock.sex = data.sex;
      userInfoMock.cellphone = data.cellphone;
      userInfoMock.birthday = data.birthday;
      userInfoMock.avatar = data.avatar;
      AppStorage.set<GetHotelUserInfoResp>(MockStorageMap.USER_INFO, userInfoMock);
    }
    return getFormattedResp(undefined)

  }
}