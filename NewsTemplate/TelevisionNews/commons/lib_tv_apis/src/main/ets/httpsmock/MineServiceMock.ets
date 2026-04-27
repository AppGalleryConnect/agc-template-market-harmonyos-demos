import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { BaseAuthor } from '../database/AuthorType';
import {
  SubscribeRequest, UserRequest,
} from '../params/request/CommonRequest';
import { BaseNewsServiceMock } from './BaseNewsServiceMock';
import { AuthorServiceMock } from './AuthorServiceMock';
import { AvResponse } from '../params/response/AvResponse';

/**
 * 我的Mock
 */
export class MineServiceMock {
  private authorMock: AuthorServiceMock = new AuthorServiceMock();
  private baseNewsMock: BaseNewsServiceMock = new BaseNewsServiceMock();

  public start(adapter: AxiosMockAdapter) {
    // 订阅公众号
    adapter.onPost('/subscribe/add').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as SubscribeRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as BaseAuthor;
      mineUserInfo.subscribe.splice(0, 0, data.subscribeId);
      return [HttpStatusCode.Ok];
    });

    // 取消订阅
    adapter.onPost('/subscribe/cancel').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as SubscribeRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as BaseAuthor;
      const index = mineUserInfo.subscribe.findIndex(id => id === data.subscribeId);
      if (index !== -1) {
        mineUserInfo?.subscribe.splice(index, 1);
      }
      return [HttpStatusCode.Ok];
    });

    // 取消全部订阅
    adapter.onPost('/subscribe/cancel/all').reply((config: AxiosRequestConfig) => {
      const mineUserInfo = this.authorMock.queryAuthorRaw() as BaseAuthor;
      if (mineUserInfo) {
        mineUserInfo.subscribe = []
      }
      return [HttpStatusCode.Ok];
    });

    // 查询我的订阅
    adapter.onGet('/my/subscribe/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as UserRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw(params.userId) as BaseAuthor;
      const list = mineUserInfo.subscribe
        .map((id: string) => {
          return this.baseNewsMock.queryRawAv(id);
        })
        .filter(v => Boolean(v)) as AvResponse[];
      return [HttpStatusCode.Ok, list];
    });
  }

}