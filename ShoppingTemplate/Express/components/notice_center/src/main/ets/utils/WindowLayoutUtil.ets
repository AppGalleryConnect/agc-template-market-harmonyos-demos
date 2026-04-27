import { window } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';


@ObservedV2
export class WindowLayoutUtil {
  @Trace isAvoidArea: boolean = false;
  @Trace windowTopPadding: number = 40;
  @Trace windowBottomPadding: number = 28;
  private static _instance: WindowLayoutUtil;

  public static get instance() {
    if (!WindowLayoutUtil._instance) {
      WindowLayoutUtil._instance = new WindowLayoutUtil();
    }
    return WindowLayoutUtil._instance;
  }

  setAvoidSize(uiContext: UIContext) {
    // 获取当前窗口实例
    try {
      const context = uiContext.getHostContext() as Context;
      window.getLastWindow(context).then(async (windowClass) => {
        // 判断是否为全屏布局
        const properties = windowClass.getWindowProperties();
        if (properties.isLayoutFullScreen) {
          this.isAvoidArea = true;
          let avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
          this.windowTopPadding = uiContext.px2vp(avoidArea.topRect.height);
          avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
          this.windowBottomPadding = uiContext.px2vp(avoidArea.bottomRect.height);
        } else {
          this.isAvoidArea = false;
        }
      }).catch((err: BusinessError) => {
        UtilLog.error(`Failed to obtain the top window. Error: ${JSON.stringify(err)}`);
      });
    } catch (err) {
      UtilLog.error(`Failed to obtain the top window. Error: ${JSON.stringify(err)}`);
    }
  }
}