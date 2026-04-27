import { container, Logger, Chain, ChainResponse, Interceptor, RealInterceptorChain } from '@agctemplate/utils';
import { LoginAPI } from '@agctemplate/common';

const ACCESS_TOKEN_TIMEOUT = 6;
const TAG = "TokenRefreshInterceptor"

export class TokenRefreshInterceptor implements Interceptor {
  async intercept(chain: Chain): Promise<ChainResponse> {
    Logger.info(TAG, "TokenRefreshInterceptor intercept");
    let request = chain.request();
    let response = await chain.proceed(request);
    let resJson;
    try {
      resJson = JSON.parse((response.result as any)?.resJson);
    } catch (e) {
      Logger.warn(TAG, "TokenRefreshInterceptor resJson parse failed");
    }
    if (resJson?.code === ACCESS_TOKEN_TIMEOUT && !request.tokenRefreshed) {
      if (await container.resolve(LoginAPI).refreshToken(true) && chain instanceof RealInterceptorChain) {
        Logger.debug(TAG, "restart all Interceptors");
        // 一个接口仅支持刷新一次token，防止无限制刷新
        request.tokenRefreshed = true;
        // 将调用链强制回到起始处，重新调用接口
        (chain as RealInterceptorChain).index = 0;
        return await chain.proceed(request);
      }
    }
    return response;
  }
}