
import { Context } from '@ohos.abilityAccessCtrl';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'SystemUtil';

export class SystemUtil {
  public static exitApp(context: Context): Promise<void> {
    try {
      let applicationContext = context.getApplicationContext();
      return applicationContext.killAllProcesses();
    } catch (e) {
      hilog.error(0x0000, TAG, `exitApp failed: ${e}`);
      return Promise.reject(e);
    }
  }
}