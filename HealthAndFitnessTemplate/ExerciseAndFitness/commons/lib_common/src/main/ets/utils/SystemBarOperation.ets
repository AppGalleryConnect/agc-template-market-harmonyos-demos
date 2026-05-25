import { window } from '@kit.ArkUI';

export class SystemBarOperation {
  /**
   * 设置顶部状态栏颜色
   */
  public static setWindowSystemBarProp(properties: window.SystemBarProperties) {
    const windowStage = AppStorage.get('windowStage') as window.WindowStage;
    const windowClass = windowStage.getMainWindowSync()
    try {
      windowClass.setWindowSystemBarProperties(properties)
    } catch (e) {
      console.error('setWindowSystemBarProperties failed')
    }
  }
}