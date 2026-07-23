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

  /**
   * 根据当前断点，判断Tab位置
   * @returns
   */
  @Computed
  get isTabVertical() {
    return [
      BreakpointNameEnum.LG,
      BreakpointNameEnum.XL,
    ].includes(this.currentBreakpoint);
  }

  /**
   * 当前断点是是MD以上
   * @returns
   */
  @Computed
  get isMoreMD() {
    return [
      BreakpointNameEnum.MD,
      BreakpointNameEnum.LG,
      BreakpointNameEnum.XL,
    ].includes(this.currentBreakpoint);
  }

}