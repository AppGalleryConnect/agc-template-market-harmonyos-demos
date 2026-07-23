import { window, AppStorageV2 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonUtil } from './CommonUtil';

const TAG = '[WindowUtil]';

@ObservedV2
export class AvoidAreaSize {
  @Trace top: number = 0;
  @Trace bottom: number = 0;
}

export class WindowUtil {
  private static _init: boolean = false;
  private static _currentWindow: window.Window | null = null;
  private static _avoidAreaSize: AvoidAreaSize = AppStorageV2.connect(AvoidAreaSize, () => new AvoidAreaSize())!;

  public static async initWindowUtil() {
    if (WindowUtil._init) {
      return;
    }
    await WindowUtil._getCurrentWindow();
    WindowUtil.addWindowAvoidAreaListener();
    WindowUtil._init = true;
  }

  public static addWindowAvoidAreaListener() {
    let uiContext: UIContext = AppStorage.get('theme_uiContext') as UIContext
    if (WindowUtil._currentWindow) {
      try {
        const systemArea = WindowUtil._currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        WindowUtil._avoidAreaSize.top = uiContext.px2vp(systemArea.topRect.height);
        const bottomArea = WindowUtil._currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        WindowUtil._avoidAreaSize.bottom = uiContext.px2vp(bottomArea.bottomRect.height);
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        CommonUtil.error(TAG, `Failed to get window avoid area. Code: ${err.code}, message: ${err.message}`);
      }
    }
  }

  public static getAvoidArea() {
    return WindowUtil._avoidAreaSize;
  }

  private static async _getCurrentWindow() {
    let uiContext: UIContext = AppStorage.get('theme_uiContext') as UIContext
    await window
      .getLastWindow(uiContext.getHostContext())
      .then((win) => {
        WindowUtil._currentWindow = win;
      })
      .catch((error: BusinessError) => {
        WindowUtil._dealAllError(error);
      });
  }

  private static _dealAllError(error: BusinessError): void {
    CommonUtil.error(TAG, `Failed to use WindowUtil, errorCode: ${error.code}, errorMsg: ${error.message}`);
  }
}
