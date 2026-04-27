export interface HttpOptions {
  readTimeout?: number;
  connectTimeout?: number;
}

export type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';
