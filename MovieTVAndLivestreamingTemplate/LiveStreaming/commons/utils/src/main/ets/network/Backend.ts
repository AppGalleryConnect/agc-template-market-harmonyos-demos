import { LoggerInterceptor } from './interceptor/LoggerInterceptor';
import { BaseRequest } from './BaseRequest';
import { BaseResponse } from './BaseResponse';
import type { HttpOptions } from './HttpOptions';

import { ChainRequest, Interceptor } from './interceptor/Interceptor';
import { HttpCallServerInterceptor } from './interceptor/CallServerInterceptor';
import { RealInterceptorChain } from './interceptor/RealInterceptorChain';
import { JsonResponseInterceptor } from './interceptor/JsonResponseInterceptor';
import { AppError } from './error/AppError';

export class Backend {
  async sendRequest(
    baseRequest: BaseRequest,
    interceptors?: Interceptor[],
    options?: HttpOptions,
  ): Promise<BaseResponse<any>> {
    let list: Interceptor[] = [];
    if (interceptors != null) {
      interceptors.forEach((interceptor: Interceptor) => {
        list.push(interceptor);
      })
    }
    //注意处理顺序，request从上到下，response从下到上
    list.push(new JsonResponseInterceptor());
    list.push(new LoggerInterceptor());
    list.push(new HttpCallServerInterceptor());

    let request_: ChainRequest = {
      url: baseRequest.host + baseRequest.path,
      method: baseRequest.method,
      headers: baseRequest.headers,
      body: baseRequest.body,
      readTimeout: options?.readTimeout,
      connectTimeout: options?.connectTimeout
    };

    try {
      let realInterceptorChain = new RealInterceptorChain(list, 0, request_);
      let httpResponse = await realInterceptorChain.proceed(request_);
      //已在上面增加`JsonResponseInterceptor`处理成Object类型
      let response = new BaseResponse(httpResponse.result, httpResponse.headers);
      if (!response.isSuccess()) {
        return Promise.reject(new AppError(response.getMessage(), response.getRetCode()));
      }
      return Promise.resolve(response);
    } catch (error) {
      return Promise.reject(error);
    }
  }
}
