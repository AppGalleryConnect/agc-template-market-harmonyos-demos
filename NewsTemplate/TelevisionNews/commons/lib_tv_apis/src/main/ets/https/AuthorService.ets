import request from '../common/BaseRequest';
import {
  SignInRequest,
} from '../params/request/CommonRequest';
import { AuthorResponse } from '../params/response/AuthorResponse';

/**
 * 用户管理类
 */
export class AuthorService {
  /**
   * 查询作者信息
   * @param userId
   * @param loginChannel
   * @returns
   */
  public queryAuthorInfo(userId?: string): Promise<AuthorResponse | undefined> {
    return request.get('/author/info', { params: { userId } });
  }

  /**
   * 登录
   * @param loginChannel
   * @param nickPhone
   * @returns
   */
  public signIn(loginChannel?: string, nickPhone?: string): Promise<AuthorResponse | undefined> {
    const data: SignInRequest = {
      loginChannel,
      nickPhone,
    };
    return request.post('/sign/in', data);
  }
}

const instance = new AuthorService();

export { instance as AuthorServiceApi }