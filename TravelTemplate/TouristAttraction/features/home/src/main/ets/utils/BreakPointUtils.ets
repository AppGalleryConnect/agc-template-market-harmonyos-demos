import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from 'common';

@ObservedV2
export class BreakPointUtils {
  @Trace static breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  private static breakPointEnum: Record<string, number> = {
    'sm': 16,
    'md': 24,
    'lg': 32,
    'xl': 32,
  }

  public static getBreakPointGutter() {
    return BreakPointUtils.breakPointEnum[BreakPointUtils.breakPointModel.currentBreakpoint]
  }
}