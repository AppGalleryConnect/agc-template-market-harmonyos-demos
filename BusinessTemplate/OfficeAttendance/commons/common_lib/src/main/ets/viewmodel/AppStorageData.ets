@ObservedV2
export class AppStorageData {
  @Trace currentWidthBreakpoint: string = 'sm';

  @Trace windowWidthVp: number = 0;

  @Trace windowHeightVp: number = 0;

  isSM() {
    return this.currentWidthBreakpoint === 'sm';
  }
}