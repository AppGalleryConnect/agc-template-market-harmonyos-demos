import { window } from '@kit.ArkUI';
import { Logger } from './Logger';


@ObservedV2
export class WindowUtil {
  private static _currentWindow: window.Window;

  // 获取窗口Rect
  public static getWindowRect() {
    const windowProperties: window.WindowProperties | undefined = WindowUtil._currentWindow.getWindowProperties();
    return windowProperties?.windowRect;
  }


  // 监听窗口大小变化
  static onWindowSizeChange(callback: Callback<Size>) {
    const windowCur = WindowUtil._currentWindow;
    if (!windowCur) {
      return;
    }
    try {
      windowCur.on('windowSizeChange', callback);
    } catch (e) {
      Logger.error('WindowUtil on windowSizeChange fail, error: ' + JSON.stringify(e));
    }
  }


  // 取消监听窗口大小变化
  static offWindowSizeChange(callback: Callback<Size>) {
    const windowCur = WindowUtil._currentWindow;
    if (!windowCur) {
      return;
    }
    try {
      windowCur.off('windowSizeChange', callback);
    } catch (e) {
      Logger.error('WindowUtil off windowSizeChange fail, error: ' + JSON.stringify(e));
    }
  }

  public static async getCurrentWindow() {
    try {
      WindowUtil._currentWindow = await window.getLastWindow(getContext());
    } catch (e) {
      Logger.error('WindowUtil getLastWindow fail, error: ' + JSON.stringify(e));
    }
  }
}





