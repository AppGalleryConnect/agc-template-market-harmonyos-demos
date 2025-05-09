//AxiosRequest.ets
import { AxiosHttpRequest } from './AxiosHttp';
import { AxiosRequestHeaders, AxiosResponse } from '@ohos/axios';
import { BusinessError } from '@kit.BasicServicesKit';
import { Constants, HttpCode, RequestUrl } from '../constants/Common';

const axiosClient = new AxiosHttpRequest({
  baseURL: RequestUrl.BASE_URL,
  checkResultCode: false,
  // 5秒超时
  timeout: Constants.REQUEST_TIME_OUT,
  headers: {
    'Content-Type': 'application/json',
  } as AxiosRequestHeaders,
  interceptorHooks: {
    requestInterceptor: async (config) => {
      axiosClient.config.showLoading = config.showLoading;
      if (config.baseURL) {
        // 补充公共请求参数
        if (!config.params) {
          config.params = {};
        }
        config.params.i = 'xxxxx';
      }

      if (config.showLoading) {
        // showLoading
      }
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
      }
      if (response.data.Response?.Result?.token) {
        AppStorage.setOrCreate('token', response.data.Response?.Result?.token);
      }
      // LogUtils.debug('网络请求响应Response:', `\n${JsonUtils.stringify(response.data)}`);
      if (response.status === HttpCode.SUCCESS_200) {
        return Promise.resolve(response.data);
      } else {
        return Promise.reject(response);
      }
    },
    responseInterceptorCatch: (error: BusinessError) => {
      if (axiosClient.config.showLoading) {
      }
      return Promise.reject(error);
    },
  },
}, true);

export default axiosClient;