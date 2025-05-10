import axios, {
  AxiosAdapter,
  AxiosError,
  AxiosInstance,
  AxiosPromise,
  AxiosRequestConfig,
  AxiosResponse,
  InternalAxiosRequestConfig,
} from '@ohos/axios';

export interface MockResponse {
  status: number;
  data?: ESObject;
}

type MockCallback = (config: AxiosRequestConfig) => Promise<MockResponse>;

interface MockHandler {
  url: string;
  method: string;
  callback: MockCallback;
}

interface RequestHandler {
  reply: (callback: MockCallback) => void;
}

interface MockAdapterOptions {
  delayResponse?: number;
}

export class AxiosMock {
  private axiosInstance: AxiosInstance;
  private originalAdapter: AxiosAdapter;
  private axiosInstanceWithoutInterceptors: AxiosInstance;
  private handlers: MockHandler[] = [];
  private globalHandler: MockHandler | null = null;
  private delayResponse: number = 0;

  constructor(axiosInstance: AxiosInstance, options: MockAdapterOptions = {}) {
    this.axiosInstance = axiosInstance;
    this.originalAdapter = axiosInstance.defaults.adapter as AxiosAdapter;
    this.axiosInstance.defaults.adapter = this.adapter();
    this.axiosInstanceWithoutInterceptors = axios.create();
    this.delayResponse = options.delayResponse || 0;
  }

  public onGet(url: string): RequestHandler {
    return this.onRequest('get', url);
  }

  public onPost(url: string): RequestHandler {
    return this.onRequest('post', url);
  }

  public onPut(url: string): RequestHandler {
    return this.onRequest('put', url);
  }

  public onDelete(url: string): RequestHandler {
    return this.onRequest('delete', url);
  }

  public onAny(): RequestHandler {
    return {
      reply: (callback: MockCallback) => {
        const handler: MockHandler = {
          url: '',
          method: 'any',
          callback: callback,
        };
        this.globalHandler = handler;
      },
    };
  }

  private onRequest(method: string, url: string): RequestHandler {
    return {
      reply: (callback: MockCallback) => {
        const handler: MockHandler = {
          url,
          method,
          callback,
        };
        this.addHandler(handler);
      },
    };
  }

  private addHandler(handler: MockHandler): void {
    this.handlers.push(handler);
  }

  private adapter(): AxiosAdapter {
    return async (config: InternalAxiosRequestConfig): AxiosPromise => {
      config.adapter = undefined;
      const handler = this.handlers.find(
        (item) => item.url === config.url && item.method === config.method,
      );
      if (handler) {
        return this.getRespose(config, handler.callback, this.delayResponse);
      } else if (this.globalHandler !== null) {
        return this.getRespose(config, this.globalHandler.callback, this.delayResponse);
      } else {
        const newConfig = this.assign({}, config);
        newConfig.adapter = this.originalAdapter;
        return this.axiosInstanceWithoutInterceptors(newConfig);
      }
    };
  }

  private async getRespose(config: InternalAxiosRequestConfig, callback: MockCallback, delay: number): AxiosPromise {
    if (delay > 0) {
      const promise: Promise<void> = new Promise((resolve: Function) => {
        setTimeout(resolve, delay);
      });
      await promise;
    }
    const resp: MockResponse = await callback(config);
    const axiosResp: AxiosResponse = {
      data: resp.data,
      status: resp.status,
      statusText: resp.status.toString(),
      headers: {},
      config: config,
    };
    if (config.validateStatus && !config.validateStatus(resp.status)) {
      const error: AxiosError = AxiosError.from(
        new Error('Request failed with status code ' + resp.status),
        resp.status.toString(),
        config,
        null,
        axiosResp,
      );
      return Promise.reject(error);
    }
    return axiosResp;
  }

  private assign(target: Record<string, Object>, ...source: Object[]): Record<string, Object> {
    for (const items of source) {
      for (const key of Object.keys(items)) {
        target[key] = Reflect.get(items, key);
      }
    }
    return target;
  }
}
