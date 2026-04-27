import type { Chain, Interceptor, ChainResponse } from './Interceptor';
import { Logger } from '../../logger/AppLogger';
import axios, {
  AxiosInstance,
  AxiosRequestHeaders
} from '@ohos/axios';
import { MockAdapter } from '../mock/MockAdapter';

const TAG = "HttpCallServerInterceptor"

export class HttpCallServerInterceptor implements Interceptor {
  private axiosInstance: AxiosInstance;

  constructor() {
    this.axiosInstance = axios.create();
  }

  //实际发送请求，不用调用chain.process();
  async intercept(chain: Chain): Promise<ChainResponse> {
    Logger.info(TAG, "HttpCallServerInterceptor intercept");
    let request = chain.request();
    let connectTimeout = request.connectTimeout ? request.connectTimeout : 60000;
    let readTimeout = request.readTimeout ? request.readTimeout : 60000;

    let result: ChainResponse;

    let response: any = await this.axiosInstance.request({
      url: request.url,
      method: request.method,
      headers: {
        ...{
          'Content-Type': 'application/json',
        }, ...request.headers
      } as AxiosRequestHeaders,
      params: request.queries,
      data: request.body,
      readTimeout: readTimeout,
      connectTimeout: connectTimeout,
      adapter: MockAdapter.adapter // todo 模板中mock数据使用，真实请求时需去除
    })

    result = {
      code: response.status,
      message: response.statusText,
      headers: response.headers,
      result: response.data
    }
    return Promise.resolve(result);
  }
}
