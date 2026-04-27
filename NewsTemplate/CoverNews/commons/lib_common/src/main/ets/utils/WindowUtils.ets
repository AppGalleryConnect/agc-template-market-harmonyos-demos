import { AppStorageV2, window } from '@kit.ArkUI';
import { WindowModel } from '../models/WindowModel';
import { Logger } from './Logger';

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
      const windowClass: window.Window = windowStage.getMainWindowSync();
      WindowUtils.setAvoidArea(windowClass);
      WindowUtils.onAvoidAreaChange(windowStage);
    } catch (error) {
      Logger.error(TAG, 'setWinConfig fail, error: ' + JSON.stringify(error));
    }
  }

  /**
   * 设置避让区域
   * @param windowClass
   */
  public static setAvoidArea(windowClass: window.Window) {
    const windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
    try {
      const uiContext = windowClass.getUIContext();
      let type = window.AvoidAreaType.TYPE_SYSTEM;
      let avoidArea = windowClass.getWindowAvoidArea(type);
      windowModel.setWindowTopPadding(uiContext.px2vp(avoidArea.topRect.height));

      type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
      avoidArea = windowClass.getWindowAvoidArea(type);
      windowModel.setWindowBottomPadding(uiContext.px2vp(avoidArea.bottomRect.height));
    } catch (error) {
      Logger.error(TAG, 'setAvoidArea fail, error: ' + JSON.stringify(error));
    }
  }

  /**
   * 窗口避让区域变化监听
   * @param windowStage
   */
  public static onAvoidAreaChange(windowStage: window.WindowStage) {
    try {
      const windowClass: window.Window = windowStage.getMainWindowSync();
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
      const windowStage = AppStorage.get('windowStage') as window.WindowStage;
      if (windowStage) {
        windowStage.getMainWindowSync().off('avoidAreaChange');
      }
    } catch (e) {
      Logger.error(TAG, 'Failed to offAvoidAreaChange. Cause: ' + JSON.stringify(e));
    }
  }
}