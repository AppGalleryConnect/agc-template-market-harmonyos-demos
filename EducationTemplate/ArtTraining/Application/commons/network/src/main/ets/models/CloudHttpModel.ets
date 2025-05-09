import { CloudFuncMap, RequestUrl } from '../constants/NetworkEnums';
import { replaceMockData } from '../mocks/MockRequestMap';
import { cloudRequest } from './Request';
import deviceInfo from '@ohos.deviceInfo';

interface HttpRequestConfig {
  url: RequestUrl;
  cloudFuncName?: CloudFuncMap;
  openMock?: boolean;
  data: ESObject;
}

class CloudHttpModel {
  private _openMock: boolean;

  constructor(openMock: boolean = false) {
    let productModelInfo: string = deviceInfo.productModel;
    this._openMock = productModelInfo ? openMock : true;
  }

  public call(config: HttpRequestConfig) {
    if (this._openMock || !canIUse('SystemCapability.DeviceCloudGateway.CloudFoundation')) {
      return replaceMockData(config.url, config.data);
    } else if (config.cloudFuncName) {
      return cloudRequest.call(config.cloudFuncName, config.data);
    }
    return Promise.reject('request failed');
  }
}

const request = new CloudHttpModel(); 

export default request;