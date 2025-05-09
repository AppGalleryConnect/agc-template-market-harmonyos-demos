/* eslint-disable */
import { AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';
import { BusinessError } from '@kit.BasicServicesKit';
import { AccountUtil, CommonConstants } from 'commonlib';
import { AxiosHttpModel } from './AxiosHttpModel';

const request = new AxiosHttpModel(
  {
    baseURL: CommonConstants.BASE_URL,
    timeout: 10 * 3000,
    headers: {},
    interceptorHooks: {
      requestInterceptor: async (config: InternalAxiosRequestConfig) => {
        config.headers.set('authorization', AccountUtil.getAuthorization());
        return config;
      },
      requestInterceptorCatch: (err: BusinessError) => {
        return err;
      },
      responseInterceptor: (response: AxiosResponse) => {
        if (response.status === 200 && response.data.code === 0) {
          return Promise.resolve(response.data);
        } else {
          return Promise.reject(response);
        }
      },
      responseInterceptorCatch: (error: BusinessError) => {
        return error;
      },
    },
  },
  true,
);

export default request;
