import type { HttpMethod } from '../HttpOptions';

export interface Interceptor {
  intercept(chain: Chain): Promise<ChainResponse>;
}

export interface Chain {
  request(): ChainRequest;

  proceed(request: ChainRequest): Promise<ChainResponse>;
}

export interface ChainRequest {
  url: string;
  method: HttpMethod;
  headers: object;
  queries?: object;
  body?: string | object | ArrayBuffer;
  readTimeout?: number;
  connectTimeout?: number;
  tokenRefreshed?: boolean
}

export interface ChainResponse {
  code: number;
  result?: string | object | ArrayBuffer;
  headers?: object;
  message?: string;
  cost?: number;
}
