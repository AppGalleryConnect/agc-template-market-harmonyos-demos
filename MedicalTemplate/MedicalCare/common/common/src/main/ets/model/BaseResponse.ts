export class BaseResponse<T = object> {
  code: number = 0
  message: string = ''
  data: T = {} as T
}