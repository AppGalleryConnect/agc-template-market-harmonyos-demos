import { BreakpointNameEnum, GridRowColSetting } from './GridRowColSetting';

@ObservedV2
export class BreakpointModel {
  @Trace currentBreakpoint: BreakpointNameEnum = BreakpointNameEnum.SM;

  @Computed
  get isLargeWindow(): boolean {
    return this.currentBreakpoint === BreakpointNameEnum.LG || this.currentBreakpoint === BreakpointNameEnum.XL;
  }

  @Computed
  get isMiddleWindow(): boolean {
    return this.currentBreakpoint === BreakpointNameEnum.MD;
  }

  @Computed
  get isSmallWindow(): boolean {
    return this.currentBreakpoint === BreakpointNameEnum.SM;
  }

  @Computed
  get pagePadding(): number {
    return GridRowColSetting.getPageMargin(this.currentBreakpoint);
  }
}
