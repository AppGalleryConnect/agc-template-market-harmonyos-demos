import { AppStorageV2, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { BreakpointModel } from './BreakpointModel';

const TAG = '[WindowModel]'

/**
 * 窗口持久化
 */
@ObservedV2
export class CustomWindowModel {
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace windowTopPadding: Length | undefined = undefined;
  @Trace windowBottomPadding: Length | undefined = undefined;
  @Trace windowLeftPadding: Length | undefined = undefined;
  @Trace windowRightPadding: Length | undefined = undefined;
  @Trace avoidBottomPadding: Length = 0;
  private context: Context | undefined;
  private uiContext: UIContext | undefined;

  /**
   * 获取页面左边距
   * @returns
   */
  @Computed
  get pageLeftPadding() {
    if (this.windowLeftPadding !== undefined) {
      return this.windowLeftPadding;
    }
    return GridRowColSetting.getPageMargin(this.breakPointModel.currentBreakpoint);
  }

  /**
   * 获取页面右边距
   * @returns
   */
  @Computed
  get pageRightPadding() {
    if (this.windowRightPadding !== undefined) {
      return this.windowRightPadding;
    }
    return GridRowColSetting.getPageMargin(this.breakPointModel.currentBreakpoint);
  }

  /**
   * 获取页面下边距
   * @returns
   */
  @Computed
  get pageBottomPadding() {
    if (this.windowBottomPadding !== undefined) {
      return this.windowBottomPadding;
    }
    return this.avoidBottomPadding > 0 ? 0 : 16;
  }

  /**
   * 获取底部避让区域高度
   */
  public getAvoidBottomPadding: () => void = () => {
    window.getLastWindow(this.context).then(currentWindow => {
      try {
        const area = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.avoidBottomPadding = this.uiContext!.px2vp(area.bottomRect.height);
      } catch (error) {
        Logger.error(TAG, `getWindowAvoidArea failed. error: ${JSON.stringify(error)}`)
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `getLastWindow failed. error: ${JSON.stringify(err)}`)
    })
  }

  /**
   * 监听底部避让区域变化
   */
  public onAvoidAreaChange() {
    this.getAvoidBottomPadding();
    window.getLastWindow(this.context).then(currentWindow => {
      try {
        currentWindow.on('avoidAreaChange', this.getAvoidBottomPadding);
      } catch (e) {
        Logger.error(TAG, 'Fail to on avoidAreaChange, error: ' + JSON.stringify(e));
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `registerWindowBottomPadding failed. error: ${JSON.stringify(err)}`)
    })
  }

  /**
   * 取消监听底部避让区域变化
   */
  public offAvoidAreaChange() {
    window.getLastWindow(this.context).then(currentWindow => {
      try {
        currentWindow.off('avoidAreaChange', this.getAvoidBottomPadding);
      } catch (e) {
        Logger.error(TAG, 'Fail to off avoidAreaChange, error: ' + JSON.stringify(e));
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `unRegisterWindowBottomPadding failed. error: ${JSON.stringify(err)}`)
    })
  }


  /**
   * 初始化context
   */
  public init(uiContext: UIContext) {
    this.uiContext = uiContext;
    this.context = this.uiContext.getHostContext();
  }
}