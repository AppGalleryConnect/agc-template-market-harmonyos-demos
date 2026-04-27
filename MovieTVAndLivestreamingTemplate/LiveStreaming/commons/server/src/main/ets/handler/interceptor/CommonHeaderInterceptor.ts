import { AppInfo } from '@agctemplate/common';
import { Chain, Interceptor, ChainResponse, container, Logger, TSExtension } from '@agctemplate/utils';

const TAG = "CommonHeaderInterceptor"

export class CommonHeaderInterceptor implements Interceptor {
  async intercept(chain: Chain): Promise<ChainResponse> {
    Logger.info(TAG, "CommonHeaderInterceptor intercept");
    let request = chain.request();
    if (!request.headers) {
      request.headers = new Object();
    }
    TSExtension.addProperty(request.headers, "App-Version", container.resolve(AppInfo).versionCode);
    TSExtension.addProperty(request.headers, "App-Id", container.resolve(AppInfo).clientId);
    return chain.proceed(request);
  }
}
