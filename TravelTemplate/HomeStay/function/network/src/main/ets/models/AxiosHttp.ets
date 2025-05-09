import axios, { AxiosError, AxiosInstance, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from 'util';
import { promptAction } from '@kit.ArkUI';

interface InterceptorHooks {
  requestInterceptor?: (config: HttpRequestConfig) => Promise<HttpRequestConfig>;
  requestInterceptorCatch?: (error: ESObject) => ESObject;
  responseInterceptor?: (response: AxiosResponse) => AxiosResponse | Promise<AxiosResponse>;
  responseInterceptorCatch?: (error: ESObject) => ESObject;
}

interface HttpRequestConfig extends InternalAxiosRequestConfig {
  showLoading?: boolean; //是否展示请求loading
  checkResultCode?: boolean; //是否检验响应结果码
  checkLoginState?: boolean; //校验用户登陆状态
  needJumpToLogin?: boolean; //是否需要跳转到登陆页面
  interceptorHooks?: InterceptorHooks;
  method?: string;
  headers: ESObject;
}

export class AxiosHttpRequest {
  config: HttpRequestConfig;
  interceptorHooks?: InterceptorHooks;
  instance: AxiosInstance;

  constructor(options: HttpRequestConfig) {
    this.config = options;
    this.interceptorHooks = options.interceptorHooks;
    this.instance = axios.create(options);
    this.setupInterceptor();
  }

  setupInterceptor(): void {
    this.instance.interceptors.request.use(
      this.interceptorHooks?.requestInterceptor,
      this.interceptorHooks?.requestInterceptorCatch,
    );
    this.instance.interceptors.response.use(
      this.interceptorHooks?.responseInterceptor,
      this.interceptorHooks?.responseInterceptorCatch,
    );
  }

  request<T = ESObject>(config: HttpRequestConfig): Promise<T> {
    return new Promise<T>((resolve, reject) => {
      this.instance
        .request<ESObject, T>(config)
        .then(res => {
          Logger.info(JSON.stringify(res));
          resolve(res);
        })
        .catch((err: BusinessError) => {
          Logger.error('网络请求Request异常：', err.message);
          errorHandler(err);
          if (err) {
            reject(err);
          }
        });
    });
  }

  get<T = ESObject>(config: HttpRequestConfig): Promise<T> {
    config.method = 'GET';
    return this.request(config);
  }

  post<T = ESObject>(config: HttpRequestConfig): Promise<T> {
    config.method = 'POST';
    return this.request(config);
  }

  delete<T = ESObject>(config: HttpRequestConfig): Promise<T> {
    config.method = 'DELETE';
    return this.request(config);
  }
}

export function showToast(msg: string) {
  promptAction.showToast({
    message: msg,
    duration: 1000,
  });
}

export function errorHandler(error: ESObject) {
  if (error instanceof AxiosError) {
    showToast(error.message);
  } else if (error !== undefined && error.response !== undefined && error.response.status) {
    switch (error.response.status) {
      case 401:
        break;
      case 403:
        break;
      case 404:
        break;
      default:
        showToast(error.response.data.message);
    }

  }
}

export default AxiosHttpRequest;