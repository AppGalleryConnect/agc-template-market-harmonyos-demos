import { Backend, BaseRequest, BaseResponse, Interceptor } from '@agctemplate/utils';

import { TokenRefreshInterceptor } from './interceptor/TokenRefreshInterceptor';
import { TokenHeaderInterceptor } from './interceptor/TokenHeaderInterceptor';
import { CommonHeaderInterceptor } from './interceptor/CommonHeaderInterceptor';

export class HttpHandler {
  private static backend: Backend;

  public static async sendRequest(request: BaseRequest,
    isAuth: boolean = false): Promise<BaseResponse<any>> {
    if (!HttpHandler.backend) {
      HttpHandler.backend = new Backend();
    }
    let interceptors: Interceptor[] = [];
    if (isAuth) {
      interceptors.push(new TokenRefreshInterceptor());
      interceptors.push(new TokenHeaderInterceptor());
    }
    interceptors.push(new CommonHeaderInterceptor());
    let response = await HttpHandler.backend.sendRequest(request, interceptors);
    return response;
  }
}