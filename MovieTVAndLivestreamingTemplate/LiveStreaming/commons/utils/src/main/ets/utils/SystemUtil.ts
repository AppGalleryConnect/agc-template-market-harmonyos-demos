
import { Context } from '@ohos.abilityAccessCtrl';

export class SystemUtil {
  public static exitApp(context: Context): Promise<void> {
    let applicationContext = context.getApplicationContext();
    return applicationContext.killAllProcesses();
  }
}