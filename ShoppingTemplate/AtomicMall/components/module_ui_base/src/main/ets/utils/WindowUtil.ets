import { UIContext, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG: string = '[UIBase][WindowUtil]';

export class WindowUtil {
  private static _context: Context | undefined;

  public static get context(): Context | undefined {
    return WindowUtil._context;
  }

  private static _uiContext: UIContext;

  public static get uiContext(): UIContext {
    return WindowUtil._uiContext;
  }

  public static async initWindowUtil(uiContext: UIContext) {
    if (WindowUtil._uiContext) {
      return;
    }
    WindowUtil._uiContext = uiContext;
    WindowUtil._context = WindowUtil._uiContext.getHostContext();
  }

  public static toast(message: string) {
    ToastDialog.showToast({ message });
  }

  public static px2vp(value: number) {
    if (!WindowUtil._uiContext) {
      UtilLog.error(TAG, 'px2vp failed. cannot get ui context.');
      return 0;
    }
    return WindowUtil._uiContext.px2vp(value);
  }

  private static async _getLastWindow() {
    return window.getLastWindow(WindowUtil.context).then((win) => {
      return win;
    }).catch((err: BusinessError) => {
      UtilLog.error(TAG, 'get last window failed. error: ' + JSON.stringify(err));
      return undefined;
    });
  }

  /**
   * 获取底部避让区域高度
   */
  public static async getWindowBottomPadding(): Promise<number> {
    try {
      const currentWindow = await WindowUtil._getLastWindow();
      if (!currentWindow) {
        return 0;
      }
      const area = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      return WindowUtil.px2vp(area.bottomRect.height);
    } catch (err) {
      UtilLog.error(TAG, 'get window avoid area failed. error: ' + JSON.stringify(err));
    }
    return 0;
  }

  /**
   * 监听底部避让区域变化
   */
  public static registerWindowBottomPadding() {
    WindowUtil.getWindowBottomPadding();
    WindowUtil._getLastWindow().then(currentWindow => {
      if (!currentWindow) {
        return;
      }
      currentWindow.on('avoidAreaChange', WindowUtil.getWindowBottomPadding);
    });
  }

  /**
   * 取消监听底部避让区域变化
   */
  public static unRegisterWindowBottomPadding() {
    WindowUtil._getLastWindow().then(currentWindow => {
      if (!currentWindow) {
        return;
      }
      currentWindow.off('avoidAreaChange', WindowUtil.getWindowBottomPadding);
    });
  }

  /**
   * 注册监听键盘区域变化
   */
  public static registerKeyboardListener(callback: Callback<number>) {
    WindowUtil._getLastWindow().then(currentWindow => {
      if (!currentWindow) {
        return;
      }
      try {
        const keyboardH = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_KEYBOARD).bottomRect.height;
        callback(keyboardH);
        currentWindow.on('keyboardHeightChange', callback);
      } catch (err) {
        UtilLog.error(TAG, 'get window avoid area failed. error: ' + JSON.stringify(err));
      }
    });
  }

  /**
   * 取消注册监听键盘区域变化
   */
  public static unRegisterKeyboardListener(callback: Callback<number>) {
    WindowUtil._getLastWindow().then(currentWindow => {
      if (!currentWindow) {
        return;
      }
      currentWindow.off('keyboardHeightChange', callback);
    });
  }
}
