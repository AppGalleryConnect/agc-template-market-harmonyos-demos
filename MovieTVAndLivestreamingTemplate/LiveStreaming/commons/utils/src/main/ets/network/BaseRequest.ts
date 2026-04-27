import type { HttpMethod } from './HttpOptions';

export class BaseRequest {
  method: HttpMethod;
  host: string;
  path: string;
  headers?: { [key: string]: string };
  body?: { [key: string]: string | number | object };
  query?: { [key: string]: string | number };

  headersIndex?: number;
  bodyIndex?: number;
  queryIndex?: number;

}

