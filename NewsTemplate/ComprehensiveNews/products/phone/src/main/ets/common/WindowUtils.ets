import { AppStorageV2, window } from '@kit.ArkUI';
import { Logger, WindowModel } from 'lib_common';

const TAG = '[WindowUtils]';

/**
 * 窗口工具类
 */
export class WindowUtils {
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
      WindowUtils.onAvoidAreaChange(windowStage);
      WindowUtils.setWindowSize(windowStage);
    } catch (error) {
      Logger.error(TAG, 'setWinConfig fail, error: ' + JSON.stringify(error));
    }
  }

  /**
   * 存储避让区域
   * @param windowClass
   */
  public static setAvoidArea(windowClass: window.Window) {
    let windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
    try {
      const uiContext = windowClass.getUIContext();
      let type = window.AvoidAreaType.TYPE_SYSTEM;
      let avoidArea = windowClass.getWindowAvoidArea(type);
      windowModel.windowTopPadding = uiContext.px2vp(avoidArea.topRect.height);
      type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
      avoidArea = windowClass.getWindowAvoidArea(type);
      windowModel.windowBottomPadding = uiContext.px2vp(avoidArea.bottomRect.height);
    } catch (error) {
      Logger.error(TAG, 'setAvoidArea fail, error: ' + JSON.stringify(error));
    }
  }

  /**
   * 存储窗口大小
   * @param windowStage
   */
  public static setWindowSize(windowStage: window.WindowStage) {
    try {
      let windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
      let windowClass: window.Window = windowStage.getMainWindowSync();
      windowModel.windowWidth = windowClass.getWindowProperties().windowRect.width;
      windowModel.windowHeight = windowClass.getWindowProperties().windowRect.height;
    } catch (error) {
      Logger.error(TAG, 'setWindowSize fail, error: ' + JSON.stringify(error));
    }
  }

  /**
   * 窗口避让区域变化监听
   * @param windowStage
   */
  public static onAvoidAreaChange(windowStage: window.WindowStage) {
    try {
      let windowClass: window.Window = windowStage.getMainWindowSync();
      windowClass.on('avoidAreaChange', () => {
        WindowUtils.setAvoidArea(windowClass);
      });
    } catch (e) {
      Logger.error(TAG, 'Failed to onAvoidAreaChange. Cause: ' + JSON.stringify(e));
    }
  }

  /**
   * 取消窗口避让区域变化监听
   */
  public static offAvoidAreaChange() {
    try {
      let windowStage = AppStorage.get('windowStage') as window.WindowStage;
      if (windowStage) {
        windowStage.getMainWindowSync().off('avoidAreaChange');
      }
    } catch (e) {
      Logger.error(TAG, 'Failed to offAvoidAreaChange. Cause: ' + JSON.stringify(e));
    }
  }
}