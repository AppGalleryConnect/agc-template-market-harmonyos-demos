import { AppStorageV2, display, UIContext, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { contextUtil } from './ContextUtil';
import { Logger } from './Logger';

const TAG = 'WindowUtil';

@ObservedV2
export class AvoidAreaSize {
  @Trace top: number = 0;
  @Trace bottom: number = 0;
}

@ObservedV2
export class WindowUtil {
  private static _avoidAreaSize: AvoidAreaSize = AppStorageV2.connect(AvoidAreaSize, () => new AvoidAreaSize())!;

  public static get avoidAreaSize() {
    return WindowUtil._avoidAreaSize;
  }

  private static _currentWindow: window.Window;

  public static get currentWindow() {
    return WindowUtil._currentWindow;
  }

  private static _display: display.Display;

  public static get display() {
    return WindowUtil._display;
  }

  public static updateDisplay() {
    WindowUtil._display = display.getDefaultDisplaySync();
  }

  public static async initWindowUtil() {
    await WindowUtil.getCurrentWindow();
    WindowUtil.getWindowAvoidArea();
    WindowUtil.updateDisplay();
  }

  public static setFullWindow(isFull: boolean = true) {
    if (WindowUtil._currentWindow) {
      WindowUtil._currentWindow
        .setWindowLayoutFullScreen(isFull)
        .then(() => {
          Logger.info(TAG, 'set full window success');
        })
        .catch((error: BusinessError) => {
          WindowUtil.dealAllError(error);
        });
    }
  }

  public static getWindowAvoidArea() {
    if (WindowUtil._currentWindow) {
      const systemArea = WindowUtil._currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      WindowUtil._avoidAreaSize.top = contextUtil.getUiContext()?.px2vp(systemArea.topRect.height) ?? 0
      const bottomArea = WindowUtil._currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      WindowUtil._avoidAreaSize.bottom = contextUtil.getUiContext()?.px2vp(bottomArea.bottomRect.height) ?? 0
    }
  }

  private static async getCurrentWindow() {
    await window
      .getLastWindow(contextUtil.getContext())
      .then((win) => {
        WindowUtil._currentWindow = win;
      })
      .catch((error: BusinessError) => {
        WindowUtil.dealAllError(error);
      });
  }

  private static dealAllError(error: BusinessError): void {
    Logger.error(TAG, `Failed to use WindowUtil, errorCode: ${error.code}, errorMsg: ${error.message}`);
  }
}





