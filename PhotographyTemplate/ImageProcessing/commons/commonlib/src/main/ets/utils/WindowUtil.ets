import { AppStorageV2, display, window } from '@kit.ArkUI';
import { WindowSize as WindowInfo } from '../models/WindowSize';
import { Logger } from './Logger';

const TAG = '[WindowUtil]';

/**
 * 窗口工具类
 */
export class WindowUtil {
  /**
   * 窗口设置
   * @param windowStage
   */
  public static async setWinConfig(windowStage: window.WindowStage) {
    AppStorage.setOrCreate('windowStage', windowStage);
    try {
      let windowClass: window.Window = windowStage.getMainWindowSync();
      WindowUtil.setAvoidArea(windowClass);
      WindowUtil.onAvoidAreaChange(windowStage);
      WindowUtil.setWindowSize(windowStage);
      WindowUtil.onWindowSizeChange(windowStage);
      WindowUtil.onWindowStatusChange(windowClass);
    } catch (error) {
      Logger.error(TAG, 'setWinConfig fail, error: ' + JSON.stringify(error));
    }
  }

  /**
   * 存储避让区域
   * @param windowClass
   */
  public static setAvoidArea(windowClass: window.Window) {
    let windowModel: WindowInfo = AppStorageV2.connect(WindowInfo, () => new WindowInfo())!;
    try {
      const uiContext = windowClass.getUIContext();
      let type = window.AvoidAreaType.TYPE_SYSTEM;
      let avoidArea = windowClass.getWindowAvoidArea(type);
      windowModel.statusHeight = uiContext.px2vp(avoidArea.topRect.height);
      type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
      avoidArea = windowClass.getWindowAvoidArea(type);
      windowModel.bottomHeight = uiContext.px2vp(avoidArea.bottomRect.height);
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
      let windowModel: WindowInfo = AppStorageV2.connect(WindowInfo, () => new WindowInfo())!;
      let windowClass: window.Window = windowStage.getMainWindowSync();
      windowModel.screenWidth = windowClass.getWindowProperties().windowRect.width;
      windowModel.screenHeight = windowClass.getWindowProperties().windowRect.height;
    } catch (error) {
      Logger.error(TAG, 'setWindowSize fail, error: ' + JSON.stringify(error));
    }
  }

  /**
   * 监听窗口尺寸变化
   * @param windowStage
   */
  public static onWindowSizeChange(windowStage: window.WindowStage) {
    try {
      let windowModel: WindowInfo = AppStorageV2.connect(WindowInfo, () => new WindowInfo())!;
      let windowClass: window.Window = windowStage.getMainWindowSync();
      windowClass.on('windowSizeChange', (data) => {
        windowModel.screenWidth = data.width;
        windowModel.screenHeight = data.height;
      });
    } catch (e) {
      Logger.error(TAG, 'Failed to onWindowSizeChange. Cause: ' + JSON.stringify(e));
    }
  }

  /**
   * 取消监听窗口尺寸变化
   * @param windowStage
   */
  public static offWindowSizeChange() {
    try {
      let windowStage = AppStorage.get('windowStage') as window.WindowStage;
      if (windowStage) {
        windowStage.getMainWindowSync().off('windowSizeChange');
      }
    } catch (e) {
      Logger.error(TAG, 'Failed to offWindowSizeChange. Cause: ' + JSON.stringify(e));
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
        WindowUtil.setAvoidArea(windowClass);
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

  /**
   * 监听窗口模式变化
   * @param windowStage
   */
  public static onWindowStatusChange(windowClass: window.Window) {
    try {
      windowClass.on('windowStatusChange', (windowStatusType) => {
        let windowModel: WindowInfo = AppStorageV2.connect(WindowInfo, () => new WindowInfo())!
        windowModel.windowStatusType = windowStatusType;
      });
    } catch (e) {
      Logger.error(TAG, 'Failed to onWindowStatusChange. Cause: ' + JSON.stringify(e));
    }
  }

  /**
   * 取消监听窗口模式变化
   */
  public static offWindowStatusChange() {
    try {
      let windowStage = AppStorage.get('windowStage') as window.WindowStage;
      if (windowStage) {
        windowStage.getMainWindowSync().off('windowStatusChange');
      }
    } catch (e) {
      Logger.error(TAG, 'Failed to offWindowStatusChange. Cause: ' + JSON.stringify(e));
    }
  }

  /**
   * 设置窗口是否全屏
   */
  public static async setWindowScreen(isFull: boolean) {
    try {
      let windowStage = AppStorage.get('windowStage') as window.WindowStage;
      if (windowStage) {
        const win = windowStage.getMainWindowSync();
        win.setWindowLayoutFullScreen(isFull).catch((err: BusinessError) => {
          Logger.error(TAG, 'set window layout failed. error: ' + JSON.stringify(err));
        });
      }
    } catch (e) {
      Logger.error(TAG, 'Failed to setWindowScreen. Cause: ' + JSON.stringify(e));
    }
  }

  /**
   * 屏蔽侧滑返回事件
   */
  public static async setGestureBackEnabled(disabled: boolean) {
    try {
      let windowStage = AppStorage.get('windowStage') as window.WindowStage;
      if (windowStage) {
        const win = windowStage.getMainWindowSync();
        win.setGestureBackEnabled(disabled).catch((err: BusinessError) => {
          Logger.error(TAG, 'set window layout failed. error: ' + JSON.stringify(err));
        });
      }
    } catch (e) {
      Logger.error(TAG, 'Failed to setWindowScreen. Cause: ' + JSON.stringify(e));
    }
  }

  public static getMaxDisplaySize(ratio: number): Size {
    let defaultDisplay: display.Display | null = null;
    try {
      defaultDisplay = display.getDefaultDisplaySync();
    } catch (exception) {
      Logger.error(TAG, `getDefaultDisplaySync failed, code is ${exception.code}, message is ${exception.message}`);
    }
    const windowWidth: number = defaultDisplay?.width ?? 0;
    const windowHeight: number = defaultDisplay?.height ?? 0;
    const rotation = (defaultDisplay?.rotation ?? 0) * 90;
    if (rotation === 90 || rotation === 270) {
      ratio = 1 / ratio;
    }
    const calculatedHeight = windowWidth * ratio;
    if (calculatedHeight <= windowHeight) {
      return {
        width: windowWidth,
        height: calculatedHeight
      };
    } else {
      return {
        width: windowHeight / ratio,
        height: windowHeight
      };
    }
  }
}