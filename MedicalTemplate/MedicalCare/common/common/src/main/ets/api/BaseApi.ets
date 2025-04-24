import { AuthenticationUtil } from '../utils/AuthenticationUtil';
import { LogUtil } from '../utils/LogUtil';
import { ToastUtil } from '../utils/ToastUtil';
import { PreferenceUtil } from '../utils/PreferenceUtil';
import { LoadingDialogUtil } from '../utils/DialogUtil';
import { BaseResponse } from '../model/BaseResponse';
import { HttpUtil } from '../utils/HttpUtil';
import { ResourceUtil } from '../utils/ResourceUtil';
import { BaseError } from '../../../../Index';
import { AxiosError, InternalAxiosRequestConfig } from '@ohos/axios';

export enum RequestMethod {
  GET,
  POST,
  PUT,
  DELETE
}

export interface BaseApiConfig {
  baseUrl?: string
  // 是否使用Mock数据
  isMock?: boolean
  // 是否显示默认错误 Toast
  showDefaultErrorToast?: boolean
  showLoading?: boolean
  onLoadingCallback?: (isLoading: boolean) => void
}

export class BaseApi {
  public config: BaseApiConfig
  private httpUtil: HttpUtil
  private preferenceUtil: PreferenceUtil
  private authorization: string | undefined = ''

  constructor(config: BaseApiConfig) {
    this.config = {
      baseUrl: config.baseUrl || 'http://10.0.2.2:8080',
      isMock: config.isMock || false,
      showDefaultErrorToast: config.showDefaultErrorToast || true,
      showLoading: config.showLoading === undefined ? true : config.showLoading,
      onLoadingCallback: config.onLoadingCallback
    } as BaseApiConfig
    this.preferenceUtil = PreferenceUtil.getInstance()

    this.httpUtil = new HttpUtil(this.config.baseUrl);

    this.httpUtil.addRequestInterceptor((config: InternalAxiosRequestConfig) => {
      let auth = this.authorization || 'null'
      config.headers.setAuthorization('Bearer ' + auth)
      LogUtil.debug(`BaseApi: 请求参数 ${JSON.stringify(config)}`)
      return config
    }, (error: AxiosError) => {
      LogUtil.debug(`BaseApi: 请求错误 ${JSON.stringify(error)}`)
      return Promise.reject(new BaseError(error.message))
    })
  }

  /**
   * 发送网络请求
   *
   * @param url 请求地址，与BaseUrl拼接后生成最终的请求地址
   * @param method 请求方法
   * @param requestData 请求参数
   * @param showLoading 是否显示加载对话框（有缓存时不显示），优先级高于全局配置
   * @param onCacheCallback 此项不为undefined则启用缓存，如果缓存存在，直接返回缓存数据；缓存后仍然会继续发起网络请求，并再次回调
   */
  public async sendRequest<T>(url: string, method: RequestMethod, requestData?: object,
    showLoading?: boolean | undefined, onCacheCallback?: (data: T) => void): Promise<T> {
    LogUtil.debug(`Send request: ${this.config.baseUrl + url} ${JSON.stringify(requestData)}`)

    showLoading = showLoading === undefined ? this.config.showLoading : showLoading

    if (!this.authorization) {
      try {
        const credential = await AuthenticationUtil.getAuthenticationInfoAsync()
        this.authorization = credential.openID;
      } catch (error) {
        LogUtil.info(`BaseApi: Error get auth info, ${JSON.stringify(error)}`)
      }
    }

    if (onCacheCallback) {
      let cacheResponse = this.preferenceUtil.get(this.getPreferenceKey(url, method))
      if (cacheResponse) {
        onCacheCallback(cacheResponse as T)
        showLoading = false
      }
    }

    if (showLoading) {
      LoadingDialogUtil.openLoadingDialog()
    }

    this.config.onLoadingCallback?.(true)

    if (this.config.isMock) {
      return this.mockResult<T>(url, method, onCacheCallback)
    }

    let requestResult: Promise<BaseResponse>
    switch (method) {
      case RequestMethod.GET:
        requestResult = this.httpUtil.get(url, requestData)
        break;
      case RequestMethod.POST:
        requestResult = this.httpUtil.post(url, requestData)
        break;
      case RequestMethod.PUT:
        requestResult = this.httpUtil.put(url, requestData)
        break;
      case RequestMethod.DELETE:
        requestResult = this.httpUtil.delete(url, requestData)
        break;
      default:
        return Promise.reject(new BaseError('Method not implemented.'))
    }

    try {
      let response = await requestResult;
      if (response.code !== 0) {
        throw new BaseError(response.message);
      }
      LogUtil.debug(`BaseApi callback onSuccess ${JSON.stringify(response)}`)
      if (onCacheCallback) {
        this.preferenceUtil.put(this.getPreferenceKey(url, method), response as object)
      }
      let responseData = response.data as T;
      onCacheCallback?.(responseData)
      return responseData
    } catch (error) {
      LogUtil.debug(`BaseApi callback onError ${JSON.stringify(error)}`)
      let e = error as BaseError;
      if (this.config.showDefaultErrorToast) {
        ToastUtil.showToast(e.message); // 显示默认 Toast
      }
      throw e; // 抛出通用错误
    } finally {
      LoadingDialogUtil.close();
      this.config.onLoadingCallback?.(false)
    }
  }

  /**
   * 模拟请求（仅本地测试用）
   * @param url 请求地址，会自动转换成rawfile下面的文件路径
   * @param callback
   */
  private async mockResult<T>(url: string, method: RequestMethod, onCacheCallback?: (data: T) => void) {
    let requestStringMap: Map<RequestMethod, string> = new Map([
      [RequestMethod.GET, 'get'],
      [RequestMethod.POST, 'post'],
      [RequestMethod.PUT, 'put'],
      [RequestMethod.DELETE, 'delete'],
    ])

    let fileName: string = `${requestStringMap.get(method)}.`
    let urlSplit: string[] = url.split('/')
    for (let i = 0; i < urlSplit.length; i++) {
      if (!urlSplit[i]) {
        continue
      }
      fileName += urlSplit[i]
      if (i < urlSplit.length - 1) {
        fileName += '.'
      } else {
        fileName += '.json'
      }
    }

    let randomTime = Math.floor(Math.random()) * 300 + 200

    try {
      const data: T | null = await ResourceUtil.readObjectFromResource<T>(fileName);
      await new Promise<T>(resolve => setTimeout(resolve, randomTime)); // 模拟延迟

      LogUtil.debug(`mockResult: ${JSON.stringify(data)}`)
      if (data === null) {
        throw new BaseError(`Read mock json ${fileName} failed: data is null`);
      } else {
        if (onCacheCallback) {
          this.preferenceUtil.put(this.getPreferenceKey(url, method), data as object)
        }
        onCacheCallback?.(data)
        return data; // 返回数据
      }
    } catch (error) {
      let e: BaseError = error as BaseError
      LogUtil.debug(`mockResult: ${JSON.stringify(error)}`)
      if (this.config.showDefaultErrorToast) {
        ToastUtil.showToast(e.message);
      }
      throw e;
    } finally {
      LoadingDialogUtil.close();
      this.config.onLoadingCallback?.(false)
    }
  }

  private getPreferenceKey(url: string, method: RequestMethod): string {
    let key = `${url}_${method}_${this.authorization}`
    LogUtil.info(`getPreferenceKey: ${key}`)
    return key
  }
}
