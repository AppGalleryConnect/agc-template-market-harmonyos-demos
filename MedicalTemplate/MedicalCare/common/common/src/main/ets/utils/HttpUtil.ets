import axios, { AxiosError, AxiosInstance, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';

/**
 * 封装了axios的Http请求工具类
 */
export class HttpUtil {
  public instance: AxiosInstance

  constructor(baseUrl?: string) {
    this.instance = axios.create({
      baseURL: baseUrl,
      timeout: 5000,
      headers: {
        'Content-Type': 'application/json;charset=utf-8',
      },
    });
  }

  public addRequestInterceptor(interceptor: (config: InternalAxiosRequestConfig) => InternalAxiosRequestConfig,
    error: (error: AxiosError) => void) {
    return this.instance.interceptors.request.use(interceptor, error)
  }

  public get<T>(url: string, params?: object): Promise<T> {
    return this.requestInternal<T>('get', url, params)
  }

  public post<T>(url: string, data?: object): Promise<T> {
    return this.requestInternal<T>('post', url, undefined, data)
  }

  public delete<T>(url: string, data?: object): Promise<T> {
    return this.requestInternal<T>('delete', url, undefined, data)
  }

  public put<T>(url: string, data?: object): Promise<T> {
    return this.requestInternal<T>('put', url, undefined, data)
  }

  private requestInternal<T>(method: 'get' | 'post' | 'put' | 'delete', url: string, params?: object,
    data?: object): Promise<T> {
    return this.instance.request({
      method: method,
      url: url,
      params: params,
      data: data
    }).then((response: AxiosResponse<T>) => {
      if (response.status !== 200) {
        console.log(`HttpUtil: request code error ${JSON.stringify(response)}`)
        return Promise.reject(new AxiosError<object>(response.statusText, response.status.toString()))
      }
      return Promise.resolve(response.data as T)
    }).catch((error: AxiosError) => {
      console.log(`HttpUtil: request error ${JSON.stringify(error)}`)
      return Promise.reject(error)
    })
  }
}
