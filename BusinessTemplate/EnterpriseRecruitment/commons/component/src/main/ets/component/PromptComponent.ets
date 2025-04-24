import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../utils/Logger';

export function promptFun(message: string | Resource, duration: number): void {
  try {
    promptAction.showToast({
      message: message,
      duration: duration
    });
  } catch (error) {
    let message = (error as BusinessError).message
    let code = (error as BusinessError).code
    Logger.error(`showToast args error code is ${code}, message is ${message}`);
  }
}