import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = '[WindowModel]'
const DOMAIN = 0x0000

@ObservedV2
export class WindowModel {
  @Trace windowBottomPadding: number = 0;
  private context: Context | undefined;
  private uiContext: UIContext | undefined;

  /**
   * 初始化context
   */
  public init(uiContext: UIContext) {
    this.uiContext = uiContext;
    this.context = this.uiContext.getHostContext();
  }

  /**
   * 获取底部避让区域高度
   */
  public getWindowBottomPadding: () => void = () => {
    window.getLastWindow(this.context).then(currentWindow => {
      try {
        const area = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.windowBottomPadding = this.uiContext!.px2vp(area.bottomRect.height);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `getWindowAvoidArea failed. error: ${JSON.stringify(error)}`)
      }
    }).catch((err: BusinessError) => {
      hilog.error(DOMAIN, TAG, `getLastWindow failed. error: ${JSON.stringify(err)}`)
    })
  }

  /**
   * 监听底部避让区域变化
   */
  public registerWindowBottomPadding() {
    this.getWindowBottomPadding();
    try {
      window.getLastWindow(this.context).then(currentWindow => {
        currentWindow.on('avoidAreaChange', this.getWindowBottomPadding);
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, `registerWindowBottomPadding failed. error: ${JSON.stringify(err)}`)
      })
    } catch (error) {
      console.error('WindowModel', ` registerWindowBottomPadding error = ${JSON.stringify(error)}`)
    }
  }

  /**
   * 取消监听底部避让区域变化
   */
  public unRegisterWindowBottomPadding() {
    try {
      window.getLastWindow(this.context).then(currentWindow => {
        currentWindow.off('avoidAreaChange', this.getWindowBottomPadding);
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, `unRegisterWindowBottomPadding failed. error: ${JSON.stringify(err)}`)
      })
    } catch (error) {
      console.error('WindowModel', ` getLastWindow error = ${JSON.stringify(error)}`)
    }
  }

  /**
   * 注册监听键盘区域变化
   */
  public registerKeyboardListener(callback: Callback<number>) {
    try {
      window.getLastWindow(this.context).then(currentWindow => {
        try {
          const keyboardH = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_KEYBOARD).bottomRect.height;
          callback(keyboardH);
          currentWindow.on('keyboardHeightChange', callback);
        } catch (error) {
          hilog.error(DOMAIN, TAG, `getWindowAvoidArea failed. error: ${JSON.stringify(error)}`)
        }
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, `registerKeyboardListener failed. error: ${JSON.stringify(err)}`)
      })
    } catch (error) {
      console.error('WindowModel', ` registerKeyboardListener error = ${JSON.stringify(error)}`)
    }
  }

  /**
   * 取消注册监听键盘区域变化
   */
  public unRegisterKeyboardListener(callback: Callback<number>) {
    try {
      window.getLastWindow(this.context).then(currentWindow => {
        currentWindow.off('keyboardHeightChange', callback);
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, `unRegisterKeyboardListener failed. error: ${JSON.stringify(err)}`)
      })
    } catch (error) {
      console.error('WindowModel', ` unRegisterKeyboardListener error = ${JSON.stringify(error)}`)
    }
  }
}