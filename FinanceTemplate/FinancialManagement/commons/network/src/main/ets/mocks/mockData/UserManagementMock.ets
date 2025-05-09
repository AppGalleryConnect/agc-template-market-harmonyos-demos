import { UpdateUserInfoRequest } from '../../types/AxiosRequestParam';
import { IUserInfo } from '../../types/responseTypes';
import { IUserAccount } from '../../types/responseTypes/GetUserAccountResp';
import { MockStorageMap } from '../Constants';
import { getFormattedResp } from '../Utils';

const userInfo: IUserInfo = {
  loginToken: 'xxx',
  id: 1,
  name: 'xx',
  nickname: '华为用户',
  sex: '1',
  cellphone: '10000000000',
  birthday: '1932-28-58',
  avatar: '',
}

const userAccount: IUserAccount = {
  id: 1,
  userId: 1,
  bankName: 'xx银行',
  bankCardNo: '6885482547156985632',
  bankAmount: 1000000.98,
  positionAmount: 10000,
  accumulatedEarnings: 265.23
}

export class UserManagementMock {
  public static login() {
    AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, userInfo);
    return getFormattedResp(userInfo)
  }

  public static logout() {
    const userInfoMockData = AppStorage.get<IUserInfo>(MockStorageMap.USER_INFO);
    if (userInfoMockData) {
      AppStorage.set(MockStorageMap.USER_INFO, {})
    }
    return getFormattedResp(undefined)
  }

  public static getUserInfo() {
    const userInfoMockData = AppStorage.get<IUserInfo>(MockStorageMap.USER_INFO);
    if (userInfoMockData) {
      return getFormattedResp(userInfoMockData)
    }
    AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, userInfo);
    return getFormattedResp(userInfo)
  }

  public static updateUserInfo(data: UpdateUserInfoRequest) {
    const userInfoMockData = AppStorage.get<IUserInfo>(MockStorageMap.USER_INFO);
    if (userInfoMockData) {
      userInfoMockData.name = data.name;
      userInfoMockData.nickname = data.nickname;
      userInfoMockData.sex = data.sex;
      userInfoMockData.cellphone = data.cellphone;
      userInfoMockData.birthday = data.birthday;
      userInfoMockData.avatar = data.avatar;
      AppStorage.set<IUserInfo>(MockStorageMap.USER_INFO, userInfoMockData);
    }
    return getFormattedResp(undefined)
  }

  public static getUserAccount() {
    const userAccountMockData = AppStorage.get<IUserAccount>(MockStorageMap.USER_ACCOUNT);
    if (userAccountMockData) {
      return getFormattedResp(userAccountMockData)
    }
    AppStorage.setOrCreate<IUserAccount>(MockStorageMap.USER_ACCOUNT, userAccount);
    return getFormattedResp(userAccount)
  }
}