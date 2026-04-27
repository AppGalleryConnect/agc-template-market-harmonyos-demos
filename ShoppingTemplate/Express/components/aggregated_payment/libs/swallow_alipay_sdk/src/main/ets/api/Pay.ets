import window from '@ohos.window';

interface Loading {
  loadingWindow?: window.Window;

  show(): Promise<void>;

  hide(): Promise<void>;
}

export class Pay {
  public context?: Context;
  public showLoading?: boolean;
  public registeredApp?: boolean;
  public loading?: Loading;
  public navPathStack?: NavPathStack;
  public navCallback?: (name: string, params: Map<string, Object>) => void;

  public getVersion(): string {
    return '';
  }

  public pay(_orderInfo: string, _showLoading?: boolean): Promise<Map<string, string>> {
    return Promise.reject('Swallow: method not implemented.');
  }

  public payWithNav(
    _orderInfo: string,
    _showLoading?: boolean,
    _callback?: (name: string, params: Map<string, Object>) => void,
    _navStack?: NavPathStack | undefined,
  ): Promise<Map<string, string>> {
    return Promise.reject('Swallow: method not implemented.');
  }

  public registerApp(_: string): void {

  }

  public payInterceptorWithUrl(
    _h5PayUrl: string,
    _showPayLoading: boolean,
    _callback: (result: Map<string, string>) => void,
  ): boolean {
    throw new Error('Swallow: method not implemented.');
  }
}
