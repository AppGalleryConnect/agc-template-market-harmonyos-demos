import { AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';

interface InterceptorHooks {
  requestInterceptor?: (config: HttpRequestConfig) => Promise<HttpRequestConfig>;
  requestInterceptorCatch?: (error: ESObject) => ESObject;
  responseInterceptor?: (response: AxiosResponse) => AxiosResponse | Promise<AxiosResponse>;
  responseInterceptorCatch?: (error: ESObject) => ESObject;
}

export interface HttpRequestConfig extends InternalAxiosRequestConfig {
  showLoading?: boolean; //是否展示请求loading
  interceptorHooks?: InterceptorHooks;
  method?: string;
  headers: ESObject;
}
