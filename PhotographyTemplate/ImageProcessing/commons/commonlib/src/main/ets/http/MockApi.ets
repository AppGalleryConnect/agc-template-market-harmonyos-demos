import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { URL_MAP } from '../constants/CommonEnums';
import { IPhoneRequest } from '../constants/CommonModel';
import { UserDB } from '../database/UserDB';
import { User } from '../models/User';

export class MockApi {
  public start(adapter: AxiosMockAdapter) {
    // 用户登录
    adapter.onPost(URL_MAP.USER_LOGIN).reply(async (config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as IPhoneRequest;
      const userInfo = await UserDB.userLogin(data.phone);
      return [HttpStatusCode.Ok, userInfo];
    });

    // 用户登出
    adapter.onPost(URL_MAP.USER_LOGOUT).reply(async (config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as IPhoneRequest;
      const loginStatus = await UserDB.userLogout(data.phone);
      return [HttpStatusCode.Ok, loginStatus];
    });

    // 更新用户信息
    adapter.onPut(URL_MAP.UPDATE_USER_INFO).reply(async (config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as User;
      const resp = await UserDB.updateUser(data);
      return [HttpStatusCode.Ok, resp];
    });
  }
}