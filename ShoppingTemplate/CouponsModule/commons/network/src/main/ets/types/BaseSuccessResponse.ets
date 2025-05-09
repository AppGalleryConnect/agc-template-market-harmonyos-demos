export interface BaseSuccessResponse<T = ESObject> {
  code: number;
  msg?: string;
  data: T;
}
