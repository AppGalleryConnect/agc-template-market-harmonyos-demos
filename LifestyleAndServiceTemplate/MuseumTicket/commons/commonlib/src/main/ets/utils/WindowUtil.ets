import { AppStorageV2, display, UIContext, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
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

  private static _context: Context;

  public static get context() {
    return WindowUtil._context;
  }

  private static _uiContext: UIContext;

  public static get uiContext() {
    return WindowUtil._uiContext;
  }

  public static updateDisplay() {
    WindowUtil._display = display.getDefaultDisplaySync();
  }

  public static async initWindowUtil() {
    await WindowUtil.getCurrentWindow();
    WindowUtil.getWindowAvoidArea();
    WindowUtil.updateDisplay();
    WindowUtil.getContext();
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

  public static getContext() {
    if (WindowUtil._currentWindow) {
      WindowUtil._context = getContext();
      WindowUtil._uiContext = WindowUtil._currentWindow.getUIContext();
    }
  }

  public static getWindowAvoidArea() {
    if (WindowUtil._currentWindow) {
      const systemArea = WindowUtil._currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      WindowUtil._avoidAreaSize.top = px2vp(systemArea.topRect.height);
      const bottomArea = WindowUtil._currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      WindowUtil._avoidAreaSize.bottom = px2vp(bottomArea.bottomRect.height);
    }
  }

  private static async getCurrentWindow() {
    await window
      .getLastWindow(getContext())
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





