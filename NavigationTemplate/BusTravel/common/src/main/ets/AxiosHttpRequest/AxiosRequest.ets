//AxiosRequest.ets
import { AxiosHttpRequest, errorHandler } from './AxiosHttp'
import { AxiosRequestHeaders, AxiosResponse } from '@ohos/axios';
import { BusinessError } from '@kit.BasicServicesKit';

const axiosClient = new AxiosHttpRequest({
  baseURL: '/api',
  timeout: 10 * 1000,
  checkResultCode: false,
  headers: {
    'Content-Type': 'application/json'
  } as AxiosRequestHeaders,
  interceptorHooks: {
    requestInterceptor: async (config) => {
      return config;
    },
    requestInterceptorCatch: (err: BusinessError) => {
      if (axiosClient.config.showLoading) {
      }
      return err;
    },
    responseInterceptor: (response: AxiosResponse) => {
      //优先执行自己的请求响应拦截器，在执行通用请求request的
      if (axiosClient.config.showLoading) {
        // hideLoading()
      }
      if (response.data.Response?.Result?.token) {
        AppStorage.setOrCreate('token', response.data.Response?.Result?.token)
      }
      // LogUtils.debug('网络请求响应Response:', `\n${JsonUtils.stringify(response.data)}`);
      if (response.status === 200) {
        return Promise.resolve(response.data);
      } else {
        return Promise.reject(response);
      }
    },
    responseInterceptorCatch: (error: BusinessError) => {
      if (axiosClient.config.showLoading) {
        // hideLoading()
      }
      // LogUtils.error("网络请求响应异常", error.toString())
      errorHandler(error);
      return Promise.reject(error);
    },
  }
});

export default axiosClient;