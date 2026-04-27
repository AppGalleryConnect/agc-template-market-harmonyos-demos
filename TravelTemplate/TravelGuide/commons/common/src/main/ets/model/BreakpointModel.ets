import { BreakpointNameEnum, GridRowColSetting } from '../constant/GridRowColSetting';

/**
 * 栅格断点
 */
@ObservedV2
export class BreakpointModel {
  // 当前屏幕宽度
  @Trace currentDisplayWidth: number = 0;
  // 当前屏幕高度
  @Trace currentDisplayHeight: number = 0;
  @Trace currentBreakpoint: BreakpointNameEnum = BreakpointNameEnum.SM;

  /**
   * 根据当前断点，获取页面边距
   * @returns
   */
  @Computed
  get pagePadding() {
    return GridRowColSetting.getPageMargin(this.currentBreakpoint);
  }

  /**
   * 示例：根据栅格化动态获取列表数量
   * @returns
   */
  @Computed
  get getColumnCount() {
    return GridRowColSetting.getColumnCount();
  }
}