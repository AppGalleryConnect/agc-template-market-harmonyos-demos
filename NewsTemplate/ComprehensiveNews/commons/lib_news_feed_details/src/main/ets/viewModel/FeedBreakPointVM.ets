import { AppStorageV2 } from '@kit.ArkUI';
import { BasePinchGestureUtils, BreakpointModel, BreakpointNameEnum, GlobalContextUtils } from 'lib_common';

@ObservedV2
export class FeedBreakPointVM {
  @Trace isSplit: boolean = false
  @Trace breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace pinchGestureUtils: BasePinchGestureUtils = new BasePinchGestureUtils();

  constructor() {
    this.pinchGestureUtils.setGestureEnabled(false);
    this.pinchGestureUtils.setOnScaleChange((scale) => {
      const oldV = this.isSplit;

      this.isSplit = scale < 1;

      if (oldV && this.isSplit) {
        GlobalContextUtils.showToast({ message: '已缩至最小' });
      } else if (this.isSplit) {
        GlobalContextUtils.showToast({ message: '已显示更多内容' });
      } else if (oldV) {
        GlobalContextUtils.showToast({ message: '已显示更少内容' });
      } else {
        GlobalContextUtils.showToast({ message: '已放至最大' });
      }
    })
  }

  @Computed
  get getNewsLanes() {
    return this.isFolderStatus ? 2 : 1
  }

  @Computed
  get isFolderStatus() {
    return this.isLargeDevice && this.isSplit
  }

  @Computed
  get isLargeDevice() {
    return this.breakpointModel.currentBreakpoint !== BreakpointNameEnum.SM
  }

  public switchSplit() {
    GlobalContextUtils.globalUIContext.animateTo({
      duration: 200,
      curve: Curve.EaseOut,
      playMode: PlayMode.Normal,
    }, () => {
      this.isSplit = !this.isSplit
    })
  }
}