import { http } from '@kit.NetworkKit';
import Logger from './Logger';

export class HttpUtil {
  httpRequest: http.HttpRequest;

  constructor() {
    this.httpRequest = http.createHttp();

  }

  async doRequest(url: string, reqMethod: http.RequestMethod, reqData: string | null): Promise<string> {
    let result: string = '';
    await this.httpRequest.request(url,
      {
        method: reqMethod,
        extraData: reqData,
        header: {
          'Content-Type': 'application/json'
        }
      }).then((data: http.HttpResponse) => {
      Logger.info('http response code=' + data.responseCode + ', responseHeader=' + JSON.stringify(data.header))
      result = data.result as string;
    }).catch((err: Error) => {
      Logger.error('doHttpRequest failed, url=' + url + ', error=' + JSON.stringify(err));
    });
    return result;
  }

  /**
   * The method of destroying httpRequest.
   */
  destroyHttpRequest() {
    this.httpRequest.destroy();
  }
}