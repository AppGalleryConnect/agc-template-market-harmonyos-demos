import { AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';
import { BusinessError } from '@kit.BasicServicesKit';
import { AxiosHttpModel } from './AxiosHttpModel';
import { CommonConstants } from '@ohos_agcit/office_attendance_common_lib';

const request = new AxiosHttpModel(
  {
    baseURL: CommonConstants.BASE_URL,
    timeout: 10 * 3000,
    headers: {
      //'Content-Type': 'application/json',
    },
    interceptorHooks: {
      requestInterceptor: async (config: InternalAxiosRequestConfig) => {
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
        return Promise.reject(error);
      },
    },
  },
  true,
);

export default request;
