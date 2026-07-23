import request from './AxiosBase';
import { URL_MAP } from '../constants/CommonEnums';
import { IPhoneRequest } from '../constants/CommonModel';
import { User } from '../models/User';

export class HttpApi {
  /**
   * 用户登录
   */
  public static userLogin(phone: string): Promise<User> {
    const url = URL_MAP.USER_LOGIN;
    return request.post(url, { phone } as IPhoneRequest);
  }

  /**
   * 用户登出
   */
  public static userLogout(phone: string): Promise<boolean> {
    const url = URL_MAP.USER_LOGOUT;
    return request.post(url, { phone } as IPhoneRequest);
  }

  /**
   * 读取用户信息
   */
  public static queryUserInfo(phone: string): Promise<User> {
    const url = URL_MAP.GET_USER_INFO;
    return request.get(url, { params: { phone } });
  };

  /**
   * 更新用户信息
   */
  public static updateUserInfo(data: User): Promise<boolean> {
    const url = URL_MAP.UPDATE_USER_INFO;
    return request.put(url, data);
  };
}