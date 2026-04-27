import { window } from '@kit.ArkUI';

/**
 * 窗口持久化
 */
@ObservedV2
export class WindowModel {
  @Trace windowTopHeight: number = 38.77;
  @Trace windowBottomHeight: number = 28;
  @Trace fullScreen: boolean = false;
  @Trace windowStage?: window.WindowStage = undefined;

  getWindowTopHeight(): number {
    return this.windowTopHeight || 38.77;
  }

  getWindowBottomHeight(): number {
    return this.windowBottomHeight || 28;
  }
}