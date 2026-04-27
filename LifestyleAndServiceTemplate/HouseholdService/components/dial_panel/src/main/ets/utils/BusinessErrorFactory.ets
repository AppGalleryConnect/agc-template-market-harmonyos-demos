import { BusinessError } from '@kit.BasicServicesKit';
import { DialErrorCode } from '../common/CustomTypes';

const errorData: Map<number, string> = new Map(([
  [DialErrorCode.SUCCESS, 'Success.'],
  [DialErrorCode.SYSCAP_NOT_SUPPORTED, 'The SystemCapability.Applications.Contacts is not supported.']
]));

export class BusinessErrorFactory {

  public static create<T>(code: number, message?: string, data?: T): BusinessError<T> {
    const msg: string | undefined = message ? message : errorData.get(code);
    const e: Error = new Error(msg);
    return {
      code: code,
      data: data,
      name: e.name,
      message: e.message,
      stack: e.stack
    };
  }
}
