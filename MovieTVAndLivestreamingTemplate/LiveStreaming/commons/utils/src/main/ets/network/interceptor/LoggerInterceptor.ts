import type { Chain, Interceptor, ChainResponse } from './Interceptor';
import { Logger } from '../../logger/AppLogger';
import { SafeJson } from '../../json/SafeJson';

const TAG = "LoggerInterceptor";
export class LoggerInterceptor implements Interceptor {
  constructor() {
  }

  async intercept(chain: Chain): Promise<ChainResponse> {
    Logger.info(TAG, "LoggerInterceptor intercept");
    let request = chain.request();
    let msg = `${request.method},interface:${maskUrl(request.url)}`;
    Logger.info(TAG, `====>${msg}`);
    Logger.debug(TAG, `--->request url: ${request.url}`);
    Logger.debug(TAG, `--->request headers: ${SafeJson.ohAegJsonStringify(request.headers)}`);
    Logger.debug(TAG, `--->request body: ${SafeJson.ohAegJsonStringify(request.body)}`);
    let time = new Date().getTime();
    let response = await chain.proceed(request);
    Logger.debug(TAG, '<---response: ' + SafeJson.ohAegJsonStringify(response));
    Logger.info(TAG, `<====${msg} responseCode:${response.code}, responseMsg:${
    response.message
    }, costTime:${new Date().getTime() - time}`
    );
    return response;
  }
}

function maskUrl(url: string): string {
  if (url) {
    let strArray: string[] = url.split('.');
    if (strArray && strArray.length > 0) {
      let re = /\//g;
      let result = strArray[strArray.length -1].replace(re, '');
      return result;
    }
  }
  return '';
}
