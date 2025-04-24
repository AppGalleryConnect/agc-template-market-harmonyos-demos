import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

export class ToastUtil {
  static showToast(error: BusinessError | string) {
    const message: string = typeof error === 'string' ? error : error.message
    promptAction.showToast({
      message,
      duration: 2000
    });
  }
}
