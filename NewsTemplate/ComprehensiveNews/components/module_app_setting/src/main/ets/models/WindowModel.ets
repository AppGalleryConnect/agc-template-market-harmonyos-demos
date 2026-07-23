import { AppStorageV2, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { ContextUtils } from '../common/ContextUtils';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { Logger } from '../common/Logger';
import { BreakpointModel } from './BreakpointModel';

const TAG = '[CustomWindowModel]';

/**
 * 窗口持久化
 */
@ObservedV2
export class CustomWindowModel {
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace avoidTopPadding: Length = 0;
  @Trace avoidBottomPadding: Length = 0;

  /**
   * 获取页面左边距
   * @returns
   */
  @Computed
  get pageLeftPadding() {
    return GridRowColSetting.getPageMargin(this.breakPointModel.currentBreakpoint);
  }

  /**
   * 获取页面右边距
   * @returns
   */
  @Computed
  get pageRightPadding() {
    return GridRowColSetting.getPageMargin(this.breakPointModel.currentBreakpoint);
  }

  /**
   * 获取页面上边距
   * @returns
   */
  @Computed
  get pageTopPadding() {
    return this.avoidTopPadding > 0 ? this.avoidTopPadding : 16;
  }

  /**
   * 获取页面下边距
   * @returns
   */
  @Computed
  get pageBottomPadding() {
    return this.avoidBottomPadding > 0 ? this.avoidBottomPadding : 16;
  }

  /**
   * 获取顶部、底部避让区域高度
   */
  public getAvoidPadding: () => void = () => {
    try {
      window.getLastWindow(ContextUtils.globalContext).then(currentWindow => {
        const indicator = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.avoidBottomPadding = ContextUtils.globalUIContext?.px2vp(indicator.bottomRect.height) ?? 0;

        const system = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        this.avoidTopPadding = ContextUtils.globalUIContext?.px2vp(system.topRect.height) ?? 0;
      }).catch((e: BusinessError) => {
        Logger.error(TAG, 'getLastWindow fail, error: ' + JSON.stringify(e));
      });
    } catch (e) {
      Logger.error(TAG, 'getAvoidPadding fail, error: ' + JSON.stringify(e));
    }
  }

  /**
   * 监听底部避让区域变化
   */
  public onAvoidAreaChange() {
    this.getAvoidPadding();
    window.getLastWindow(ContextUtils.globalContext).then(currentWindow => {
      try {
        currentWindow.on('avoidAreaChange', this.getAvoidPadding);
      } catch (e) {
        Logger.error(TAG, 'on currentWindow fail, error: ' + JSON.stringify(e));
      }
    }).catch((e: BusinessError) => {
      Logger.error(TAG, 'getLastWindow fail, error: ' + JSON.stringify(e));
    });
  }

  /**
   * 取消监听底部避让区域变化
   */
  public offAvoidAreaChange() {
    window.getLastWindow(ContextUtils.globalContext).then(currentWindow => {
      try {
        currentWindow.off('avoidAreaChange', this.getAvoidPadding);
      } catch (e) {
        Logger.error(TAG, `Failed to off curren window. Code is ${e.code}, message is ${e.message}`);
      }
    }).catch((e: BusinessError) => {
      Logger.error(TAG, 'getLastWindow fail, error: ' + JSON.stringify(e));
    });
  }
}