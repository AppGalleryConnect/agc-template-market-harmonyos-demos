import { AxiosHttpRequest, errorHandler } from './AxiosHttp';
import { AxiosResponse } from '@ohos/axios';
import { BusinessError } from '@kit.BasicServicesKit';
import { HUAWEIAccountModel } from 'account';
import { PersistenceV2 } from '@kit.ArkUI';

function resetLoginToken() {
  const accountInfo: HUAWEIAccountModel | undefined =
    PersistenceV2.connect(HUAWEIAccountModel, 'accountInfo', () => new HUAWEIAccountModel())!;
  accountInfo.loginToken = undefined;
}

const axiosClient = new AxiosHttpRequest({
  baseURL: '',
  timeout: 1000 * 1000,
  checkResultCode: false,
  headers: {
    'Content-Type': 'application/json',
  },
  interceptorHooks: {
    requestInterceptor: async (config) => {
      config.headers.Channel = 'b5343a0e3e266d5df68b24a8b76dc50c.2.XXX';
      return config;
    },
    requestInterceptorCatch: (err: BusinessError) => {
      return err;
    },
    responseInterceptor: (response: AxiosResponse) => {
      if (response.data.Response?.Result?.token) {
        AppStorage.setOrCreate('token', response.data.Response?.Result?.token);
      }
      if (response.status === 401) {
        resetLoginToken();
        return Promise.reject(response);
      }
      if (response.status === 200) {
        return Promise.resolve(response.data);
      } else {
        return Promise.reject(response);
      }
    },
    responseInterceptorCatch: (error: BusinessError) => {
      errorHandler(error);
      return Promise.reject(error);
    },
  },
});

export default axiosClient;