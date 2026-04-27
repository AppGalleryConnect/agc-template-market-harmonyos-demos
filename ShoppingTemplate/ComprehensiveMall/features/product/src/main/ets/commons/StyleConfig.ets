import { BreakpointSystem, BreakpointTypeEnum } from 'lib_foundation';

@ObservedV2
export class ProductSwiperStyleConfig {
  @Computed
  public static get imageMaxHeight() {
    return BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.LG ? '100%' : 360;
  }

  @Computed
  public static get imageAspectRatio() {
    return BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.LG ? undefined : 1.0;
  }

  @Computed
  public static get outImageDisplayWidth() {
    return BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.MD ? 120 : 0;
  }

  @Computed
  public static get swiperPadding() {
    return BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.MD ? 0 : $r('app.float.space_l');
  }

  @Computed
  public static get imagePadding() {
    if (BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.SM) {
      return {
        left: 6,
        right: 6,
      } as Padding
    }
    return BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.MD ?
      {
        left: 6,
        right: 6,
        top: 8,
        bottom: 8,
      } as Padding : 0;
  }
}