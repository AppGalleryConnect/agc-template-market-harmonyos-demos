import { AppStorageV2, display, window } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[WindowUtil]'

// 窗口信息持久化
@ObservedV2
export class WindowModel {
  @Trace windowTopHeight: number = 38.77;
  @Trace windowBottomHeight: number = 28;
  @Trace windowStage?: window.WindowStage = undefined;
  // sheet的最大高度
  @Trace fullSheetHeight: number = 640;

  getWindowTopHeight() {
    return this.windowTopHeight || 38.77;
  }

  getWindowBottomHeight() {
    return this.windowBottomHeight || 28;
  }
}

@ObservedV2
export class WindowUtil {
  @Trace
  private static _context: Context | undefined;

  public static get context(): Context | undefined {
    return WindowUtil._context;
  }

  @Trace
  private static _uiContext: UIContext;

  public static get uiContext(): UIContext {
    return WindowUtil._uiContext;
  }

  public static init(uiContext: UIContext) {
    if (WindowUtil._uiContext) {
      return;
    }
    WindowUtil._uiContext = uiContext;
    WindowUtil._context = WindowUtil._uiContext.getHostContext();
  }

  /**
   * 存储WindowStage
   */
  public static setWindowStage(windowStage: window.WindowStage) {
    let windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
    windowModel.windowStage = windowStage;
  }

  /**
   * 存储避让区域
   */
  public static setAvoidArea(windowClass: window.Window) {
    let windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
    try {
      const uiContext = windowClass.getUIContext();
      let type = window.AvoidAreaType.TYPE_SYSTEM;
      let avoidArea = windowClass.getWindowAvoidArea(type);
      windowModel.windowTopHeight = uiContext.px2vp(avoidArea.topRect.height);
      type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
      avoidArea = windowClass.getWindowAvoidArea(type);
      windowModel.windowBottomHeight = uiContext.px2vp(avoidArea.bottomRect.height);
      const displayInfo = display.getDefaultDisplaySync();
      const displayHeight = uiContext.px2vp(displayInfo.height);
      windowModel.fullSheetHeight = displayHeight - windowModel.windowTopHeight - 56;
    } catch (error) {
      UtilLog.error(TAG, 'setAvoidArea fail, error: ' + JSON.stringify(error));
    }
  }
}
