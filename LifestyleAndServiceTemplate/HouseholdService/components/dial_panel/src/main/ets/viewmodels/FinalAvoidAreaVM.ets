import { window } from '@kit.ArkUI';
import { WindowSizeVM } from './WindowSizeVM';

@ObservedV2
export class FinalAvoidAreaVM {

  @Trace
  private windowSize: WindowSizeVM = new WindowSizeVM();

  @Trace
  private system: window.AvoidArea | null = null;

  @Trace
  private cutout: window.AvoidArea | null = null;

  @Trace
  private indicator: window.AvoidArea | null = null;

  @Computed
  public get top(): number {
    const systemTop: number =
      this.system?.topRect.height ? (this.system.topRect.top + this.system.topRect.height) : 0;
    const cutoutTop: number =
      this.cutout?.topRect.height ? (this.cutout.topRect.top + this.cutout.topRect.height) : 0;
    return Math.max(systemTop, cutoutTop);
  }

  @Computed
  public get bottom(): number {
    const cutoutBottom: number =
      this.cutout?.bottomRect.height ? (this.windowSize.height - this.cutout.bottomRect.top) : 0;
    const indicatorBottom: number =
      this.indicator?.bottomRect.height ? (this.windowSize.height - this.indicator.bottomRect.top) : 0;
    return Math.max(cutoutBottom, indicatorBottom);
  }

  public setWindowSize(size: WindowSizeVM): void {
    this.windowSize = size;
  }

  public setSystemAvoidArea(area: window.AvoidArea): void {
    this.system = area;
  }

  public setCutoutAvoidArea(area: window.AvoidArea): void {
    this.cutout = area;
  }

  public setIndicatorAvoidArea(area: window.AvoidArea): void {
    this.indicator = area;
  }
}
