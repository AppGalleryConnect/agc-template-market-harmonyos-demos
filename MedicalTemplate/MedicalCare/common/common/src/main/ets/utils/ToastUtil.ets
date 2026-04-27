import { BusinessError } from '@kit.BasicServicesKit';
import { GlobalContextUtils } from './ContextUtils';

export class ToastUtil {
  static showToast(error: BusinessError | string) {
    const message: string = typeof error === 'string' ? error : error.message
    GlobalContextUtils.showToast({
      message,
      duration: 2000
    });
  }
}
