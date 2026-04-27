import {
  HttpRequestConfig,
  AxiosHttpRequest,
  AxiosResponse,
  HttpPromise,
  AxiosRequestHeaders,
  AxiosError,
  AxiosHeaders,
  FileUploadConfig
} from '@nutpi/axios'

// 默认配置
const DEFAULT_CONFIG: HttpRequestConfig = {
  baseURL: '',
  timeout: 60 * 1000,
  checkResultCode: false,
  showLoading: false,
  headers: new AxiosHeaders({
    'Content-Type': 'application/json'
  }) as AxiosRequestHeaders,
  interceptorHooks: {
    requestInterceptor: async (config) => {
      // 请求拦截器
      return config
    },
    requestInterceptorCatch: (err: Error) => {
      return err
    },
    responseInterceptor: (response: AxiosResponse) => {
      // 响应拦截器

      if (response.status === 200) {
        return Promise.resolve(response)
      } else {
        return Promise.reject(response)
      }
    },
    responseInterceptorCatch: (error: Error) => {
      return Promise.reject(error)
    }
  }
}

/**
 * 创建默认HTTP客户端
 * @returns AxiosHttpRequest实例
 */
export function createDefaultHttpClient(): AxiosHttpRequest {
  return new AxiosHttpRequest(DEFAULT_CONFIG)
}

// 便捷的http实例（推荐使用）
export const http = createDefaultHttpClient()

// 导出类型
export { HttpPromise, FileUploadConfig, AxiosRequestHeaders, AxiosError, AxiosHeaders }
