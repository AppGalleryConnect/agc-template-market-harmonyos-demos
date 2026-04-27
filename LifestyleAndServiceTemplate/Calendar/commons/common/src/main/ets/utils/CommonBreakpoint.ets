import { BreakpointModel } from '../models/BreakpointModel';
import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointType, BreakpointTypeOptions } from '../constants/GridRowColSetting';

@ObservedV2
export class CommonBreakpoint<T> extends BreakpointType<T> {
  @Trace breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  constructor(options: BreakpointTypeOptions<T>) {
    super(options)
  }

  getLanes(): T {
    return this.getValue(this.breakpointModel.currentBreakpoint)
  }
}
