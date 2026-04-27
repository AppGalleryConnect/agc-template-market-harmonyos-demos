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
  public pay(_: string, __?: boolean): Promise<Map<string, string>> {
    return Promise.reject('Swallow: method not implemented.');
  }
  public payWithNav(
    _: string,
    __?: boolean,
    ___?: (name: string, params: Map<string, Object>) => void,
    ____?: NavPathStack | undefined
  ): Promise<Map<string, string>> {
    return Promise.reject('Swallow: method not implemented.');
  }
  public registerApp(_: string): void {

  }
  public payInterceptorWithUrl(_: string, __: boolean, ___: (result: Map<string, string>) => void): boolean {
    throw new Error('Swallow: method not implemented.');
  }
}
