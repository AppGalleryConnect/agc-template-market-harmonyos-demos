import {
  GetProductExpireTimeRequest,
  ModifyPersonalInfoRequest, SendCodeRequest, SignInRequest, VerifyCodeRequest } from '../../model/HttpRequest';
import { UserResponse } from '../../model/HttpResponse';
import request from '../Request';
// 启动mock
import('../../httpsmock/MockAdapter');

export class UserService {
  /**
   * 登录
   * @param loginChannel
   * @param nickPhone
   * @returns
   */
  public signIn(loginChannel?: string, uid?: string): Promise<UserResponse | undefined> {
    const data: SignInRequest = {
      loginChannel,
      uid,
    };
    return request.post('/sign/in', data);
  }

  /**
   * 修改个人信息
   * @param params
   * @returns
   */
  public modifyPersonalInfo(params: ModifyPersonalInfoRequest): Promise<void> {
    return request.post('/modify/personal/info', params);
  }

  /**
   * 获取短信验证码
   * @param phone
   * @returns
   */
  public sendCode(phone: string): Promise<void> {
    const data: SendCodeRequest = {
      phone,
    };
    return request.post('/send/code', data);
  }

  /**
   * 验证短信验证码
   * @param phone
   * @param code
   * @returns
   */
  public verifyCode(phone: string, code: string): Promise<void> {
    const data: VerifyCodeRequest = {
      phone,
      code,
    };
    return request.post('/verify/code', data);
  }

  /**
   * 获取非续期商品或者非消耗型的到期时间
   * @param productId
   * @param time
   * @returns
   */
  public getProductExpireTime(productId: string, time?: number): Promise<string> {
    const data: GetProductExpireTimeRequest = {
      productId,
      time,
    };
    return request.post('/product/time', data);
  }
}

const instance = new UserService();

export { instance as UserServiceApi };