import { AxiosRequestHeaders, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';
import { BusinessError } from '@kit.BasicServicesKit';


/**
 * 定义接口响应包装类
 */
export interface BaseResponse {
  errorCode: number
  errorMsg: string
  //拓展xxx-API响应体
}

export interface ApiResponse<T> extends BaseResponse {
  data: T;
  //拓展xxx-API响应体
}

export interface InterceptorHooks {
  requestInterceptor?: (config: HttpRequestConfig) => Promise<HttpRequestConfig>;
  requestInterceptorCatch?: (error: BusinessError) => BusinessError;
  responseInterceptor?: (response: AxiosResponse) => AxiosResponse | Promise<AxiosResponse>;
  responseInterceptorCatch?: (error: BusinessError) => Promise<BusinessError>;
}

export interface HttpRequestConfig extends InternalAxiosRequestConfig {
  showLoading?: boolean; //是否展示请求loading
  checkResultCode?: boolean; //是否检验响应结果码
  needJumpToLogin?: boolean //是否需要跳转到登陆页面
  interceptorHooks?: InterceptorHooks;
  method?: string;
  headers: AxiosRequestHeaders
}