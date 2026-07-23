import { BusinessError } from '@kit.BasicServicesKit';
import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';
import { AppStorageMap } from '../constants/CommonEnums';
import { CommonConstants } from '../constants/Constants';
import { Logger } from '../utils/Logger';

const instance = axios.create({
  baseURL: CommonConstants.BASE_URL,
  timeout: 3000,
});

// Add a request interceptor.
instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  if (!config.url?.includes('loginWithHuaweiID')) {
    config.headers.set('Token', AppStorage.get(AppStorageMap.TOKEN));
  }
  return config;
}, (error: AxiosError) => {
  return Promise.reject(error);
});

instance.interceptors.response.use(
  (response: AxiosResponse) => {
    if (response.status === 200) {
      return Promise.resolve(response.data);
    } else {
      Logger.error('[Network]', `https request failed：${response.config.url}. error: ${response.status}`);
      return Promise.reject(response);
    }
  },
  (error: BusinessError) => {
    Logger.error('[Network]', `https request failed：. error: ${JSON.stringify(error)}`);
    return Promise.reject(error);
  },
);

export default instance;