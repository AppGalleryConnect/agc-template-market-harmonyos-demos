import axios, {
  AxiosError,
  AxiosInstance,
  AxiosRequestConfig,
  AxiosResponse,
  InternalAxiosRequestConfig,
} from '@ohos/axios';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from 'commonlib';
import { replaceMockData } from '../mocks/MockRequestMap';

export class AxiosHttpModel {
  private _instance: AxiosInstance;
  private _openMock: boolean;
  private _config: HttpRequestConfig;

  constructor(config: HttpRequestConfig, openMock: boolean = false) {
    this._config = config;
    this._instance = axios.create(config);
    this._openMock = openMock;
    this._setupInterceptor();
  }

  public request<T = Object>(config: HttpRequestConfig): Promise<T> {
    return new Promise<T>((resolve, reject) => {
      this._instance
        .request<Object, T>(config)
        .then((res) => {
          resolve(res);
        })
        .catch((err: BusinessError) => {
          Logger.error(`https request failed：${config.url}`, err.message);
          reject(err);
        });
    });
  }

  public get<T = Object>(config: HttpRequestConfig): Promise<T> {
    config.method = 'GET';
    return this.request(config);
  }

  public post<T = Object>(config: HttpRequestConfig): Promise<T> {
    config.method = 'POST';
    return this.request(config);
  }

  public put<T = Object>(config: HttpRequestConfig): Promise<T> {
    config.method = 'PUT';
    return this.request(config);
  }

  public delete<T = Object>(config: HttpRequestConfig): Promise<T> {
    config.method = 'DELETE';
    return this.request(config);
  }

  private _setupInterceptor(): void {
    if (this._config.interceptorHooks) {
      this._instance.interceptors.request.use(
        this._config.interceptorHooks.requestInterceptor,
        this._config.interceptorHooks.requestInterceptorCatch,
      );
      this._instance.interceptors.response.use(
        this._config.interceptorHooks.responseInterceptor,
        this._openMock ? this._replaceMock : this._config.interceptorHooks.responseInterceptorCatch,
      );
    }
  }

  private _replaceMock(error: AxiosError): Promise<Object> {
    if (error.config && error.config.baseURL === '') {
      if (error.config.method === 'get') {
        return replaceMockData(error.config.url, error.config.params);
      }
      const data: ESObject = JSON.parse(error.config.data ?? '{}');
      return replaceMockData(error.config.url, data);
    }
    return Promise.reject(error.response?.data);
  }
}

export interface HttpRequestConfig extends AxiosRequestConfig {
  showLoading?: boolean;
  interceptorHooks?: InterceptorHooks;
  method?: string;
}

export interface InterceptorHooks {
  requestInterceptor?: (config: InternalAxiosRequestConfig) => Promise<InternalAxiosRequestConfig>;
  requestInterceptorCatch?: (error: BusinessError) => BusinessError;
  responseInterceptor?: (response: AxiosResponse) => AxiosResponse | Promise<AxiosResponse>;
  responseInterceptorCatch?: (error: BusinessError) => BusinessError;
}
