import { BusinessError } from '@kit.BasicServicesKit';
import { vibrator } from '@kit.SensorServiceKit';
import { Logger } from './Logger';

const TAG: string = 'VibratorUtil';

export class VibratorUtil {
  public static notification(duration: number, id: number): void {
    try {
      // 触发马达振动
      vibrator.startVibration({
        type: 'time',
        duration: duration,
      }, {
        id: id,
        usage: 'notification'
      }, (error: BusinessError) => {
        if (error) {
          Logger.error(TAG, `Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
          return;
        }
        Logger.info(TAG, 'Succeed in starting vibration');
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      Logger.info(TAG, `An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
    }
  }
}