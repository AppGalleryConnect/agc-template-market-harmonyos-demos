import axios, { AxiosError, AxiosInstance } from '@ohos/axios';
import { BusinessError } from '@kit.BasicServicesKit';
import { HttpRequestConfig, InterceptorHooks } from '../types/HttpRequestConfig';
import { replaceMockData } from '../mocks/MockRequestMap';
import { Logger } from 'commonlib';

/**
 * 网络请求构造
 * 基于axios框架实现
 */
export class AxiosHttpRequest {
  config: HttpRequestConfig;
  openMock: boolean = false;
  interceptorHooks?: InterceptorHooks;
  instance: AxiosInstance;

  constructor(options: HttpRequestConfig, openMock: boolean = false) {
    this.config = options;
    this.interceptorHooks = options.interceptorHooks;
    this.openMock = openMock;
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
      this.openMock ? this.replaceMock : this.interceptorHooks?.responseInterceptorCatch,
    );
  }

  private replaceMock(error: AxiosError): Promise<ESObject> {
    if (error.config && error.config.baseURL === '') {
      if (error.config.params) {
        return replaceMockData(error.config.url, error.config.params);
      }

      const data: Object = JSON.parse(error.config.data ?? '{}');
      return replaceMockData(error.config.url, data);
    }
    return Promise.reject(error.response?.data);
  }

  request<T = ESObject>(config: HttpRequestConfig): Promise<T> {
    return new Promise<T>((resolve, reject) => {
      this.instance.request<ESObject, T>(config)
        .then((res) => {
          resolve(res);
        })
        .catch((err: BusinessError) => {
          Logger.error(`网络请求Request异常：${config.url}`, err.message);
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

  put<T = ESObject>(config: HttpRequestConfig): Promise<T> {
    config.method = 'PUT';
    return this.request(config);
  }

  delete<T = ESObject>(config: HttpRequestConfig): Promise<T> {
    config.method = 'DELETE';
    return this.request(config);
  }
}

export default AxiosHttpRequest;
