import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { CommonConstants } from '../common/Constants';

const TAG = '[ShareConfigModel]';

@ObservedV2
export class ShareConfigModel {
  @Trace sheetType: SheetType = SheetType.BOTTOM;
  @Trace windowBottomPadding: number = 0;
  @Trace isLayoutFullScreen: boolean = false;
  @Trace uiContext: UIContext | undefined = undefined;

  @Computed
  get bottomPadding() {
    if (this.sheetType === SheetType.BOTTOM) {
      return this.windowBottomPadding;
    }
    return CommonConstants.PADDING_L;
  }

  /**
   * 主动获取底部避让区域高度
   */
  public queryWindowBottomPadding: () => void = () => {
    try {
      window.getLastWindow(this.uiContext?.getHostContext()).then(currentWindow => {
        const area = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.windowBottomPadding = this.uiContext?.px2vp(area.bottomRect.height) ?? 0;
      }).catch((e: BusinessError) => {
        UtilLog.error(TAG, 'getLastWindow fail, error: ' + JSON.stringify(e));
      });
    } catch (e) {
      UtilLog.error(TAG, 'getWindowAvoidArea fail, error: ' + JSON.stringify(e));
    }
  };
  /**
   * 监听avoidAreaChange的回调函数
   * @param options
   */
  private setWindowBottomPadding: (options: window.AvoidAreaOptions) => void = (options: window.AvoidAreaOptions) => {
    if (options.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
      this.windowBottomPadding = this.uiContext?.px2vp(options.area.bottomRect.height) ?? 0;
    }
  };

  /**
   * 监听底部避让区域变化
   */
  public registerWindowBottomPadding(uiContext: UIContext) {
    this.uiContext = uiContext;
    this.queryWindowBottomPadding();
    window.getLastWindow(uiContext.getHostContext()).then(currentWindow => {
      try {
        currentWindow.on('avoidAreaChange', this.setWindowBottomPadding);
      } catch (err) {
        UtilLog.error(TAG, 'fail to register avoid area change. error:' + JSON.stringify(err));
      }
    }).catch((e: BusinessError) => {
      UtilLog.error(TAG, 'getLastWindow fail, error: ' + JSON.stringify(e));
    });
  }

  /**
   * 取消监听底部避让区域变化
   */
  public unRegisterWindowBottomPadding(uiContext: UIContext) {
    this.uiContext = uiContext;
    try {
      window.getLastWindow(uiContext.getHostContext()).then(currentWindow => {
        currentWindow.off('avoidAreaChange', this.setWindowBottomPadding);
      }).catch((e: BusinessError) => {
        UtilLog.error(TAG, 'getLastWindow fail, error: ' + JSON.stringify(e));
      });
    } catch (e) {
      UtilLog.error(TAG, 'unRegisterWindowBottomPadding fail, error: ' + JSON.stringify(e));
    }
  }

  /**
   * 还原应用窗口模式
   */
  public restoreWindowLayout(uiContext: UIContext | undefined) {
    if (!uiContext) {
      return;
    }
    window.getLastWindow(uiContext.getHostContext()).then(currentWindow => {
      currentWindow.setWindowLayoutFullScreen(this.isLayoutFullScreen).catch((e: BusinessError) => {
        UtilLog.error(TAG, 'setWindowLayoutFullScreen fail, error: ' + JSON.stringify(e));
      });
    }).catch((e: BusinessError) => {
      UtilLog.error(TAG, 'getLastWindow fail, error: ' + JSON.stringify(e));
    });
  }
}
