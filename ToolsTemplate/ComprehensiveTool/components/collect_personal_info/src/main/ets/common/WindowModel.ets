import { window } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';

@ObservedV2
export class WindowModel {
  uiContext?: UIContext
  @Trace windowBottomPadding: number = 0;
  /**
   * 获取底部避让区域高度
   */
  public getWindowBottomPadding: () => void = () => {
    try {
      window.getLastWindow(this.uiContext?.getHostContext()).then(currentWindow => {
        const area = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.windowBottomPadding = this.uiContext?.px2vp(area.bottomRect.height) ?? 0;
      })
    } catch (e) {
      UtilLog.error(`getWindowBottomPadding failed with error ${JSON.stringify(e)}`);
    }
  }

  /**
   * 监听底部避让区域变化
   */
  public registerWindowBottomPadding() {
    this.getWindowBottomPadding();
    try {
      window.getLastWindow(this.uiContext?.getHostContext()).then(currentWindow => {
        currentWindow.on('avoidAreaChange', this.getWindowBottomPadding);
      })
    } catch (e) {
      UtilLog.error(`registerWindowBottomPadding failed with error ${JSON.stringify(e)}`);
    }
  }

  /**
   * 取消监听底部避让区域变化
   */
  public unRegisterWindowBottomPadding() {
    try {
      window.getLastWindow(this.uiContext?.getHostContext()).then(currentWindow => {
        currentWindow.off('avoidAreaChange', this.getWindowBottomPadding);
      })
    } catch (e) {
      UtilLog.error(`unRegisterWindowBottomPadding failed with error ${JSON.stringify(e)}`);
    }
  }

  /**
   * 注册监听键盘区域变化
   */
  public registerKeyboardListener(callback: Callback<number>) {
    try {
      window.getLastWindow(this.uiContext?.getHostContext()).then(currentWindow => {
        const keyboardH = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_KEYBOARD).bottomRect.height;
        callback(keyboardH);
        currentWindow.on('keyboardHeightChange', callback);
      })
    } catch (e) {
      UtilLog.error(`registerKeyboardListener failed with error ${JSON.stringify(e)}`);
    }
  }

  /**
   * 取消注册监听键盘区域变化
   */
  public unRegisterKeyboardListener(callback: Callback<number>) {
    try {
      window.getLastWindow(this.uiContext?.getHostContext()).then(currentWindow => {
        currentWindow.off('keyboardHeightChange', callback);
      })
    } catch (e) {
      UtilLog.error(`unRegisterKeyboardListener failed with error ${JSON.stringify(e)}`);
    }
  }
}
