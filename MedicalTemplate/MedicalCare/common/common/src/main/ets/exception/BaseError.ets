import { BusinessError } from '@ohos.base';

export class BaseError implements BusinessError<string> {
  code: number;
  name: string;
  message: string;

  public constructor(msg: string, name?: string) {
    this.code = -1
    this.name = name || 'BaseError'
    this.message = msg
  }
}