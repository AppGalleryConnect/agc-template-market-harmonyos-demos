import { window } from '@kit.ArkUI';
import { Logger } from './Logger';

const TAG = '[SystemBarOperation]';

export class SystemBarOperation {
  /**
   * 设置顶部状态栏颜色
   */
  public static async setWindowSystemBarProp(properties: window.SystemBarProperties) {
    try {
      const windowStage = AppStorage.get('windowStage') as window.WindowStage;
      const windowClass = windowStage.getMainWindowSync()
      await windowClass.setWindowSystemBarProperties(properties)
    } catch (e) {
      Logger.error(TAG, 'setWindowSystemBarProp fail, error: ' + JSON.stringify(e));
    }
  }
}