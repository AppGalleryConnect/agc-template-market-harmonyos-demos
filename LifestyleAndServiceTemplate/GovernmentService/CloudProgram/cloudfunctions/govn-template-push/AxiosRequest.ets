//AxiosRequest.ets
import { AxiosHttpRequest, errorHandler } from './AxiosHttp'
import { AxiosRequestHeaders, AxiosResponse } from 'axios';
import { getJWT } from './JWT';

const axiosClient = new AxiosHttpRequest({
  baseURL: '/api',
  timeout: 10 * 1000,
  checkResultCode: false,
  headers: {
    'Content-Type': 'application/json',
  } as AxiosRequestHeaders,
  interceptorHooks: {
    requestInterceptor: async (config) => {
      // 在发送请求之前做一些处理，例如打印请求信息
      config.headers['Authorization'] = `Bearer ${getJWT()}`
      return config;
    },
    requestInterceptorCatch: (err) => {
      if (axiosClient.config.showLoading) {
        // hideLoading()
      }
      return err;
    },
    responseInterceptor: (response: AxiosResponse) => {
      //优先执行自己的请求响应拦截器，在执行通用请求request的
      if (axiosClient.config.showLoading) {
        // hideLoading()
      }
      // LogUtils.debug('网络请求响应Response:', `\n${JsonUtils.stringify(response.data)}`);
      if (response.status === 200) {
        return Promise.resolve(response.data);
      } else {
        return Promise.reject(response);
      }
    },
    responseInterceptorCatch: (error) => {
      if (axiosClient.config.showLoading) {
        // hideLoading()
      }
      // LogUtils.error("网络请求响应异常", error.toString())
      errorHandler(error);
      return Promise.reject(error);
    },
  },
});

export default axiosClient;