import { AppStorageV2, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowUtil } from 'module_ui_base';
import { UtilLog } from '@hw-agconnect/util-log';
import { BreakpointModel } from './BreakpointModel';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { LOG_TAG } from '../constants/CommonConstants';

/**
 * 窗口持久化
 */
@ObservedV2
export class CustomWindowModel {
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(
    BreakpointModel,
    () => new BreakpointModel(),
  )!;
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
    return GridRowColSetting.getPageMargin(
      this.breakPointModel.currentBreakpoint,
    );
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
    return GridRowColSetting.getPageMargin(
      this.breakPointModel.currentBreakpoint,
    );
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

  public async getLastWindow() {
    return window.getLastWindow(WindowUtil.context).then((win) => {
      return win;
    }).catch((err: BusinessError) => {
      UtilLog.error(LOG_TAG, 'get last window failed. error: ' + JSON.stringify(err));
      return undefined;
    });
  }

  /**
   * 获取底部避让区域高度
   */
  public getAvoidBottomPadding: () => void = () => {
    this.getLastWindow().then((currentWindow) => {
      if (!currentWindow) {
        return;
      }
      try {
        const area = currentWindow.getWindowAvoidArea(
          window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR,
        );
        this.avoidBottomPadding = WindowUtil.px2vp(area.bottomRect.height);
      } catch (err) {
        UtilLog.error('[Setting]', 'get window avoid area failed. error: ' + JSON.stringify(err));
      }
    });
  };

  /**
   * 监听底部避让区域变化
   */
  public onAvoidAreaChange() {
    this.getAvoidBottomPadding();
    this.getLastWindow().then((currentWindow) => {
      currentWindow?.on('avoidAreaChange', this.getAvoidBottomPadding);
    });
  }

  /**
   * 取消监听底部避让区域变化
   */
  public offAvoidAreaChange() {
    this.getLastWindow().then((currentWindow) => {
      currentWindow?.off('avoidAreaChange', this.getAvoidBottomPadding);
    });
  }
}
