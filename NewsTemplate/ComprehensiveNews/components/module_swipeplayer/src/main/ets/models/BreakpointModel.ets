import { display } from '@kit.ArkUI';
import { BreakpointNameEnum } from '../type/Index';

/*
 * 栅格断点
 */
@ObservedV2
export class BreakpointModel {
  @Trace currentBreakpoint: BreakpointNameEnum = BreakpointNameEnum.SM;
  // 是否通过设备旋转自动横屏
  @Trace isLandscapeAuto: boolean = false;
  // 进入全屏页面前的屏幕方向
  @Trace orientationBefore: display.Orientation = display.Orientation.PORTRAIT;
}