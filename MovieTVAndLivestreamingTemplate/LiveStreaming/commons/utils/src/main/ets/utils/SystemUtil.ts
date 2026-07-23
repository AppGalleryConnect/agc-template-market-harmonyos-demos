
import { Context } from '@ohos.abilityAccessCtrl';
import { BusinessError } from '@ohos.base';

export class SystemUtil {
  public static exitApp(context: Context): Promise<void> {
    let applicationContext = context.getApplicationContext();
    try {
      return applicationContext.killAllProcesses();
    } catch (error) {
      let err = error as BusinessError;
      console.error(`exitApp failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      return Promise.reject(err);
    }
  }
}