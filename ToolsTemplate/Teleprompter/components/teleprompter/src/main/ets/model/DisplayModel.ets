
@ObservedV2
export class DisplayModel {
  // 是否是横屏
  @Trace isLandscape: boolean = false;
  // 是否是折叠屏
  @Trace isFoldAble: boolean = false
  // 是否是展开状态
  @Trace isFullMode: boolean = false
}