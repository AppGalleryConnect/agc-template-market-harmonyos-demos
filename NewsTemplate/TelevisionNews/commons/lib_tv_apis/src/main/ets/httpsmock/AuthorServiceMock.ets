import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { BaseAuthor } from '../database/AuthorType';
import { UserRequest } from '../params/request/CommonRequest';
import { AuthorResponse } from '../params/response/AuthorResponse';
import { MockUser } from './mockdata/MockUser';

/**
 * 用户管理Mock
 */
export class AuthorServiceMock {
  public start(adapter: AxiosMockAdapter) {
    // 查询作者信息
    adapter.onGet('/author/info').reply((config: AxiosRequestConfig) => {
      const params = config.params as UserRequest;
      const result = this.queryAuthorInfo(params.userId);
      return [HttpStatusCode.Ok, result];
    });
  }

  /**
   * 查询作者信息
   * @param userId
   * @returns
   */
  public queryAuthorInfo(userId?: string): AuthorResponse | undefined {
    const raw = this.queryAuthorRaw(userId);
    if (raw) {
      return this.handleRawInfo(raw);
    }
    return undefined;
  }

  /**
   * 查询用户信息数据库字段
   * @param userId
   * @returns
   */
  public queryAuthorRaw(userId?: string): BaseAuthor | undefined {
    if (userId) {
      return [MockUser.myself].find(v => v.authorId === userId)!;
    }
    // 获取本人信息
    return MockUser.myself;
  }

  /**
   * 数据库字段转换成云侧模型
   * @param author
   * @returns
   */
  private handleRawInfo(author: BaseAuthor): AuthorResponse {
    const copyItem = JSON.parse(JSON.stringify(author)) as AuthorResponse;
    return copyItem;
  }
}