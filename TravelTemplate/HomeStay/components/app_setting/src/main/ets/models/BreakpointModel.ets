import { BreakpointNameEnum } from '../common/GridRowColSetting';

/**
 * 栅格断点
 */
@ObservedV2
export class BreakpointModel {
  @Trace currentBreakpoint: BreakpointNameEnum | string = BreakpointNameEnum.SM;
}