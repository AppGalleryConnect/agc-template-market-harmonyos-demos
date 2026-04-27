import { BreakpointNameEnum, GridRowColSetting } from '../constant/GridRowColSetting';

/**
 * 栅格断点
 */
@ObservedV2
export class BreakpointModel {
  // 当前屏幕宽度
  @Trace currentDisplayWidth: number = 0;
  // 弹框宽度
  @Trace dialogWidth: number = 0;
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