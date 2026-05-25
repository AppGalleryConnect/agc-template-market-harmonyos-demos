import { AppStorageV2, window } from '@kit.ArkUI';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { BreakpointModel } from './BreakpointModel';
import { Logger } from '../common/Logger';

const TAG = '[WindowModel]';

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
    try {
      window.getLastWindow(getContext()).then(currentWindow => {
        const area = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.avoidBottomPadding = px2vp(area.bottomRect.height);
      })
    } catch (error) {
      Logger.error(TAG, JSON.stringify(error))
    }

  }

  /**
   * 监听底部避让区域变化
   */
  public onAvoidAreaChange() {
    this.getAvoidBottomPadding();
    try {
      window.getLastWindow(getContext()).then(currentWindow => {
        currentWindow.on('avoidAreaChange', this.getAvoidBottomPadding);
      })
    }  catch (error) {
      Logger.error(TAG, JSON.stringify(error))
    }
  }

  /**
   * 取消监听底部避让区域变化
   */
  public offAvoidAreaChange() {
    try {
      window.getLastWindow(getContext()).then(currentWindow => {
        currentWindow.off('avoidAreaChange', this.getAvoidBottomPadding);
      })
    } catch (error) {
      Logger.error(TAG, JSON.stringify(error))
    }
  }
}