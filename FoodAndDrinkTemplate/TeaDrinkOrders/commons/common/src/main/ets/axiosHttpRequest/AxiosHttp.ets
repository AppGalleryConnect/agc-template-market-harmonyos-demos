import axios, { AxiosInstance } from '@ohos/axios';
import { BusinessError } from '@kit.BasicServicesKit';
import * as MockResponse from '../mock/MockResponse';
import { HttpRequestConfig, InterceptorHooks } from './AxiosModel';


/**
 * 网络请求构造
 * 基于axios框架实现
 */
export class AxiosHttpRequest {
  config: HttpRequestConfig;
  instance: AxiosInstance;
  interceptorHooks?: InterceptorHooks;
  mockFlag: boolean = false;

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

  constructor(options: HttpRequestConfig, mockFlag: boolean = false) {
    this.mockFlag = mockFlag;
    this.config = options;
    this.instance = axios.create(options);
    this.interceptorHooks = options.interceptorHooks;
    this.setupInterceptor()
  }

  request<T>(config: HttpRequestConfig): Promise<T> {
    return new Promise<T>((resolve, reject) => {
      if (this.mockFlag) {
        let res = MockResponse.getMockResponse<T>(config)
        resolve(res)
        return
      }
      this.instance
        .request<null, T>(config)
        .then(res => {
          resolve(res);
        })
        .catch((err: BusinessError) => {
          console.error('网络请求Request异常：', err.message)
          if (err) {
            reject(err);
          }
        });
    });
  }

  get<T>(config: HttpRequestConfig): Promise<T> {
    config.method = 'GET'
    return this.request(config);
  }

  post<T>(config: HttpRequestConfig): Promise<T> {
    config.method = 'POST'
    return this.request(config);
  }

  delete<T>(config: HttpRequestConfig): Promise<T> {
    config.method = 'DELETE'
    return this.request(config);
  }
}

export default AxiosHttpRequest