import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0xFF00;
const TAG: string = 'CollectPersonalInfo';

@ObservedV2
export class WindowModel {
  @Trace windowBottomPadding: number = 0;
  /**
   * 获取底部避让区域高度
   */
  public getWindowBottomPadding: () => void = () => {
    try {
      window.getLastWindow(getContext()).then(currentWindow => {
        const area = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.windowBottomPadding = px2vp(area.bottomRect.height);
      })
    } catch (error) {
      hilog.error(DOMAIN, TAG, '%{public}s', JSON.stringify(error))
    }

  }

  /**
   * 监听底部避让区域变化
   */
  public registerWindowBottomPadding() {
    this.getWindowBottomPadding();
    try {
      window.getLastWindow(getContext()).then(currentWindow => {
        currentWindow.on('avoidAreaChange', this.getWindowBottomPadding);
      })
    } catch (error) {
      hilog.error(DOMAIN, TAG, '%{public}s', JSON.stringify(error))
    }
  }

  /**
   * 取消监听底部避让区域变化
   */
  public unRegisterWindowBottomPadding() {
    try {
      window.getLastWindow(getContext()).then(currentWindow => {
        currentWindow.off('avoidAreaChange', this.getWindowBottomPadding);
      })
    } catch (error) {
      hilog.error(DOMAIN, TAG, '%{public}s', JSON.stringify(error))
    }
  }

  /**
   * 注册监听键盘区域变化
   */
  public registerKeyboardListener(callback: Callback<number>) {
    try {
      window.getLastWindow(getContext()).then(currentWindow => {
        const keyboardH = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_KEYBOARD).bottomRect.height;
        callback(keyboardH);
        currentWindow.on('keyboardHeightChange', callback);
      })
    } catch (error) {
      hilog.error(DOMAIN, TAG, '%{public}s', JSON.stringify(error))
    }

  }

  /**
   * 取消注册监听键盘区域变化
   */
  public unRegisterKeyboardListener(callback: Callback<number>) {
    try {
      window.getLastWindow(getContext()).then(currentWindow => {
        currentWindow.off('keyboardHeightChange', callback);
      })
    } catch (error) {
      hilog.error(DOMAIN, TAG, '%{public}s', JSON.stringify(error))
    }
  }
}
