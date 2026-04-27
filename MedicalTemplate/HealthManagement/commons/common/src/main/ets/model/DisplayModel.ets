import { display } from '@kit.ArkUI';

@ObservedV2
export class DisplayModel {
  // 是否是横屏
  @Trace isLandscape: boolean = false;
  // 是否是折叠屏
  @Trace isFoldable: boolean = false
  // 当前可折叠设备的折叠状态
  @Trace foldStatus: display.FoldStatus = 0;
  constructor() {
    if (canIUse('SystemCapability.Window.SessionManager')) {
      this.foldStatus = display.getFoldStatus();
    }
  }
}