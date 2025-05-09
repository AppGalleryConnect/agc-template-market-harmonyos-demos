import { BreakpointConstants } from '../constants/BreakpointConstants';

export class BreakpointType<T> {
  public sm: T;
  public md: T;
  public lg: T;

  constructor(sm: T, md: T, lg: T) {
    this.sm = sm;
    this.md = md;
    this.lg = lg;
  }

  getValue(currentBreakpoint: string): T {
    if (currentBreakpoint === BreakpointConstants.BREAKPOINT_MD) {
      return this.md;
    }
    if (currentBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
      return this.lg;
    } else {
      return this.sm;
    }
  }
}