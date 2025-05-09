import axios, {
  AxiosError,
  AxiosInstance,
  AxiosRequestConfig,
  AxiosRequestHeaders,
  AxiosResponse,
  InternalAxiosRequestConfig
} from '@ohos/axios';
import { BusinessError } from '@kit.BasicServicesKit';


/**
 * 定义接口响应包装类
 */
export interface BaseResponse {
  errorCode: number
  errorMsg: string
  //拓展xxx-API响应体
}

export interface ApiResponse<T = ESObject> extends BaseResponse {
  data: T | ESObject;
  //拓展xxx-API响应体
}

/**
 * 封装后，不支持传入拦截器
 * 需要自己定义接口继承 AxiosRequestConfig类型
 * 从而支持传入拦截器，但拦截器选项应为可选属性
 * 之后请求实例传入的options为继承了AxiosRequestConfig的自定义类型
 */
interface InterceptorHooks {
  requestInterceptor?: (config: HttpRequestConfig) => Promise<HttpRequestConfig>;
  requestInterceptorCatch?: (error: ESObject) => ESObject;
  responseInterceptor?: (response: AxiosResponse) => AxiosResponse | Promise<AxiosResponse>;
  responseInterceptorCatch?: (error: ESObject) => ESObject;
}

interface HttpRequestConfig extends InternalAxiosRequestConfig {
  showLoading?: boolean; //是否展示请求loading
  checkResultCode?: boolean; //是否检验响应结果码
  checkLoginState?: boolean //校验用户登陆状态
  needJumpToLogin?: boolean //是否需要跳转到登陆页面
  interceptorHooks?: InterceptorHooks;
  method?: string;
  headers: AxiosRequestHeaders
}


/**
 * 网络请求构造
 * 基于axios框架实现
 */
export class AxiosHttpRequest {
  config: HttpRequestConfig;
  interceptorHooks?: InterceptorHooks;
  instance: AxiosInstance;

  constructor(options: HttpRequestConfig) {
    this.config = options;
    this.interceptorHooks = options.interceptorHooks;
    this.instance = axios.create(options);
    this.setupInterceptor()
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
          resolve(res);
        })
        .catch((err: BusinessError) => {
          console.error('网络请求Request异常：', err.message)
          errorHandler(err)
          if (err) {
            reject(err);
          }
        });
    });
  }

  get<T = ESObject>(config: HttpRequestConfig): Promise<T> {
    config.method = 'GET'
    return this.request(config);
  }

  post<T = ESObject>(config: HttpRequestConfig): Promise<T> {
    config.method = 'POST'
    return this.request(config);
  }

  delete<T = ESObject>(config: HttpRequestConfig): Promise<T> {
    config.method = 'DELETE'
    return this.request(config);
  }
}

export function errorHandler(error: ESObject) {
  if (error instanceof AxiosError) {
    // showToast(error.message)
  } else if (error !== undefined && error.response !== undefined && error.response.status) {
    switch (error.response.status) {
      // 401: 未登录
      // 未登录则跳转登录页面，并携带当前页面的路径
      // 在登录成功后返回当前页面，这一步需要在登录页操作。
      case 401:

        break;
        // 403 token过期
        // 登录过期对用户进行提示
        // 清除本地token和清空vuex中token对象
        // 跳转登录页面
      case 403:
        // showToast("登录过期，请重新登录")
        // 清除token
        // localStorage.removeItem('token');
        break;
        // 404请求不存在
      case 404:
        // showToast("网络请求不存在")
        break;

      // 其他错误，直接抛出错误提示
      default:
      // showToast(error.response.data.message)
    }

  }
}

export default AxiosHttpRequest