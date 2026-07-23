import { window } from '@kit.ArkUI';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
const TAG = '[WindowUtils]';

/**
 * 窗口持久化
 */
@ObservedV2
export class WindowUtils {
  @Trace static windowTopPadding: number = 40;
  @Trace static windowBottomPadding: number = 28;

  /**
   * 窗口设置
   * @param windowStage
   */
  public static async setWinConfig(windowStage: window.WindowStage) {
    AppStorage.setOrCreate('windowStage', windowStage);
    try {
      let windowClass: window.Window = windowStage.getMainWindowSync();
      await windowClass.setWindowLayoutFullScreen(true);
      WindowUtils.setAvoidArea(windowClass);
    } catch (error) {
      Logger.error(TAG, 'setWinConfig fail, error: ' + JSON.stringify(error));
    }
  }

  /**
   * 存储避让区域
   * @param windowClass
   */
  public static setAvoidArea(windowClass: window.Window) {
    try {
      const uiContext = windowClass.getUIContext();
      let type = window.AvoidAreaType.TYPE_SYSTEM;
      let avoidArea = windowClass.getWindowAvoidArea(type);
      WindowUtils.windowTopPadding = uiContext.px2vp(avoidArea.topRect.height);
      type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
      avoidArea = windowClass.getWindowAvoidArea(type);
      WindowUtils.windowBottomPadding = uiContext.px2vp(avoidArea.bottomRect.height);
    } catch (error) {
      Logger.error(TAG, 'setAvoidArea fail, error: ' + JSON.stringify(error));
    }
  }
}