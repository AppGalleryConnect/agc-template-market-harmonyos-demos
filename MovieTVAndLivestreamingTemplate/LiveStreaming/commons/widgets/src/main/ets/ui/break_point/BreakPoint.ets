import { BreakPointValue } from './BreakPointType';

@ObservedV2
export class BreakPoint {
  @Trace value: BreakPointValue = BreakPointValue.SM;

  constructor(value?: BreakPointValue) {
    this.value = value || BreakPointValue.SM;
  }
}