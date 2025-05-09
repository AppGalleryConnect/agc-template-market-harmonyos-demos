import { AxiosResponse } from '@ohos/axios';
import { HttpRequestConfig } from './HttpRequestConfig';

/**
 * 封装后，不支持传入拦截器
 * 需要自己定义接口继承 AxiosRequestConfig类型
 * 从而支持传入拦截器，但拦截器选项应为可选属性
 * 之后请求实例传入的options为继承了AxiosRequestConfig的自定义类型
 */
export interface InterceptorHooks {
  requestInterceptor?: (config: HttpRequestConfig) => Promise<HttpRequestConfig>;
  requestInterceptorCatch?: (error: ESObject) => ESObject;
  responseInterceptor?: (response: AxiosResponse) => AxiosResponse | Promise<AxiosResponse>;
  responseInterceptorCatch?: (error: ESObject) => ESObject;
}
