import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { EXCHANGE_INFO } from '../Exchange';

export class ExchangeServiceMock {
  public start(adapter: AxiosMockAdapter) {
    // 查询汇率列表
    adapter.onGet('/exchange/list').reply((config: AxiosRequestConfig) => {
      return [HttpStatusCode.Ok, EXCHANGE_INFO];
    });
  }
}