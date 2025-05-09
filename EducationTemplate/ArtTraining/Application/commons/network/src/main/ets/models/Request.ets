import { cloudFunction } from '@kit.CloudFoundationKit';
import { Logger } from 'commonlib';
import { BaseResponse } from '../types/ResponseTypes';

const MAX_RETRIES = 3;
const TAG = '[CloudRequest]';

interface RejectError {
  code: number;
  message: string;
}

class CloudRequest {
  private async _performRequest(funcName: string, data?: Object, times?: number): Promise<Object> {
    return new Promise((resolve: (value: Object | PromiseLike<Object>) => void) => {
      Logger.info(TAG, 'Request call :' + funcName);
      Logger.info(TAG, 'Request params :' + JSON.stringify(data));
      cloudFunction.call({
        name: funcName,
        version: '$latest',
        timeout: 5000,
        data,
      })
        .then((functionResult: cloudFunction.FunctionResult) => {
          Logger.info(TAG, 'Request call success--------' + funcName + ':' + JSON.stringify(functionResult));
          resolve(functionResult.result);
        })
        .catch((error: RejectError) => {
          if (times && times > 0) {
            Logger.error(TAG, 'retry times--------' + (MAX_RETRIES - times + 1));
            resolve(cloudRequest._performRequest(funcName, data, times - 1));
          } else {
            Logger.error(TAG, `${funcName}   reject error--------` + JSON.stringify(error));
            const result: BaseResponse = {
              ret: { code: -1, msg: JSON.stringify(error) },
            };
            resolve(result);
          }
        });
    });
  }

  public async call(funcName: string, params?: Object): Promise<Object> {
    return await this._performRequest(funcName, params, MAX_RETRIES);
  }
}

const cloudRequest = new CloudRequest();

export { cloudRequest };