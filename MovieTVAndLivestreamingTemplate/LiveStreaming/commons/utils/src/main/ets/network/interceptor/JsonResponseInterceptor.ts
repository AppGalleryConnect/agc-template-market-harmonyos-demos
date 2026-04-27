import type { Chain, Interceptor, ChainResponse } from './Interceptor';
import { Logger } from '../../logger/AppLogger';
import { TSExtension } from '../../utils/TSExtension';

const TAG = "JsonResponseInterceptor"
export class JsonResponseInterceptor implements Interceptor {

  constructor() {
  }

  async intercept(chain: Chain): Promise<ChainResponse> {
    Logger.info(TAG, "JsonResponseInterceptor intercept");
    let request = chain.request();
    if (!request.headers) {
      request.headers = new Object();
    }
    TSExtension.addProperty(request.headers, "Accept", "application/json");
    TSExtension.addProperty(request.headers, "Content-Type", "application/json;charset=UTF-8");
    let response = await chain.proceed(request);
    if (typeof response.result === 'string') {
      try {
        response.result = JSON.parse(response.result as string);
      }catch (e) {
        return Promise.reject(e);
      }
    } else if (response.result instanceof ArrayBuffer) {
      return Promise.reject("not support http type");
    }
    return response;
  }
}