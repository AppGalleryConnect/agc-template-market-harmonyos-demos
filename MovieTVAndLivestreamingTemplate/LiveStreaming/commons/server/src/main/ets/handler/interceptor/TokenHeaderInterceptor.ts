import { LoginAPI } from '@agctemplate/common';
import { Chain, ChainResponse, container, Interceptor, Logger, TSExtension } from '@agctemplate/utils';

const TAG = "TokenHeaderInterceptor"

export class TokenHeaderInterceptor implements Interceptor {
  async intercept(chain: Chain): Promise<ChainResponse> {
    Logger.info(TAG, "TokenHeaderInterceptor intercept");
    let request = chain.request();
    if (!request.headers) {
      request.headers = new Object();
    }
    TSExtension.addProperty(request.headers, "AccessToken", container.resolve(LoginAPI).getAccessToken());

    return chain.proceed(request);
  }
}