export class BaseResponse<T> {
  protected body: T
  protected headers: any;

  constructor(response?: any, headers?: any) {
    this.body = response;
    this.headers = headers;
  }

  isSuccess(): boolean {
    return true;
  }

  getRetCode(): string {
    return "0";
  }

  getMessage(): string {
    return "success"
  }

  getBody(): T {
    return this.body;
  }

  getHeaders(): any {
    return this.headers;
  }
}
