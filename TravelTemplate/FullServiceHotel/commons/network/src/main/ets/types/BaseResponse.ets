export interface BaseResponse<T = ESObject> {
  code: number;
  msg?: string;
  data: T;
}
