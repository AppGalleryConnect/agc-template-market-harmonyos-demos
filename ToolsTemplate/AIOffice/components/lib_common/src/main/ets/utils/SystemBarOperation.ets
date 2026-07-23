import { window } from '@kit.ArkUI';

export class SystemBarOperation {
  /**
   * 设置顶部状态栏颜色
   */
  public static setWindowSystemBarProp(properties: window.SystemBarProperties) {
    try {
      const windowStage = AppStorage.get('windowStage') as window.WindowStage;
      const windowClass = windowStage.getMainWindowSync()
      windowClass.setWindowSystemBarProperties(properties)
    } catch (error) {
      console.error('[SystemBarOperation] setWindowSystemBarProp error: ' + JSON.stringify(error));
    }
  }
}