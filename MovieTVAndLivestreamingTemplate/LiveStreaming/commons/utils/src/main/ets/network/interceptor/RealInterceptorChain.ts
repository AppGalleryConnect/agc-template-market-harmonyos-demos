import type { Chain, Interceptor, ChainRequest, ChainResponse } from './Interceptor';

export class RealInterceptorChain implements Chain {
  interceptors : Interceptor[];
  request_: ChainRequest;
  index: number;

  constructor(interceptors: Interceptor[], index: number, request: ChainRequest) {
    this.interceptors = interceptors;
    this.index = index;
    this.request_ = request;
  }

  request(): ChainRequest {
    return this.request_;
  }

  async proceed(request: ChainRequest): Promise<ChainResponse> {
    if (this.index >= this.interceptors.length) {
      return Promise.reject("no call server interceptor");
    }
    let next: RealInterceptorChain = new RealInterceptorChain(
      this.interceptors,
      this.index + 1,
      request
    );
    let interceptor = this.interceptors[this.index];
    return interceptor.intercept(next);
  }
}
