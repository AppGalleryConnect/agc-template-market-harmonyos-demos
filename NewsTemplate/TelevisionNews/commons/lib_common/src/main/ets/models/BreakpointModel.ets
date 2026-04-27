import { BreakpointNameEnum, GridRowColSetting } from '../constants/GridRowColSetting';

/**
 * 栅格断点
 */
@ObservedV2
export class BreakpointModel {
  @Trace currentBreakpoint: BreakpointNameEnum = BreakpointNameEnum.SM;

  /**
   * 根据当前断点，获取页面边距
   * @returns
   */
  @Computed
  get pagePadding() {
    return GridRowColSetting.getPageMargin(this.currentBreakpoint);
  }
}