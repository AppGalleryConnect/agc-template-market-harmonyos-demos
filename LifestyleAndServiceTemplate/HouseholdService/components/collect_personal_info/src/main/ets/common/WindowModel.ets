import { UtilLog } from '@hw-agconnect/util-log';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = '[CollectPersonalInfo]'

@ObservedV2
export class WindowModel {
  @Trace windowBottomPadding: number = 0;
  private static _context: Context | undefined;
  private static _uiContext: UIContext;

  public static async initWindowModel(uiContext: UIContext) {
    if (WindowModel._uiContext) {
      return;
    }
    WindowModel._uiContext = uiContext;
    WindowModel._context = WindowModel._uiContext.getHostContext();
  }

  private async _getLastWindow() {
    return window.getLastWindow(WindowModel._context).then((win) => {
      return win
    }).catch((err: BusinessError) => {
      UtilLog.error(TAG, 'get last window failed. error: ' + JSON.stringify(err))
      return undefined;
    })
  }

  /**
   * 获取底部避让区域高度
   */
  public getWindowBottomPadding: () => void = () => {
    this._getLastWindow().then(currentWindow => {
      if (!currentWindow) {
        return;
      }
      try {
        const area = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.windowBottomPadding = WindowModel._uiContext.px2vp(area.bottomRect.height);
      } catch (error) {
        UtilLog.error(TAG, 'get window avoid area failed. error: ' + JSON.stringify(error));
      }
    })
  }

  /**
   * 监听底部避让区域变化
   */
  public registerWindowBottomPadding() {
    this.getWindowBottomPadding();
    this._getLastWindow().then(currentWindow => {
      if (!currentWindow) {
        return;
      }
      currentWindow.on('avoidAreaChange', this.getWindowBottomPadding);
    })
  }

  /**
   * 取消监听底部避让区域变化
   */
  public unRegisterWindowBottomPadding() {
    this._getLastWindow().then(currentWindow => {
      if (!currentWindow) {
        return;
      }
      currentWindow.off('avoidAreaChange', this.getWindowBottomPadding);
    })
  }

  /**
   * 注册监听键盘区域变化
   */
  public registerKeyboardListener(callback: Callback<number>) {
    this._getLastWindow().then(currentWindow => {
      if (!currentWindow) {
        return;
      }
      try {
        const keyboardH = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_KEYBOARD).bottomRect.height;
        callback(keyboardH);
        currentWindow.on('keyboardHeightChange', callback);
      } catch (error) {
        UtilLog.error(TAG, 'get window avoid area failed. error: ' + JSON.stringify(error));
      }
    })
  }

  /**
   * 取消注册监听键盘区域变化
   */
  public unRegisterKeyboardListener(callback: Callback<number>) {
    this._getLastWindow().then(currentWindow => {
      if (!currentWindow) {
        return;
      }
      currentWindow.off('keyboardHeightChange', callback);
    })
  }
}
