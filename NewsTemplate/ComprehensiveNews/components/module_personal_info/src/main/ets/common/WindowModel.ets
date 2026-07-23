import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { ContextUtils } from './ContextUtils';

const TAG = '[PersonalWindowModel]';

@ObservedV2
export class PersonalWindowModel {
  @Trace windowBottomPadding: number = 0;
  /**
   * 获取底部避让区域高度
   */
  public getWindowBottomPadding: () => void = () => {
    window.getLastWindow(ContextUtils.globalContext).then(currentWindow => {
      try {
        const area = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.windowBottomPadding = ContextUtils.globalUIContext?.px2vp(area.bottomRect.height) ?? 0;
      } catch (e) {
        UtilLog.error(TAG, 'getWindowAvoidArea fail, error: ' + JSON.stringify(e));
      }
    }).catch((e: BusinessError) => {
      UtilLog.error(TAG, 'getLastWindow fail, error: ' + JSON.stringify(e));
    });
  }

  /**
   * 监听底部避让区域变化
   */
  public registerWindowBottomPadding() {
    this.getWindowBottomPadding();
    window.getLastWindow(ContextUtils.globalContext).then(currentWindow => {
      try {
        currentWindow.on('avoidAreaChange', this.getWindowBottomPadding);
      } catch (e) {
        UtilLog.error(TAG, `Failed to on current window. Code is ${e.code}, message is ${e.message}`);
      }
    }).catch((e: BusinessError) => {
      UtilLog.error(TAG, 'getLastWindow fail, error: ' + JSON.stringify(e));
    });
  }

  /**
   * 取消监听底部避让区域变化
   */
  public unRegisterWindowBottomPadding() {
    window.getLastWindow(ContextUtils.globalContext).then(currentWindow => {
      try {
        currentWindow.off('avoidAreaChange', this.getWindowBottomPadding);
      } catch (e) {
        UtilLog.error(TAG, `Failed to off current window. Code is ${e.code}, message is ${e.message}`);
      }
    }).catch((e: BusinessError) => {
      UtilLog.error(TAG, 'getLastWindow fail, error: ' + JSON.stringify(e));
    });
  }

  /**
   * 注册监听键盘区域变化
   */
  public registerKeyboardListener(callback: Callback<number>) {
    window.getLastWindow(ContextUtils.globalContext).then(currentWindow => {
      try {
        const keyboardH = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_KEYBOARD).bottomRect.height;
        callback(keyboardH);
        currentWindow.on('keyboardHeightChange', callback);
      } catch (e) {
        UtilLog.error(TAG, 'getWindowAvoidArea fail, error: ' + JSON.stringify(e));
      }
    }).catch((e: BusinessError) => {
      UtilLog.error(TAG, 'getLastWindow fail, error: ' + JSON.stringify(e));
    });
  }

  /**
   * 取消注册监听键盘区域变化
   */
  public unRegisterKeyboardListener(callback: Callback<number>) {
    window.getLastWindow(ContextUtils.globalContext).then(currentWindow => {
      try {
        currentWindow.off('keyboardHeightChange', callback);
      } catch (e) {
        UtilLog.error(TAG, 'off currentWindow fail, error: ' + JSON.stringify(e));
      }
    }).catch((e: BusinessError) => {
      UtilLog.error(TAG, 'getLastWindow fail, error: ' + JSON.stringify(e));
    });
  }
}
